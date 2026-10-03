// The reactions API request contract (schemaVersion 1), mirrored exactly on the client.
// The client sends only bodies that pass this check; the API validates again on its side.

export const MAX_BODY_BYTES = 4096;
export const MAX_COMMENT_LENGTH = 1000;

export interface AttemptData {
  puzzleId: string;
  puzzleVersion: string;
  mistakes: number;
  openMoveAssists: number;
  score: number;
  elapsedSeconds: number;
}

export interface GameReaction {
  reactionType: 'game';
  readStoryFirst?: 'yes' | 'no';
  finished?: 'finished' | 'partway' | 'notStarted';
  satisfaction?: 1 | 2 | 3 | 4 | 5;
  playAnother?: 'yes' | 'maybe' | 'no';
  comment?: string;
  attempt?: AttemptData;
}

export interface StoryReaction {
  reactionType: 'story';
  madeSense?: 'yes' | 'partly' | 'no';
  changedView?: 'moreInterested' | 'noChange' | 'lessInterested';
  wouldUse?: 'yes' | 'maybe' | 'no';
  comment?: string;
}

export type ReactionBody = GameReaction | StoryReaction;

const GAME_FIELDS: Record<string, readonly unknown[] | 'comment' | 'attempt'> = {
  readStoryFirst: ['yes', 'no'],
  finished: ['finished', 'partway', 'notStarted'],
  satisfaction: [1, 2, 3, 4, 5],
  playAnother: ['yes', 'maybe', 'no'],
  comment: 'comment',
  attempt: 'attempt',
};

const STORY_FIELDS: Record<string, readonly unknown[] | 'comment'> = {
  madeSense: ['yes', 'partly', 'no'],
  changedView: ['moreInterested', 'noChange', 'lessInterested'],
  wouldUse: ['yes', 'maybe', 'no'],
  comment: 'comment',
};

const ID_PATTERN = /^[a-z0-9_-]{1,64}$/;
const ATTEMPT_LIMITS: Record<keyof AttemptData, number | 'id'> = {
  puzzleId: 'id',
  puzzleVersion: 'id',
  mistakes: 10_000,
  openMoveAssists: 10_000,
  score: 10_000,
  elapsedSeconds: 86_400,
};

const isPlainObject = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

function attemptProblems(value: unknown): string[] {
  if (!isPlainObject(value)) return ['attempt'];
  const problems: string[] = [];
  for (const key of Object.keys(value)) {
    if (!(key in ATTEMPT_LIMITS)) problems.push(`attempt.${key}`);
  }
  for (const [key, limit] of Object.entries(ATTEMPT_LIMITS)) {
    const field = value[key];
    if (limit === 'id') {
      if (typeof field !== 'string' || !ID_PATTERN.test(field)) problems.push(`attempt.${key}`);
    } else if (typeof field !== 'number' || !Number.isInteger(field) || field < 0 || field > limit) {
      problems.push(`attempt.${key}`);
    }
  }
  return problems;
}

/** UTF-8 size of the body exactly as it would be sent. */
export function bodyBytes(body: unknown): number {
  return new TextEncoder().encode(JSON.stringify(body)).length;
}

/** Names of the properties that break the contract; empty when the body is valid. */
export function reactionProblems(value: unknown): string[] {
  if (!isPlainObject(value)) return ['body'];
  const type = value['reactionType'];
  const fields = type === 'game' ? GAME_FIELDS : type === 'story' ? STORY_FIELDS : null;
  if (fields === null) return ['reactionType'];
  const problems: string[] = [];
  for (const [key, field] of Object.entries(value)) {
    if (key === 'reactionType') continue;
    const rule = fields[key];
    if (rule === undefined) problems.push(key);
    else if (rule === 'comment') {
      if (typeof field !== 'string' || field.length < 1 || field.length > MAX_COMMENT_LENGTH || field !== field.trim()) {
        problems.push(key);
      }
    } else if (rule === 'attempt') problems.push(...attemptProblems(field));
    else if (!rule.includes(field)) problems.push(key);
  }
  if (bodyBytes(value) > MAX_BODY_BYTES) problems.push('body');
  return problems;
}

export function isValidReaction(value: unknown): value is ReactionBody {
  return reactionProblems(value).length === 0;
}

/** Trims a free-text answer; an empty answer is left out of the body entirely. */
export function cleanComment(text: string | null | undefined): string | undefined {
  const trimmed = (text ?? '').trim();
  return trimmed.length > 0 ? trimmed : undefined;
}
