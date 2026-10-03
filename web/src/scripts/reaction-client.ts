// Sends anonymous reactions to the reactions API. No credentials, no cookies, no identifiers.
// Responses are classified exactly: 202 sent; 400/413/415 invalid (dropped, never retried);
// anything else (404, 405, 429, 5xx, network error, timeout, CORS or CSP block) means the
// endpoint is unavailable and the reaction waits in this browser's pending queue.
import { isValidReaction, type ReactionBody } from './reaction-schema';
import type { PendingQueue, SendOutcome } from './pending-queue';

export const REACTIONS_PATH = '/api/public/arrowspark/reactions';
export const TIMEOUT_MS = 8_000;

export type SubmitResult = 'sent' | 'invalid' | 'saved' | 'full' | 'unavailable';

export interface ClientOptions {
  baseUrl: string | undefined;
  fetch?: typeof fetch;
  timeoutMs?: number;
}

export function reactionsEndpoint(baseUrl: string): string {
  return `${baseUrl.replace(/\/+$/, '')}${REACTIONS_PATH}`;
}

export function classifyStatus(status: number): SendOutcome {
  if (status === 202) return 'sent';
  if (status === 400 || status === 413 || status === 415) return 'invalid';
  return 'pending';
}

/** One POST of one body. Never throws; an unset endpoint behaves like an unreachable one. */
export async function sendReaction(body: ReactionBody, options: ClientOptions): Promise<SendOutcome> {
  if (!options.baseUrl) return 'pending';
  const doFetch = options.fetch ?? fetch;
  try {
    const response = await doFetch(reactionsEndpoint(options.baseUrl), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
      credentials: 'omit',
      cache: 'no-store',
      referrerPolicy: 'no-referrer',
      signal: AbortSignal.timeout(options.timeoutMs ?? TIMEOUT_MS),
    });
    return classifyStatus(response.status);
  } catch {
    return 'pending';
  }
}

/**
 * Submits a new reaction: validates it, flushes anything already waiting, sends it, and keeps
 * it locally if the endpoint is unavailable.
 */
export async function submitReaction(body: ReactionBody, queue: PendingQueue, options: ClientOptions): Promise<SubmitResult> {
  if (!isValidReaction(body)) return 'invalid';
  const send = (pending: ReactionBody) => sendReaction(pending, options);
  await queue.flush(send);
  const outcome = await send(body);
  if (outcome === 'sent' || outcome === 'invalid') return outcome;
  return queue.save(body);
}
