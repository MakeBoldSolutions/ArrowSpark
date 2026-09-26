---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
id: workitem-review
name: workitem-review
audience: expert
exposed: false
category: legacy-command
description: Atomic shim for /devspark.workitem-review. Resolves to templates/commands/workitem-review.md.
inputs: []
outputs: []
legacy_command: workitem-review
---

## Outline

This atomic prompt is a backward-compatibility shim. Its execution is
delegated to the canonical command file at `templates/commands/workitem-review.md`.

The workflow runner resolves this id through the standard 3-tier override
chain (personal -> team -> stock) and forwards execution to the legacy
command body.
