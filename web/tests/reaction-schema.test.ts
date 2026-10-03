import { describe, expect, it } from 'vitest';
import { bodyBytes, cleanComment, isValidReaction, reactionProblems } from '../src/scripts/reaction-schema';

const attempt = {
  puzzleId: 'reference_knot',
  puzzleVersion: 'g1-0123456789ab',
  mistakes: 2,
  openMoveAssists: 2,
  score: 103,
  elapsedSeconds: 1260,
};

describe('reaction schema (contract conformance examples)', () => {
  it('accepts the valid game reaction with an attempt', () => {
    const body = {
      reactionType: 'game',
      readStoryFirst: 'no',
      finished: 'finished',
      satisfaction: 4,
      playAnother: 'yes',
      comment: 'The long arrow on the right was great.',
      attempt,
    };
    expect(reactionProblems(body)).toEqual([]);
  });

  it('accepts the valid story reaction', () => {
    expect(isValidReaction({ reactionType: 'story', madeSense: 'partly', changedView: 'moreInterested', wouldUse: 'maybe' })).toBe(true);
  });

  it('accepts minimal bodies and every allowed value', () => {
    expect(isValidReaction({ reactionType: 'story' })).toBe(true);
    expect(isValidReaction({ reactionType: 'game' })).toBe(true);
    for (const satisfaction of [1, 2, 3, 4, 5]) expect(isValidReaction({ reactionType: 'game', satisfaction })).toBe(true);
    for (const finished of ['finished', 'partway', 'notStarted']) expect(isValidReaction({ reactionType: 'game', finished })).toBe(true);
    for (const changedView of ['moreInterested', 'noChange', 'lessInterested']) {
      expect(isValidReaction({ reactionType: 'story', changedView })).toBe(true);
    }
  });

  it('rejects an unknown property', () => {
    expect(reactionProblems({ reactionType: 'game', visitorId: 'x' })).toEqual(['visitorId']);
  });

  it('rejects an out-of-range value', () => {
    expect(reactionProblems({ reactionType: 'game', satisfaction: 6 })).toEqual(['satisfaction']);
    expect(isValidReaction({ reactionType: 'game', satisfaction: 4.5 })).toBe(false);
    expect(isValidReaction({ reactionType: 'game', satisfaction: '4' })).toBe(false);
  });

  it('rejects an attempt on a story reaction', () => {
    expect(reactionProblems({ reactionType: 'story', attempt })).toEqual(['attempt']);
  });

  it('rejects an incomplete or extended attempt', () => {
    expect(isValidReaction({ reactionType: 'game', attempt: { puzzleId: 'reference_knot' } })).toBe(false);
    expect(isValidReaction({ reactionType: 'game', attempt: { ...attempt, sessionId: 'x' } })).toBe(false);
    expect(isValidReaction({ reactionType: 'game', attempt: { ...attempt, score: 10_001 } })).toBe(false);
    expect(isValidReaction({ reactionType: 'game', attempt: { ...attempt, elapsedSeconds: 86_401 } })).toBe(false);
    expect(isValidReaction({ reactionType: 'game', attempt: { ...attempt, puzzleId: 'Reference Knot' } })).toBe(false);
  });

  it('rejects an unknown or missing reaction type', () => {
    expect(reactionProblems({ reactionType: 'poll' })).toEqual(['reactionType']);
    expect(reactionProblems({ madeSense: 'yes' })).toEqual(['reactionType']);
    expect(reactionProblems(null)).toEqual(['body']);
  });

  it('rejects a 1,001-character comment and accepts 1,000', () => {
    expect(reactionProblems({ reactionType: 'story', comment: 'a'.repeat(1001) })).toEqual(['comment']);
    expect(isValidReaction({ reactionType: 'story', comment: 'a'.repeat(1000) })).toBe(true);
  });

  it('rejects an empty or untrimmed comment', () => {
    expect(isValidReaction({ reactionType: 'story', comment: '' })).toBe(false);
    expect(isValidReaction({ reactionType: 'story', comment: ' padded ' })).toBe(false);
  });

  it('rejects a body over 4,096 bytes', () => {
    // A single comment within 1,000 characters cannot exceed the cap (at most 3 bytes per
    // UTF-16 unit), so the size rule is shown on an oversized comment, which also fails length.
    const body = { reactionType: 'game', comment: '€'.repeat(1500), attempt };
    expect(bodyBytes(body)).toBeGreaterThan(4096);
    expect(reactionProblems(body)).toEqual(['comment', 'body']);
    const largestValid = { reactionType: 'game', comment: '€'.repeat(1000), attempt };
    expect(bodyBytes(largestValid)).toBeLessThanOrEqual(4096);
    expect(isValidReaction(largestValid)).toBe(true);
  });

  it('trims comments and drops empty ones', () => {
    expect(cleanComment('  hello  ')).toBe('hello');
    expect(cleanComment('   ')).toBeUndefined();
    expect(cleanComment(null)).toBeUndefined();
  });
});
