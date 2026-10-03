import { beforeEach, describe, expect, it, vi } from 'vitest';
import { REACTIONS_PATH, TIMEOUT_MS, classifyStatus, reactionsEndpoint, sendReaction, submitReaction } from '../src/scripts/reaction-client';
import { createPendingQueue, STORAGE_KEY } from '../src/scripts/pending-queue';
import { buildGameReaction } from '../src/scripts/reaction-forms';
import type { ReactionBody } from '../src/scripts/reaction-schema';

const BASE = 'https://makeboldspark.com';
const body: ReactionBody = { reactionType: 'story', madeSense: 'yes' };

function fakeFetch(status: number | Error) {
  return vi.fn(async (_url: RequestInfo | URL, _init?: RequestInit) => {
    if (status instanceof Error) throw status;
    return new Response(null, { status });
  });
}

describe('reaction client', () => {
  beforeEach(() => localStorage.clear());

  it('posts JSON to the fixed path with no credentials or cookies and an 8 s timeout', async () => {
    const fetch = fakeFetch(202);
    const timeout = vi.spyOn(AbortSignal, 'timeout');
    await sendReaction(body, { baseUrl: `${BASE}/`, fetch });
    const [url, init] = fetch.mock.calls[0]!;
    expect(url).toBe(`${BASE}${REACTIONS_PATH}`);
    expect(init?.method).toBe('POST');
    expect(init?.headers).toEqual({ 'Content-Type': 'application/json' });
    expect(init?.credentials).toBe('omit');
    expect(JSON.parse(String(init?.body))).toEqual(body);
    expect(timeout).toHaveBeenCalledWith(TIMEOUT_MS);
    expect(TIMEOUT_MS).toBe(8000);
  });

  it('classifies every response exactly', () => {
    expect(classifyStatus(202)).toBe('sent');
    for (const status of [400, 413, 415]) expect(classifyStatus(status)).toBe('invalid');
    for (const status of [200, 201, 204, 301, 401, 403, 404, 405, 409, 429, 500, 502, 503, 504]) {
      expect(classifyStatus(status)).toBe('pending');
    }
  });

  it('treats network errors, timeouts and CORS or CSP blocks as unavailable', async () => {
    for (const error of [new TypeError('Failed to fetch'), new DOMException('timed out', 'TimeoutError'), new TypeError('NetworkError when attempting to fetch resource.')]) {
      expect(await sendReaction(body, { baseUrl: BASE, fetch: fakeFetch(error) })).toBe('pending');
    }
  });

  it('treats an unset endpoint as unreachable without making a request', async () => {
    const fetch = fakeFetch(202);
    expect(await sendReaction(body, { baseUrl: undefined, fetch })).toBe('pending');
    expect(await sendReaction(body, { baseUrl: '', fetch })).toBe('pending');
    expect(fetch).not.toHaveBeenCalled();
  });

  it('builds the endpoint from the base URL', () => {
    expect(reactionsEndpoint('http://localhost:8787')).toBe('http://localhost:8787/api/public/arrowspark/reactions');
  });

  it('builds a game reaction from the form plus the latest attempt only when one exists', () => {
    const attempt = { puzzleId: 'reference_knot', puzzleVersion: 'g1-7ce0942d4a5e', mistakes: 2, openMoveAssists: 2, score: 103, elapsedSeconds: 1260 };
    const answers = { readStoryFirst: 'no', finished: 'finished', satisfaction: '4', playAnother: 'yes', comment: '  Loved the ending.  ' };
    expect(buildGameReaction(answers, attempt)).toEqual({
      reactionType: 'game',
      readStoryFirst: 'no',
      finished: 'finished',
      satisfaction: 4,
      playAnother: 'yes',
      comment: 'Loved the ending.',
      attempt,
    });
    expect(buildGameReaction({ satisfaction: '3', comment: '   ' }, null)).toEqual({ reactionType: 'game', satisfaction: 3 });
  });

  describe('submit', () => {
    const queue = () => createPendingQueue({ storage: () => localStorage, today: () => '2026-10-10' });

    it('sent on 202, with nothing queued', async () => {
      expect(await submitReaction(body, queue(), { baseUrl: BASE, fetch: fakeFetch(202) })).toBe('sent');
      expect(localStorage.getItem(STORAGE_KEY)).toBeNull();
    });

    it('invalid on 400/413/415, dropped and never queued', async () => {
      for (const status of [400, 413, 415]) {
        expect(await submitReaction(body, queue(), { baseUrl: BASE, fetch: fakeFetch(status) })).toBe('invalid');
      }
      expect(localStorage.getItem(STORAGE_KEY)).toBeNull();
    });

    it('never sends a body that breaks the contract', async () => {
      const fetch = fakeFetch(202);
      const bad = { reactionType: 'story', visitorId: 'x' } as unknown as ReactionBody;
      expect(await submitReaction(bad, queue(), { baseUrl: BASE, fetch })).toBe('invalid');
      expect(fetch).not.toHaveBeenCalled();
    });

    it('saved locally on 404, 405, 429, 5xx and network errors', async () => {
      for (const status of [404, 405, 429, 500, 503] as const) {
        localStorage.clear();
        expect(await submitReaction(body, queue(), { baseUrl: BASE, fetch: fakeFetch(status) })).toBe('saved');
        expect(JSON.parse(localStorage.getItem(STORAGE_KEY)!)).toEqual([{ body, savedOn: '2026-10-10' }]);
      }
      localStorage.clear();
      expect(await submitReaction(body, queue(), { baseUrl: BASE, fetch: fakeFetch(new TypeError('Failed to fetch')) })).toBe('saved');
    });

    it('flushes earlier pending reactions before sending a new one', async () => {
      const q = queue();
      q.save({ reactionType: 'story', comment: 'earlier' });
      const fetch = fakeFetch(202);
      expect(await submitReaction(body, q, { baseUrl: BASE, fetch })).toBe('sent');
      expect(fetch.mock.calls.map(([, init]) => JSON.parse(String(init?.body)))).toEqual([{ reactionType: 'story', comment: 'earlier' }, body]);
      expect(q.entries()).toEqual([]);
    });

    it('reports full when five reactions are already waiting', async () => {
      const q = queue();
      for (let n = 0; n < 5; n += 1) q.save({ reactionType: 'story', comment: `n${n}` });
      expect(await submitReaction(body, q, { baseUrl: BASE, fetch: fakeFetch(503) })).toBe('full');
    });

    it('requests carry only contract fields: no identifier, timestamp or correlation data', async () => {
      const fetch = fakeFetch(202);
      await submitReaction({ reactionType: 'game', satisfaction: 5 }, queue(), { baseUrl: BASE, fetch });
      const [, init] = fetch.mock.calls[0]!;
      expect(Object.keys(JSON.parse(String(init?.body)))).toEqual(['reactionType', 'satisfaction']);
      expect(Object.keys(init?.headers as Record<string, string>)).toEqual(['Content-Type']);
    });
  });
});
