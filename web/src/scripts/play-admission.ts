// Decides whether the Play page shows the game on this screen, from the viewport and the input
// capabilities, never from the user agent. The decision is pure; the page reads the browser into
// `Capabilities` and re-asks whenever the window changes.
//
// - Desktop: a fine pointer and a viewport of at least 960 × 540 CSS px (unchanged since the
//   first release).
// - Mobile web beta: a touch-capable screen in landscape, at least 640 × 320 CSS px. Portrait
//   asks the visitor to rotate; anything smaller asks for a larger screen.
// Touch and a fine pointer are independent: a device with both may qualify by either route.

export type PlayVerdict = 'play' | 'rotate' | 'larger';

export interface Capabilities {
  width: number;
  height: number;
  finePointer: boolean;
  touch: boolean;
}

export const DESKTOP_MIN = { width: 960, height: 540 } as const;
export const TOUCH_MIN = { width: 640, height: 320 } as const;

export function decidePlay({ width, height, finePointer, touch }: Capabilities): PlayVerdict {
  if (finePointer && width >= DESKTOP_MIN.width && height >= DESKTOP_MIN.height) return 'play';
  if (touch) {
    if (height > width) return 'rotate';
    if (width >= TOUCH_MIN.width && height >= TOUCH_MIN.height) return 'play';
  }
  return 'larger';
}

// True when the visitor is on a touch screen without a fine pointer as the primary input, so
// the page can show the beta note and touch wording.
export function isTouchFirst({ finePointer, touch }: Pick<Capabilities, 'finePointer' | 'touch'>): boolean {
  return touch && !finePointer;
}

export function readCapabilities(win: Window = window): Capabilities {
  return {
    width: win.innerWidth,
    height: win.innerHeight,
    finePointer: win.matchMedia('(pointer: fine)').matches,
    touch: win.matchMedia('(any-pointer: coarse)').matches,
  };
}
