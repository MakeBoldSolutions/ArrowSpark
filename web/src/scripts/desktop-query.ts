// Screens the game supports: a fine pointer (mouse or trackpad) and at least 960 × 540 CSS
// pixels (60rem × 33.75rem). DesktopOnlyNotice.astro and the Play page use the same boundary
// in CSS, as its exact complement.
export const DESKTOP_QUERY = '(pointer: fine) and (min-width: 60rem) and (min-height: 33.75rem)';
