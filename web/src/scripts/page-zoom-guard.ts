// Keeps browser page zoom from triggering while the pointer is over the game frame's own
// chrome (its border and title bar). Events inside the game iframe never reach this page; the
// game's shell guards those itself. Everywhere else on the page, zoom works as usual.

export function guardFrameChrome(frame: HTMLElement): () => void {
  const onWheel = (event: WheelEvent) => {
    if (event.ctrlKey) event.preventDefault();
  };
  const onGesture = (event: Event) => event.preventDefault();
  frame.addEventListener('wheel', onWheel, { passive: false });
  const gestures = ['gesturestart', 'gesturechange', 'gestureend'];
  for (const name of gestures) frame.addEventListener(name, onGesture);
  return () => {
    frame.removeEventListener('wheel', onWheel);
    for (const name of gestures) frame.removeEventListener(name, onGesture);
  };
}
