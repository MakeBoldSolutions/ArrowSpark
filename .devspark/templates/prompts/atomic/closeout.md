---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
id: closeout
name: closeout
audience: expert
exposed: false
category: legacy-command
description: Atomic shim for /devspark.closeout. Resolves to templates/commands/closeout.md.
inputs: []
outputs: []
legacy_command: closeout
---

## Outline

This atomic prompt is a backward-compatibility shim. Its execution is
delegated to the canonical command file at `templates/commands/closeout.md`.

The workflow runner resolves this id through the standard 3-tier override
chain (personal -> team -> stock) and forwards execution to the legacy
command body.
