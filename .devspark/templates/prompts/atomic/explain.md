---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
id: explain
name: explain
audience: expert
exposed: false
category: legacy-command
description: Atomic shim for /devspark.explain. Resolves to templates/commands/explain.md.
inputs: []
outputs: []
legacy_command: explain
---

## Outline

This atomic prompt is a backward-compatibility shim. Its execution is
delegated to the canonical command file at `templates/commands/explain.md`.

The workflow runner resolves this id through the standard 3-tier override
chain (personal -> team -> stock) and forwards execution to the legacy
command body.
