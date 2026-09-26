---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
id: workitem-create
name: workitem-create
audience: expert
exposed: false
category: legacy-command
description: Atomic shim for /devspark.workitem-create. Resolves to templates/commands/workitem-create.md.
inputs: []
outputs: []
legacy_command: workitem-create
---

## Outline

This atomic prompt is a backward-compatibility shim. Its execution is
delegated to the canonical command file at `templates/commands/workitem-create.md`.

The workflow runner resolves this id through the standard 3-tier override
chain (personal -> team -> stock) and forwards execution to the legacy
command body.
