# Contract: Play Page Admission

Replaces the desktop-only rule only after the matrix freeze. All numbers below are filled from the frozen Support Matrix, not from this document.

**Inputs** (page-side, transient, never stored or sent): viewport width/height in CSS px, orientation, touch available, fine pointer available.

**Outputs**: `play` (load and show the game), or `unsupported` with a reason (`rotate`, `larger-screen`).

Rules:
1. Desktop behavior is preserved: a fine pointer with a viewport at or above today's desktop floor (960 × 540 CSS px) is `play`.
2. Touch-capable viewports are `play` only when orientation is landscape and the viewport meets the frozen minimum for a matrix row. Hybrid devices are evaluated on their capabilities together, not on most recent input.
3. Portrait or narrow touch viewports → `unsupported/rotate`; undersized → `unsupported/larger-screen`. Message is concise, keeps the story link, and never presents the game as playable.
4. The decision is re-evaluated on resize and orientation change; an in-progress attempt is not destroyed when avoidable, and anything lost is stated.
5. The engine is downloaded only on `play`.
6. The decision is pure logic over its inputs, unit-testable with a table of cases (desktop, tablet landscape, phone landscape, phone portrait, undersized, hybrid).
7. No user-agent string storage, analytics or network call is involved.
