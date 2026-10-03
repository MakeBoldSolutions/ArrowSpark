// Shared publication rules for showcase content. Used by the content collection schemas
// (src/content.config.ts) and by scripts/check-content.mjs, so both enforce one definition.

const REPO = 'https://github\\.com/MakeBoldSolutions/ArrowSpark';

/** Temporary planning material must never be linked or named in published output. */
export const PLANNING_DIR = '.devspark.work';

/**
 * Permanent evidence links, in order of preference: durable knowledge or code/tests as
 * commit-pinned permalinks, a merged pull request, a commit, or an internal site path.
 */
export const EVIDENCE_URL_PATTERNS = [
  new RegExp(`^${REPO}/(blob|tree)/[0-9a-f]{40}/[^\\s#?]+(#L\\d+(-L\\d+)?)?$`),
  new RegExp(`^${REPO}/pull/\\d+$`),
  new RegExp(`^${REPO}/commit/[0-9a-f]{40}$`),
  /^\/[a-z0-9/_-]*(#[a-z0-9_-]+)?$/,
];

/** Returns a reason the URL is not a permanent evidence link, or null when it is. */
export function evidenceUrlProblem(url) {
  if (typeof url !== 'string' || url.length === 0) return 'missing URL';
  if (url.includes(PLANNING_DIR)) return `links to temporary planning material (${PLANNING_DIR})`;
  if (!EVIDENCE_URL_PATTERNS.some((pattern) => pattern.test(url))) {
    return 'not a permanent link (use a commit-pinned blob/tree, a merged PR, a commit, or an internal path)';
  }
  return null;
}

/** Author placeholders that must never ship. */
export const PLACEHOLDER_MARKERS = ['TODO(', '<!-- TODO', '[Mark', 'Mark:'];

/**
 * Words that must not appear on any surface a first-time visitor sees before playing.
 * Matched whole-word and case-insensitive; plural forms are included.
 */
export const PRE_PLAY_WORDS = [
  'neighborhood',
  'neighbourhood',
  'bridge arrow',
  'insight chain',
  'discovery beat',
  'major release',
  'meaningful density',
  'spaghetti',
  'zone',
];

export function prePlayWordPattern() {
  const alternatives = PRE_PLAY_WORDS.map((word) => word.replace(/ /g, '\\s+') + 's?');
  return new RegExp(`\\b(${alternatives.join('|')})\\b`, 'gi');
}
