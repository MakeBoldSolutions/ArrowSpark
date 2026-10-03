// Receives the game's one-way "attempt completed" message on the Play page.
//
// The game, running in a same-origin iframe, posts one JSON string per completed attempt.
// A message is accepted only if it comes from this page's own origin, from the game iframe's
// window, and has exactly the contract's eight properties with valid values. Anything else is
// ignored silently. The latest valid attempt is kept in memory for this page visit only: it is
// never written to browser storage, never sent anywhere except as part of a reaction the
// visitor chooses to submit, and never sent back to the game.

export interface Attempt {
  puzzleId: string;
  puzzleVersion: string;
  mistakes: number;
  openMoveAssists: number;
  score: number;
  elapsedSeconds: number;
}

export const MESSAGE_TYPE = 'arrowspark.attemptCompleted';
export const CONTRACT_VERSION = 1;
export const MAX_MESSAGE_LENGTH = 1024;

const MESSAGE_KEYS = ['type', 'contractVersion', 'puzzleId', 'puzzleVersion', 'mistakes', 'openMoveAssists', 'score', 'elapsedSeconds'];
const PUZZLE_ID = /^[a-z0-9_-]{1,64}$/;
const PUZZLE_VERSION = /^g1-[0-9a-f]{12}$/;

const isCount = (value: unknown, max: number): value is number =>
  typeof value === 'number' && Number.isInteger(value) && value >= 0 && value <= max;

let latest: Attempt | null = null;

/** Validates one message's data. Returns the attempt, or null when anything is off. */
export function parseAttemptMessage(data: unknown): Attempt | null {
  if (typeof data !== 'string' || data.length > MAX_MESSAGE_LENGTH) return null;
  let value: unknown;
  try {
    value = JSON.parse(data);
  } catch {
    return null;
  }
  if (typeof value !== 'object' || value === null || Array.isArray(value)) return null;
  const message = value as Record<string, unknown>;
  const keys = Object.keys(message);
  if (keys.length !== MESSAGE_KEYS.length || !MESSAGE_KEYS.every((key) => keys.includes(key))) return null;
  if (message['type'] !== MESSAGE_TYPE || message['contractVersion'] !== CONTRACT_VERSION) return null;
  const { puzzleId, puzzleVersion, mistakes, openMoveAssists, score, elapsedSeconds } = message;
  if (typeof puzzleId !== 'string' || !PUZZLE_ID.test(puzzleId)) return null;
  if (typeof puzzleVersion !== 'string' || !PUZZLE_VERSION.test(puzzleVersion)) return null;
  if (!isCount(mistakes, 10_000) || !isCount(openMoveAssists, 10_000) || !isCount(score, 10_000)) return null;
  if (!isCount(elapsedSeconds, 86_400)) return null;
  return { puzzleId, puzzleVersion, mistakes, openMoveAssists, score, elapsedSeconds };
}

/**
 * Handles one window message. Accepts it only from `expectedOrigin` and from the game frame's
 * own window; a valid attempt replaces the previous one. Returns whether it was accepted.
 */
export function handleMessage(event: MessageEvent, gameWindow: Window | null, expectedOrigin: string): boolean {
  if (gameWindow === null || event.origin !== expectedOrigin || event.source !== gameWindow) return false;
  const attempt = parseAttemptMessage(event.data);
  if (attempt === null) return false;
  latest = attempt;
  if (import.meta.env.DEV) console.debug('Attempt received from the game', attempt);
  return true;
}

/** The latest completed attempt of this page visit, if any. */
export function getLatestAttempt(): Attempt | null {
  return latest;
}

/** Starts listening for the game's messages. Returns a function that stops listening. */
export function startGameBridge(iframe: HTMLIFrameElement): () => void {
  const listener = (event: MessageEvent) => {
    handleMessage(event, iframe.contentWindow, window.location.origin);
  };
  window.addEventListener('message', listener);
  return () => window.removeEventListener('message', listener);
}

/** Test helper: forget the held attempt. */
export function clearLatestAttempt(): void {
  latest = null;
}
