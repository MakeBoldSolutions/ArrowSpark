import { describe, expect, it } from 'vitest';
import { decidePlay, isTouchFirst, readCapabilities, type Capabilities } from '../src/scripts/play-admission';

const desktop = (over: Partial<Capabilities> = {}): Capabilities => ({
  width: 1440, height: 900, finePointer: true, touch: false, ...over,
});
const phone = (over: Partial<Capabilities> = {}): Capabilities => ({
  width: 850, height: 411, finePointer: false, touch: true, ...over,
});

describe('decidePlay', () => {
  it('keeps the desktop boundary: fine pointer and at least 960 x 540', () => {
    expect(decidePlay(desktop())).toBe('play');
    expect(decidePlay(desktop({ width: 960, height: 540 }))).toBe('play');
    expect(decidePlay(desktop({ width: 959, height: 900 }))).toBe('larger');
    expect(decidePlay(desktop({ width: 1440, height: 539 }))).toBe('larger');
  });

  it('plays on a touch phone or tablet in landscape', () => {
    expect(decidePlay(phone())).toBe('play');
    expect(decidePlay(phone({ width: 915, height: 412 }))).toBe('play');
    expect(decidePlay(phone({ width: 1180, height: 820 }))).toBe('play');
    expect(decidePlay(phone({ width: 640, height: 320 }))).toBe('play');
  });

  it('asks a touch device in portrait to rotate', () => {
    expect(decidePlay(phone({ width: 411, height: 891 }))).toBe('rotate');
    expect(decidePlay(phone({ width: 820, height: 1180 }))).toBe('rotate');
  });

  it('asks a too-small touch landscape screen for a larger one', () => {
    expect(decidePlay(phone({ width: 639, height: 360 }))).toBe('larger');
    expect(decidePlay(phone({ width: 700, height: 319 }))).toBe('larger');
  });

  it('asks a small non-touch window for a larger screen', () => {
    expect(decidePlay({ width: 800, height: 500, finePointer: true, touch: false })).toBe('larger');
    expect(decidePlay({ width: 1440, height: 900, finePointer: false, touch: false })).toBe('larger');
  });

  it('lets a hybrid device qualify by either route, without switching mode', () => {
    const hybrid = (width: number, height: number): Capabilities => ({ width, height, finePointer: true, touch: true });
    expect(decidePlay(hybrid(1440, 900))).toBe('play');
    expect(decidePlay(hybrid(800, 450))).toBe('play'); // too small for the desktop route, fine for touch landscape
    expect(decidePlay(hybrid(450, 800))).toBe('rotate');
    expect(decidePlay(hybrid(600, 300))).toBe('larger');
  });
});

describe('isTouchFirst', () => {
  it('is true only for touch without a fine pointer', () => {
    expect(isTouchFirst(phone())).toBe(true);
    expect(isTouchFirst(desktop())).toBe(false);
    expect(isTouchFirst({ finePointer: true, touch: true })).toBe(false);
  });
});

describe('readCapabilities', () => {
  it('reads size and the two input queries from the window', () => {
    const win = {
      innerWidth: 850,
      innerHeight: 411,
      matchMedia: (q: string) => ({ matches: q === '(any-pointer: coarse)' }),
    } as unknown as Window;
    expect(readCapabilities(win)).toEqual({ width: 850, height: 411, finePointer: false, touch: true });
  });
});
