---
id: product-branding
type: authoritative-reference
title: Product Identity and Branding Hierarchy
appliesTo:
  - project.godot
  - ATTRIBUTION.md
  - scenes/menus/main_menu/main_menu_with_animations.tscn
  - scenes/credits/credits.tscn
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

`config/name` in `project.godot` is `ArrowSpark`; it drives both the OS window
title and the Main Menu title label live (see `config_name_label.gd` in the
Maaack template addon). The Main Menu subtitle carries the tagline
"A Make Bold Spark Game". Creator credit and the public link live in Credits
only (`ATTRIBUTION.md`, rendered by `scenes/credits/credits.gd`), not on the
Main Menu.

## Presentation principle

Branding should establish identity at application-level surfaces (Main Menu,
Credits) and then recede during gameplay. The puzzle HUD and Results keep
puzzle identity and metrics only — no product or company branding is added
there, so gameplay stays the showcase once it begins.
