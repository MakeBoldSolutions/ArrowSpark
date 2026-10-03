// A small local queue for reactions the visitor tried to send while the endpoint was
// unavailable. It lives in this browser only and holds at most five entries, each the exact
// request body plus the UTC day it was saved (used only to expire it after seven days, never
// sent). No identifiers, no timers, no background retry: the queue is flushed once per page
// load and just before a new submission, one send per entry, serialized across tabs.
import { isValidReaction, type ReactionBody } from './reaction-schema';

export const STORAGE_KEY = 'arrowspark.pendingReactions';
export const LOCK_NAME = 'arrowspark.pendingReactions.flush';
export const MAX_ENTRIES = 5;
export const RETENTION_DAYS = 7;

export interface PendingEntry {
  body: ReactionBody;
  savedOn: string; // YYYY-MM-DD, UTC
}

/** How one send attempt ended. */
export type SendOutcome = 'sent' | 'invalid' | 'pending';
export type SaveResult = 'saved' | 'full' | 'unavailable';

export interface LockManagerLike {
  request<T>(name: string, callback: () => Promise<T>): Promise<T>;
}

export interface QueueDeps {
  /** Browser storage; a getter so a blocked or missing store surfaces as an exception. */
  storage: () => Storage;
  /** Today's UTC date as YYYY-MM-DD. */
  today?: () => string;
  /** Cross-tab lock; when absent, entries are claimed (removed) before they are sent. */
  locks?: LockManagerLike | undefined;
}

export class StorageUnavailableError extends Error {}

const utcToday = () => new Date().toISOString().slice(0, 10);

function daysBetween(from: string, to: string): number {
  return Math.round((Date.parse(`${to}T00:00:00Z`) - Date.parse(`${from}T00:00:00Z`)) / 86_400_000);
}

function isEntry(value: unknown): value is PendingEntry {
  if (typeof value !== 'object' || value === null) return false;
  const entry = value as Record<string, unknown>;
  return (
    Object.keys(entry).length === 2 &&
    typeof entry['savedOn'] === 'string' &&
    /^\d{4}-\d{2}-\d{2}$/.test(entry['savedOn']) &&
    isValidReaction(entry['body'])
  );
}

export function createPendingQueue(deps: QueueDeps) {
  const today = deps.today ?? utcToday;

  function store(): Storage {
    try {
      return deps.storage();
    } catch (error) {
      throw new StorageUnavailableError(error instanceof Error ? error.message : String(error));
    }
  }

  function read(): PendingEntry[] {
    let text: string | null;
    try {
      text = store().getItem(STORAGE_KEY);
    } catch (error) {
      throw error instanceof StorageUnavailableError ? error : new StorageUnavailableError(String(error));
    }
    if (!text) return [];
    try {
      const parsed: unknown = JSON.parse(text);
      return Array.isArray(parsed) ? parsed.filter(isEntry).slice(0, MAX_ENTRIES) : [];
    } catch {
      return [];
    }
  }

  function write(entries: PendingEntry[]): void {
    try {
      if (entries.length === 0) store().removeItem(STORAGE_KEY);
      else store().setItem(STORAGE_KEY, JSON.stringify(entries));
    } catch (error) {
      throw error instanceof StorageUnavailableError ? error : new StorageUnavailableError(String(error));
    }
  }

  function removeOne(entries: PendingEntry[], target: PendingEntry): PendingEntry[] {
    const key = JSON.stringify(target);
    const index = entries.findIndex((entry) => JSON.stringify(entry) === key);
    return index === -1 ? entries : [...entries.slice(0, index), ...entries.slice(index + 1)];
  }

  /** Entries currently waiting (expired ones excluded). */
  function entries(): PendingEntry[] {
    const now = today();
    return read().filter((entry) => daysBetween(entry.savedOn, now) <= RETENTION_DAYS);
  }

  /** Drops entries older than the retention period, without sending them. */
  function prune(): void {
    const current = read();
    const kept = entries();
    if (kept.length !== current.length) write(kept);
  }

  /** Keeps one unsent body. Refuses the newest when the queue is full; never evicts. */
  function save(body: ReactionBody): SaveResult {
    try {
      prune();
      const current = read();
      if (current.length >= MAX_ENTRIES) return 'full';
      write([...current, { body, savedOn: today() }]);
      return 'saved';
    } catch (error) {
      if (error instanceof StorageUnavailableError) return 'unavailable';
      throw error;
    }
  }

  async function flushWithLock(send: (body: ReactionBody) => Promise<SendOutcome>): Promise<void> {
    for (const entry of entries()) {
      const outcome = await send(entry.body);
      if (outcome === 'pending') return;
      write(removeOne(read(), entry));
    }
  }

  async function flushByClaiming(send: (body: ReactionBody) => Promise<SendOutcome>): Promise<void> {
    // Without cross-tab locks, take every entry out of storage before sending, so another tab
    // flushing at the same moment finds nothing to send. Unsent entries go back on a keep outcome.
    const claimed = entries();
    if (claimed.length === 0) return;
    write([]);
    for (let index = 0; index < claimed.length; index += 1) {
      const outcome = await send(claimed[index]!.body);
      if (outcome === 'pending') {
        const restored = [...claimed.slice(index), ...read()].slice(0, MAX_ENTRIES);
        write(restored);
        return;
      }
    }
  }

  /**
   * Sends each waiting entry once, in order. 202 and 400/413/415 remove it; any other outcome
   * keeps it and stops the flush (the endpoint is down or not yet deployed).
   */
  async function flush(send: (body: ReactionBody) => Promise<SendOutcome>): Promise<void> {
    try {
      prune();
      if (read().length === 0) return;
      if (deps.locks) await deps.locks.request(LOCK_NAME, () => flushWithLock(send));
      else await flushByClaiming(send);
    } catch (error) {
      if (!(error instanceof StorageUnavailableError)) throw error;
    }
  }

  /** The visitor's "Discard unsent feedback". */
  function discard(): void {
    try {
      write([]);
    } catch (error) {
      if (!(error instanceof StorageUnavailableError)) throw error;
    }
  }

  /** Whether storage can be used at all on this device. */
  function available(): boolean {
    try {
      read();
      return true;
    } catch {
      return false;
    }
  }

  return { entries, save, flush, discard, prune, available };
}

export type PendingQueue = ReturnType<typeof createPendingQueue>;

/** The queue for this browser, with Web Locks when the browser provides them. */
export function browserPendingQueue(): PendingQueue {
  const locks = typeof navigator !== 'undefined' && 'locks' in navigator ? (navigator.locks as LockManagerLike) : undefined;
  return createPendingQueue({ storage: () => window.localStorage, locks });
}
