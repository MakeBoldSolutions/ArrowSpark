import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { clearLatestAttempt, getLatestAttempt, handleMessage, parseAttemptMessage } from '../src/scripts/game-bridge';

const ORIGIN = 'https://arrow.makeboldspark.com';

const valid = {
  type: 'arrowspark.attemptCompleted',
  contractVersion: 1,
  puzzleId: 'reference_knot',
  puzzleVersion: 'g1-7ce0942d4a5e',
  mistakes: 2,
  openMoveAssists: 2,
  score: 103,
  elapsedSeconds: 1260,
};

const gameWindow = {} as Window;
const otherWindow = {} as Window;

function message(data: unknown, origin = ORIGIN, source: Window | null = gameWindow): MessageEvent {
  return new MessageEvent('message', { data, origin, source: source as MessageEventSource | null });
}

describe('game bridge', () => {
  beforeEach(() => clearLatestAttempt());
  afterEach(() => vi.restoreAllMocks());

  it('accepts a valid same-origin message from the game frame', () => {
    expect(handleMessage(message(JSON.stringify(valid)), gameWindow, ORIGIN)).toBe(true);
    expect(getLatestAttempt()).toEqual({
      puzzleId: 'reference_knot',
      puzzleVersion: 'g1-7ce0942d4a5e',
      mistakes: 2,
      openMoveAssists: 2,
      score: 103,
      elapsedSeconds: 1260,
    });
  });

  it('ignores a message from another origin', () => {
    expect(handleMessage(message(JSON.stringify(valid), 'https://example.com'), gameWindow, ORIGIN)).toBe(false);
    expect(getLatestAttempt()).toBeNull();
  });

  it('ignores a message from a window other than the game frame', () => {
    expect(handleMessage(message(JSON.stringify(valid), ORIGIN, otherWindow), gameWindow, ORIGIN)).toBe(false);
    expect(handleMessage(message(JSON.stringify(valid), ORIGIN, null), gameWindow, ORIGIN)).toBe(false);
    expect(handleMessage(message(JSON.stringify(valid)), null, ORIGIN)).toBe(false);
  });

  it('ignores non-string data, oversized strings and malformed JSON', () => {
    expect(parseAttemptMessage(valid)).toBeNull();
    expect(parseAttemptMessage(JSON.stringify(valid).padEnd(1025, ' '))).toBeNull();
    expect(parseAttemptMessage('{not json')).toBeNull();
    expect(parseAttemptMessage('[]')).toBeNull();
    expect(parseAttemptMessage('null')).toBeNull();
  });

  it('accepts a message at exactly 1,024 characters', () => {
    const text = JSON.stringify(valid);
    expect(parseAttemptMessage(text.padEnd(1024, ' '))).not.toBeNull();
  });

  it('ignores extra or missing properties', () => {
    expect(parseAttemptMessage(JSON.stringify({ ...valid, visitorId: 'x' }))).toBeNull();
    const { score: _score, ...missing } = valid;
    expect(parseAttemptMessage(JSON.stringify(missing))).toBeNull();
  });

  it('ignores wrong type, contract version, types and ranges', () => {
    const bad: Array<Record<string, unknown>> = [
      { type: 'arrowspark.other' },
      { contractVersion: 2 },
      { puzzleId: 'Reference Knot' },
      { puzzleId: '' },
      { puzzleId: 'a'.repeat(65) },
      { puzzleVersion: '0.1.0' },
      { puzzleVersion: 'g1-7CE0942D4A5E' },
      { mistakes: -1 },
      { mistakes: 1.5 },
      { mistakes: '2' },
      { openMoveAssists: 10_001 },
      { score: null },
      { elapsedSeconds: 86_401 },
    ];
    for (const change of bad) {
      expect(parseAttemptMessage(JSON.stringify({ ...valid, ...change })), JSON.stringify(change)).toBeNull();
    }
  });

  it('keeps only the latest valid attempt', () => {
    handleMessage(message(JSON.stringify(valid)), gameWindow, ORIGIN);
    handleMessage(message(JSON.stringify({ ...valid, score: 110, mistakes: 0 })), gameWindow, ORIGIN);
    handleMessage(message('garbage'), gameWindow, ORIGIN);
    expect(getLatestAttempt()?.score).toBe(110);
    expect(getLatestAttempt()?.mistakes).toBe(0);
  });

  it('never touches browser storage', () => {
    const setItem = vi.spyOn(Storage.prototype, 'setItem');
    const getItem = vi.spyOn(Storage.prototype, 'getItem');
    handleMessage(message(JSON.stringify(valid)), gameWindow, ORIGIN);
    getLatestAttempt();
    expect(setItem).not.toHaveBeenCalled();
    expect(getItem).not.toHaveBeenCalled();
  });
});
