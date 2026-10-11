---
title: "A Phone in Landscape"
part: 10
slug: a-phone-in-landscape
description: "Spec 012 set out to certify mobile web play with a real-device spike and ended as a public beta in under three hours, because the engine already did the hard part; a week later pinch and drag were rebuilt, and are still untested on a phone."
spoiler: false
status: draft
sources:
  - label: "Spec 012 planned"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/689e0889d9260258dd1b4652b0d74e496ed1d439
  - label: "Flag-gated spike mode and probe overlay"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/519709f9bafc77d39861438c2f83778d724d528a
  - label: "Android record corrected: Pixel 7 Pro, Edge Beta, not Chrome"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/01c3b13f4e3898fbf3374ae464fed6dd4e6ac42f
  - label: "Mobile web beta admission"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/8b3c260c745503935add2b5e57ac614e940d5ce0
  - label: "Mobile web beta pull request"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/6
  - label: "Modeless touch: tap acts, drag pans, pinch zooms"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/c140776f345afef2e9df27e69ae2cc7b667405c0
  - label: "Touch gestures in Godot, design and research"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/blob/c140776f345afef2e9df27e69ae2cc7b667405c0/.knowledge/reference/touch-gestures.md
  - label: "Modeless touch pull request"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/8
updated: 2026-10-11
---

Spec 012 was simple to state: a phone should be able to play ArrowSpark. Until it, the Play page showed phones a notice that the game needed a desktop browser. This part is about replacing that notice, and about the gap between a plan and what the evidence allowed.

## The plan

The spec was ambitious and sensible. Touch is a new input class, and the earlier chapters had said so more than once: touch input was left out of Spec 008 on purpose and deferred. So Spec 012 proposed a real-device spike first, with a probe overlay that reports touch events from an actual phone, then a support matrix that the owner and a reviewer would freeze, then touch controls sized to 44 by 44 CSS pixels, then verification on every row of the matrix. The task list had **61 tasks**.

The critic had already corrected the plan before any of it started. It found the plan wrong about two baseline facts: the game selects an arrow on press while the engine emulates mouse events from touch by default, so one tap could act at the wrong moment or twice; and nothing scales the game's content for a small screen today. The plan was amended, and the first commit of the work, the plan itself, landed at 12:23 on October 3rd.

## The spike

By 12:36 a flag-gated spike mode and a probe overlay were on the preview build. Over the next two hours the spike records filled in, one commit per observation, which is why the history for this part reads like a lab notebook. The real device was a **Google Pixel 7 Pro**. One of those commits is a correction: the first Android record said Chrome, and the browser was actually Edge Beta, so the record was corrected and then redone in Google Chrome 154.

What the owner saw on that phone was simple:

- The game loaded and started.
- **Tapping an arrow worked.** The engine already turns a touch into the existing click path, so selection needed no new input code.
- **Pinch to zoom did nothing.**
- **One-finger drag did not pan** unless Pan mode was on. With Pan on, it did.
- Full screen worked, and no page scroll or zoom leakage was seen on that phone.

No iPhone was available, and the record says so. An iPhone record was started but never completed, and the decision was written down as *Unverified, best guess, not claimed*.

A throwaway prototype of touch gestures was built on a separate spike branch. Simulated touches in a browser emulator looked fine. The first real-finger result on the real phone was: **pinch not working**. That is the useful part: emulation said yes, hardware said no.

## The decision

At this point the plan said to freeze a matrix, build a touch layer and verify across devices. The evidence said something else: the unmodified game already worked on a phone, for taps and the on-screen controls, and the only thing standing between a phone and the game was the page refusing to start it. The owner chose a **beta** over certification.

The change that shipped, at 14:51, was an admission decision on the Play page. It reads the viewport and the input capabilities, never the user agent. A fine pointer and at least 960 by 540 shows the game as before. A touch screen in landscape at least 640 by 320 shows it with a "Mobile Web Beta" note. Anything else gets a message: rotate the phone, or use a larger screen. A game that is loaded stays loaded when the phone is rotated. No game code changed. At 15:16, **2 hours and 53 minutes after the plan**, the pull request merged.

The close-out recorded this as a learning, not a failure: the engine already turns touch into the existing click path, so a usable beta needed an admission change, not a new input layer. Of the 61 planned tasks, most were not done, and that was recorded on purpose. The beta's limitations were written into the page, the pull request and the project's constitution, which was amended to 2.2.0 so that it allows a beta and forbids claiming a device that was not tested: pinch did not work, controls were about 17 CSS pixels tall on the Pixel, selection happened on touch-down, and only one real phone had been used.

## A week later: modeless touch

The owner had a direction for what came next: gestures should be modeless, like the games they like to play. Pinch zooms, one finger drags the view, a tap acts, and no Pan button is needed. On October 10th, `PuzzleBoard` was changed to do exactly that, and the pull request merged on October 11th at 11:52.

The design is written up with its research in the project's knowledge base. The parts worth repeating:

- **A tap acts on release**, and only if no second finger arrived and the finger moved under 32 pixels. Selecting on touch-down fires before a pinch can begin.
- **When one finger of a pinch lifts first**, the other is ignored until every finger is up, so it cannot fire a stray pan or selection.
- **The board drops the mouse events the engine synthesizes from touch**, so a touch never selects twice.
- **The page also has to let go.** Chrome combines the `touch-action` setting across an iframe boundary, so the game frame on the page needed `touch-action: none` as well as the game's own shell. The leading explanation for why pinch failed on the Pixel is that the page claimed the two-finger gesture as a page zoom. That is a hypothesis.

## What this part does not claim

- **The modeless touch change has not been tried on a real phone.** The headless checks synthesize touches, and the research itself notes that browser emulation zoomed under simulated multi-touch while the real phone did not.
- **It does not claim iPhone support.** Safari on an iPhone is let in by the same capability rule and has never been run.
- **It does not claim touch is comfortable.** Controls are still small, and in-game help still describes the mouse. Both are deferred.
- **It evidences one phone**, a Pixel 7 Pro, and one tester.

## What it taught us

1. **Real hardware answers what an emulator cannot.** A simulated pinch worked. A real one did not.
2. **A spike can show the plan was larger than the problem.** Sixty-one tasks gave way to a small admission change because the spike found what was already working.
3. **A beta is a legitimate release if the limits are in the page, the PR and the constitution.** The page says what it is.
4. **Writing the unverified list down is the habit.** The next step is the same as the last one in this series: put it in front of a person and watch.
