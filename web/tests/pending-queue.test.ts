import { beforeEach, describe, expect, it } from 'vitest';
import {
  MAX_ENTRIES,
  STORAGE_KEY,
  createPendingQueue,
  type LockManagerLike,
  type QueueDeps,
  type SendOutcome,
} from '../src/scripts/pending-queue';
import type { ReactionBody } from '../src/scripts/reaction-schema';

const story = (n: number): ReactionBody => ({ reactionType: 'story', comment: `reaction ${n}` });

/** A simple in-process lock: callbacks for one name run strictly one after another. */
function fakeLocks(): LockManagerLike {
  const tails = new Map<string, Promise<unknown>>();
  return {
    request<T>(name: string, callback: () => Promise<T>): Promise<T> {
      const previous = tails.get(name) ?? Promise.resolve();
      const run = previous.then(callback, callback);
      tails.set(name, run.catch(() => undefined));
      return run;
    },
  };
}

let day = '2026-10-10';
const deps = (extra: Partial<QueueDeps> = {}): QueueDeps => ({ storage: () => localStorage, today: () => day, ...extra });

/** A sender that records bodies and answers with the given outcomes in turn. */
function recorder(outcomes: SendOutcome[] | SendOutcome = 'sent', delayMs = 0) {
  const sent: ReactionBody[] = [];
  let call = 0;
  const send = async (body: ReactionBody) => {
    sent.push(body);
    if (delayMs) await new Promise((resolve) => setTimeout(resolve, delayMs));
    const outcome = Array.isArray(outcomes) ? (outcomes[call] ?? outcomes[outcomes.length - 1]!) : outcomes;
    call += 1;
    return outcome;
  };
  return { send, sent };
}

describe('pending queue', () => {
  beforeEach(() => {
    localStorage.clear();
    day = '2026-10-10';
  });

  it('saves an unsent reaction as the exact body plus its UTC day, and nothing else', () => {
    const queue = createPendingQueue(deps());
    expect(queue.save(story(1))).toBe('saved');
    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY)!);
    expect(stored).toEqual([{ body: story(1), savedOn: '2026-10-10' }]);
    expect(Object.keys(stored[0])).toEqual(['body', 'savedOn']);
  });

  it('holds at most five entries and refuses the sixth without evicting', () => {
    const queue = createPendingQueue(deps());
    for (let n = 1; n <= MAX_ENTRIES; n += 1) expect(queue.save(story(n))).toBe('saved');
    expect(queue.save(story(6))).toBe('full');
    expect(queue.entries().map((entry) => entry.body)).toEqual([1, 2, 3, 4, 5].map(story));
  });

  it('drops entries older than seven days without sending them', async () => {
    const queue = createPendingQueue(deps());
    day = '2026-10-01';
    queue.save(story(1));
    day = '2026-10-03';
    queue.save(story(2));
    day = '2026-10-09';
    const { send, sent } = recorder('pending');
    await queue.flush(send);
    expect(sent).toEqual([story(2)]); // the 8-day-old entry was pruned, not sent
    expect(queue.entries().map((entry) => entry.body)).toEqual([story(2)]);
  });

  it('a full queue after pruning still refuses rather than evicting', () => {
    const queue = createPendingQueue(deps());
    day = '2026-10-01';
    queue.save(story(1));
    day = '2026-10-05';
    for (let n = 2; n <= 5; n += 1) queue.save(story(n));
    day = '2026-10-09'; // entry 1 is now expired and pruned; four remain
    expect(queue.save(story(6))).toBe('saved');
    expect(queue.save(story(7))).toBe('full');
  });

  it('removes entries on sent (202) and on invalid (400/413/415)', async () => {
    const queue = createPendingQueue(deps());
    queue.save(story(1));
    queue.save(story(2));
    const { send } = recorder(['sent', 'invalid']);
    await queue.flush(send);
    expect(queue.entries()).toEqual([]);
    expect(localStorage.getItem(STORAGE_KEY)).toBeNull();
  });

  it('keeps an entry on an unavailable outcome and stops flushing', async () => {
    const queue = createPendingQueue(deps());
    queue.save(story(1));
    queue.save(story(2));
    queue.save(story(3));
    const { send, sent } = recorder(['sent', 'pending', 'sent']);
    await queue.flush(send);
    expect(sent).toEqual([story(1), story(2)]);
    expect(queue.entries().map((entry) => entry.body)).toEqual([story(2), story(3)]);
  });

  it('sends each entry once per flush, in order', async () => {
    const queue = createPendingQueue(deps());
    [1, 2, 3].forEach((n) => queue.save(story(n)));
    const { send, sent } = recorder('sent');
    await queue.flush(send);
    await queue.flush(send);
    expect(sent).toEqual([story(1), story(2), story(3)]);
  });

  for (const [label, locks] of [
    ['with Web Locks', fakeLocks()],
    ['with the claim-before-send fallback', undefined],
  ] as const) {
    it(`two flushers at once send each entry exactly once (${label})`, async () => {
      const first = createPendingQueue(deps({ locks }));
      const second = createPendingQueue(deps({ locks }));
      [1, 2, 3].forEach((n) => first.save(story(n)));
      const { send, sent } = recorder('sent', 5);
      await Promise.all([first.flush(send), second.flush(send)]);
      expect(sent.map((body) => (body as { comment: string }).comment).sort()).toEqual(['reaction 1', 'reaction 2', 'reaction 3']);
      expect(first.entries()).toEqual([]);
    });

    it(`an unavailable outcome during a concurrent flush loses nothing (${label})`, async () => {
      const first = createPendingQueue(deps({ locks }));
      const second = createPendingQueue(deps({ locks }));
      [1, 2].forEach((n) => first.save(story(n)));
      const { send } = recorder('pending', 5);
      await Promise.all([first.flush(send), second.flush(send)]);
      expect(first.entries().map((entry) => entry.body)).toEqual([story(1), story(2)]);
    });
  }

  it('Discard clears the queue', () => {
    const queue = createPendingQueue(deps());
    queue.save(story(1));
    queue.discard();
    expect(queue.entries()).toEqual([]);
    expect(localStorage.getItem(STORAGE_KEY)).toBeNull();
  });

  it('reports unavailable when storage is blocked, and never throws', async () => {
    const blocked = createPendingQueue({
      storage: () => {
        throw new DOMException('blocked', 'SecurityError');
      },
    });
    expect(blocked.available()).toBe(false);
    expect(blocked.save(story(1))).toBe('unavailable');
    await expect(blocked.flush(async () => 'sent')).resolves.toBeUndefined();
    expect(() => blocked.discard()).not.toThrow();
  });

  it('ignores stored data that is not a valid queue', () => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify([{ body: { reactionType: 'story', visitorId: 'x' }, savedOn: '2026-10-10' }, 'junk']));
    expect(createPendingQueue(deps()).entries()).toEqual([]);
    localStorage.setItem(STORAGE_KEY, '{not json');
    expect(createPendingQueue(deps()).entries()).toEqual([]);
  });

  it('stores no visitor or entry identifier', () => {
    const queue = createPendingQueue(deps());
    queue.save({ reactionType: 'game', satisfaction: 4 });
    const text = localStorage.getItem(STORAGE_KEY)!;
    expect(text).not.toMatch(/"(id|uuid|visitor|session|device|recordId)"/i);
    expect(Object.keys(localStorage)).toEqual([STORAGE_KEY]);
  });

  it('uses no timers', async () => {
    const realSetTimeout = globalThis.setTimeout;
    const realSetInterval = globalThis.setInterval;
    let timers = 0;
    globalThis.setTimeout = ((...args: Parameters<typeof setTimeout>) => {
      timers += 1;
      return realSetTimeout(...args);
    }) as typeof setTimeout;
    globalThis.setInterval = ((...args: Parameters<typeof setInterval>) => {
      timers += 1;
      return realSetInterval(...args);
    }) as typeof setInterval;
    try {
      const queue = createPendingQueue(deps({ locks: fakeLocks() }));
      queue.save(story(1));
      await queue.flush(async () => 'pending');
      queue.discard();
    } finally {
      globalThis.setTimeout = realSetTimeout;
      globalThis.setInterval = realSetInterval;
    }
    expect(timers).toBe(0);
  });
});
