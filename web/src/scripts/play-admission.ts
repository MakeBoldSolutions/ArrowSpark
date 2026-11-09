// Decides whether the Play page shows the game on this screen, from the viewport and the input
// capabilities, never from the user agent. The decision is pure; the page reads the browser into
// `Capabilities` and re-asks whenever the window changes.
//
// - Desktop: a fine pointer and a viewport of at least 960 × 540 CSS px (unchanged since the
//   first release).
// - Mobile web beta: a touch-capable screen in portrait (taller than wide) at least 360 × 640
//   CSS px, or in landscape at least 640 × 320 CSS px. Anything smaller asks for a larger screen.
// Touch and a fine pointer are independent: a device with both may qualify by either route.

export type PlayVerdict = 'play' | 'larger';

export interface Capabilities {
  width: number;
  height: number;
  finePointer: boolean;
  touch: boolean;
}

export const DESKTOP_MIN = { width: 960, height: 540 } as const;
export const PORTRAIT_MIN = { width: 360, height: 640 } as const;
export const TOUCH_MIN = { width: 640, height: 320 } as const;

export function decidePlay({ width, height, finePointer, touch }: Capabilities): PlayVerdict {
  if (finePointer && width >= DESKTOP_MIN.width && height >= DESKTOP_MIN.height) return 'play';
  if (touch) {
    const minimum = height > width ? PORTRAIT_MIN : TOUCH_MIN;
    if (width >= minimum.width && height >= minimum.height) return 'play';
  }
  return 'larger';
}

// An on-screen keyboard shrinks the visible viewport's height but never its width. Without this,
// opening the keyboard to type a name can push a portrait phone under the 640 px floor, which would
// hide the game and close the keyboard again. While a touch-first screen keeps the same width and
// only gets shorter, keep judging it by the height it had before; a rotation changes the width, and
// a taller viewport (keyboard closed) is taken as is.
export function holdForKeyboard(previous: Capabilities | null, next: Capabilities): Capabilities {
  if (!previous || !isTouchFirst(next) || !isTouchFirst(previous)) return next;
  if (decidePlay(previous) !== 'play') return next;
  const sameWidth = Math.abs(next.width - previous.width) <= 1;
  return sameWidth && next.height < previous.height ? { ...next, height: previous.height } : next;
}

// True when the visitor is on a touch screen without a fine pointer as the primary input, so
// the page can show the beta note and touch wording.
export function isTouchFirst({ finePointer, touch }: Pick<Capabilities, 'finePointer' | 'touch'>): boolean {
  return touch && !finePointer;
}

export function readCapabilities(win: Window = window): Capabilities {
  const visible = win.visualViewport;
  const useVisible = visible && Math.abs(visible.scale - 1) < 0.01;
  return {
    width: useVisible ? visible.width : win.innerWidth,
    height: useVisible ? visible.height : win.innerHeight,
    finePointer: win.matchMedia('(pointer: fine)').matches,
    touch: win.matchMedia('(any-pointer: coarse)').matches,
  };
}
