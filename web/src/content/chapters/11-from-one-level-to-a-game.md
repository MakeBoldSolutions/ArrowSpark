---
title: "From One Level to a Game"
part: 11
slug: from-one-level-to-a-game
description: "Six changes in three weeks turned one hard level into something closer to a game: a way up to the big board, a cleanup proven to change nothing, a finished look, portrait play, and levels as data with a generator that arrived before the players did."
spoiler: false
status: published
sources:
  - label: "Progression levels and the world canvas pull request"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/9
  - label: "Progression pack closeout, with the real-phone touch result"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/776ae49719f8af1b8ee4f387c4f57b24009cc50d
  - label: "Every catalog entry pinned before the cleanup"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/a25849f8ef18b5bdc296b477f04eb441aba3e4f9
  - label: "Codebase consolidation pull request"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/10
  - label: "Game UI pull request"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/13
  - label: "Portrait play and compact controls"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/044bc8ff462399121a46c3179e6881144fa1fb0c
  - label: "Portrait play pull request"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/14
  - label: "Levels as data and a seeded generator"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/b36c041b032afbc3fc80651684a51996a0de540f
  - label: "Level pack pull request"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/16
  - label: "Progression design record"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/blob/1a1ee67a317c5cc1902ba30f8e0af189ccdc5f05/.knowledge/reference/progression-design-learning.md
updated: 2026-11-08
---

At the end of [Part 10](/story/a-phone-in-landscape/) the game had a website, a phone beta and a problem that had nothing to do with either. A new player could finish a handful of small tutorial boards and then meet a 115-arrow knot with nothing in between. This part covers the six changes that followed, between October 11th and October 31st.

## A way up to the big board

Spec 013 had two jobs, and both came from playing.

The first was the camera. I had been playing other arrow games and wanted the board to sit inside a larger world, so that any point on it, corners included, could be brought to the middle of the screen. Departing arrows also stopped being clipped at the board's edge. They now travel a fixed margin past it before they disappear.

The second was content. Eight new levels sit in front of the Reference Knot, and Play now starts at the first of them. Their arrow counts run 9, 15, 14, 17, 23, 30, 68 and 93, then 115. Each level has one stated challenge, and every first-draft description of those challenges was checked against what the analyzer measured. Several overstated the structure and were rewritten.

One detail is worth being plain about. The boards are hand-curated, but they were found by a seeded offline search that places arrows in reverse solve order, so each board is solvable by construction. The solver then confirms it. That search could not reach what the Reference Knot does, which is six playable arrows out of 115 at 92 percent fill.

I played all of them on a desktop and on the Pixel, and the note I left was "great game play … right level of difficulty for the new ones, nice progression." That note covers the eight levels together. It is not per level.

The same closeout settled a question from Part 10. On the real Pixel 7 Pro in Chrome, pinch zoom and one-finger drag worked, and every level could be played by tapping. The emulator had said yes before the phone said no; this time the phone said yes.

The record also shows where the process got loose. Eight per-level tasks were closed on one aggregate comment. The agent recorded my silence as acceptance of an exit margin. Review caught an accepted limitation with no actual acceptor. Those are in the [Beck retrospective](/devspark/beck-retrospective/), published the day this spec merged, and it is less kind to this project than this chapter is.

## A cleanup that had to prove nothing happened

Spec 014 was the first spec in the project whose goal was that players would see no difference. Thirteen specs had mostly added code. Some rules were defined in several places, some boards had no safety net, and template examples suggested systems the game does not have.

The interesting part is how "no difference" was tested. Before any refactor, a commit pinned the identity and geometry of all 30 catalog entries. A throwaway probe then captured every entry's validity, solution order, Open Move trail and analyzer report. After the work the same probe was run again, and the two outputs of 195,273 bytes each were identical. One coordinate was also changed on purpose to confirm that the gate would fail. It did.

The branch came to 95 lines added and 861 removed. The bigger ideas, level data files and a generator among them, were written down as separate future work. A quick follow-up (PR #11) fixed three leftovers, one of which was a New Game tooltip still promising the Reference Knot.

## Looking like a game

Spec 016 had an unusual requirement for a polish pass: *no functional change to game play or behavior.* Everything around the puzzle was still wearing the engine's default grey. Launch, Main Menu, Level Select, Options, Pause and Credits now share one Make Bold look, scale with the screen, and have restrained motion and sound. The regression gates passed with no changed expectations, which is how "the game did not change" stayed a tested claim rather than a promise.

I signed it off on desktop in Chrome, Firefox and two other Chromium-based browsers. I also chose to take the phone check out of the spec rather than hold it up. That check became a written future-work item, and it stayed open until November 8th.

## Upright on a phone

Spec 017 made portrait play real. Until then, a phone held upright got a message asking you to turn it. Portrait now plays, status at the top and a three-button strip (Menu, Open Move, Fit) at the bottom within thumb reach. The separate Zoom In, Zoom Out and Pan buttons went away, because tap, drag and pinch had made them duplicates that cost puzzle space. The board has to get at least 75 percent of the usable area, and a layout check measures that.

The evidence here is the kind this series keeps trying to be honest about. Automated checks, real-export rendering and desktop browsers all ran before merge. The real-phone walk was marked as a post-deploy obligation and sat open for three weeks. On November 8th I recorded it: I had played the game on my Pixel both upright and sideways, and it held up. That is one phone and one tester.

## Levels as data, and a generator that came early

Until Spec 018, level geometry lived in builder functions inside the GDScript catalog. Now every level is a record in a committed JSON pack, with an id, a title, a pinned content version and its provenance. All 30 levels moved, and the before and after snapshots of their ids, order, versions and structure were identical.

The same spec added a seeded generator and a one-command tool that builds a pack from a recipe. It uses the game's own rules, solver and analyzer, so there is no second rules engine. The same recipe and seed rebuild the same file byte for byte, checked across independent processes. Its output so far is four sample levels, shown in Level Select as Generated Levels and described there as an untuned first sample.

This needs saying directly, because of what earlier chapters said. [Part 5](/story/playtest-beat-the-dashboard/) said not to build the generator yet, and the stated order was human evidence first, then a generator that encodes what people enjoyed. That order was not followed. The human evidence is still thin, and the generator exists anyway.

What limits the damage is how little the generator is allowed to claim. It is developer tooling and does not run in the game. It can hit a range of structural measurements and prove a board is solvable. Part 5 is exactly the story of those measurements failing to predict whether a puzzle is any good. So the generator makes more boards cheaper. It doesn't know which ones are worth playing.

## What this part does not claim

- **It does not claim portrait play works beyond one phone.** My Pixel, in both orientations, is the whole of the device evidence.
- **It does not claim anything about iPhone.** Safari on an iPhone is let in by the same capability rule and has never been run.
- **It does not claim the eight levels are good for anyone else.** The evidence is the designer's aggregate opinion.
- **It does not claim the generated levels are good.** They are valid and solvable, and that is all that has been shown.

## What it taught us

1. **A hard level needs a way up to it.** The Reference Knot did not get easier; it got an approach.
2. **"No behavior change" is a claim you can test.** Pin it first, compare afterwards, then break it on purpose to prove the check can fail.
3. **A deferred check needs a date, or it just stays deferred.** The real-phone walk was carried across two specs before it was recorded.
4. **A principle you depart from should be named.** The generator came early. Saying so costs a paragraph, and pretending otherwise would cost the rest of the series.

The game is bigger than the level I said in Part 8 I'd happily hand to a friend. Whether it's better is the same question it was then, and the next part is where I ask it.
