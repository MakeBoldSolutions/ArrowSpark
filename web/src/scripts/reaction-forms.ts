// Turns the reaction forms' answers into contract bodies and drives their visible states.
import type { Attempt } from './game-bridge';
import { cleanComment, type GameReaction, type StoryReaction } from './reaction-schema';
import type { SubmitResult } from './reaction-client';

type Answers = Record<string, string | undefined>;

const pick = <T extends string>(value: string | undefined, allowed: readonly T[]): T | undefined =>
  allowed.includes(value as T) ? (value as T) : undefined;

export function buildGameReaction(answers: Answers, attempt: Attempt | null): GameReaction {
  const satisfaction = Number(answers['satisfaction']);
  const body: GameReaction = { reactionType: 'game' };
  const readStoryFirst = pick(answers['readStoryFirst'], ['yes', 'no'] as const);
  const finished = pick(answers['finished'], ['finished', 'partway', 'notStarted'] as const);
  const playAnother = pick(answers['playAnother'], ['yes', 'maybe', 'no'] as const);
  const comment = cleanComment(answers['comment']);
  if (readStoryFirst) body.readStoryFirst = readStoryFirst;
  if (finished) body.finished = finished;
  if ([1, 2, 3, 4, 5].includes(satisfaction)) body.satisfaction = satisfaction as 1 | 2 | 3 | 4 | 5;
  if (playAnother) body.playAnother = playAnother;
  if (comment) body.comment = comment;
  if (attempt) body.attempt = { ...attempt };
  return body;
}

export function buildStoryReaction(answers: Answers): StoryReaction {
  const body: StoryReaction = { reactionType: 'story' };
  const madeSense = pick(answers['madeSense'], ['yes', 'partly', 'no'] as const);
  const changedView = pick(answers['changedView'], ['moreInterested', 'noChange', 'lessInterested'] as const);
  const wouldUse = pick(answers['wouldUse'], ['yes', 'maybe', 'no'] as const);
  const comment = cleanComment(answers['comment']);
  if (madeSense) body.madeSense = madeSense;
  if (changedView) body.changedView = changedView;
  if (wouldUse) body.wouldUse = wouldUse;
  if (comment) body.comment = comment;
  return body;
}

/** True when the visitor answered nothing at all; an empty reaction is not sent. */
export function isEmptyReaction(body: GameReaction | StoryReaction): boolean {
  return Object.keys(body).filter((key) => key !== 'reactionType' && key !== 'attempt').length === 0;
}

export const RESULT_MESSAGES: Record<SubmitResult | 'empty', string> = {
  sent: 'Thanks. Nothing here was required.',
  invalid: 'Something in this reaction couldn’t be sent.',
  saved: 'Saved on this device, not sent yet. It will be sent the next time you visit while feedback is available.',
  full: 'This one couldn’t be saved: you already have 5 unsent reactions on this device.',
  unavailable: 'Feedback is temporarily unavailable. Your game and the story are unaffected.',
  empty: 'Answer at least one question, or leave it; nothing here is required.',
};
