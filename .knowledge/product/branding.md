---
id: product-branding
type: authoritative-reference
title: Product Identity and Branding Hierarchy
appliesTo:
  - project.godot
  - README.md
  - CLAUDE.md
  - ATTRIBUTION.md
  - scenes/menus/main_menu/main_menu_with_animations.tscn
  - scenes/credits/credits.tscn
  - scenes/opening/opening_with_logo.tscn
  - assets/brand/**
  - icon.png
  - web/src/components/site/SiteHeader.astro
  - web/src/components/site/SiteFooter.astro
---

# Product Identity and Branding Hierarchy

**ArrowSpark** is the game. **Make Bold Spark** is the product family / development
approach it belongs to. **Make Bold Solutions** is the creator.
`makeboldspark.com` is the public destination.

```
ArrowSpark            -> product/game
  -> Make Bold Spark   -> product family / development approach
    -> Make Bold Solutions -> creator
      -> makeboldspark.com -> public destination
```

`config/name` in `project.godot` is `ArrowSpark` and drives the OS window
title. The Main Menu hero shows the same name as a two-tone wordmark ("Arrow"
in cream, "Spark" in ember) above the tagline "A Make Bold Spark Game"; a
layout check asserts the wordmark still reads the configured name. Creator
credit and the public link live in Credits only (`ATTRIBUTION.md`, rendered by
`scenes/credits/credits.gd`), not on the Main Menu.

The Make Bold peak mark appears on application-level surfaces as the "mark
tile" (`assets/brand/mark_tile.svg`): the mark's paths unmodified, centred on a
cream rounded tile with clear space of at least the tallest peak's height, so
it is never recoloured or crowded even on ink. The tile is the opening splash
image (on ink), the Main Menu hero mark, and, as a 256 px raster, the
application icon (`icon.png`). No engine logo is shown at launch; Godot remains
credited under Tools in Credits, and Credits lists the mark under Brand.

## The playable showcase

`https://arrow.makeboldspark.com` is ArrowSpark's public showcase under the
Make Bold Spark domain: the place to play the game in a desktop browser and
read how it was built (`.knowledge/architecture/web-showcase.md`). Its header
carries the Make Bold peak mark, "ArrowSpark" and a spaced "MAKE BOLD SPARK"
family label, and its footer reads "A Make Bold Spark experiment". It uses
the Make Bold visual system unchanged; it is a Make Bold property that
contains a puzzle game, not a separate game brand.

## Presentation principle

Branding should establish identity at application-level surfaces (launch
splash, Main Menu, Credits, application icon) and then recede during gameplay. The puzzle HUD and Results keep
puzzle identity and metrics only — no product or company branding is added
there, so gameplay stays the showcase once it begins.
