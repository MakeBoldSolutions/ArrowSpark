---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
id: discover-knowledge
name: discover-knowledge
audience: expert
exposed: false
category: legacy-command
description: Atomic shim for /devspark.discover-knowledge. Resolves to templates/commands/discover-knowledge.md.
inputs: []
outputs: []
legacy_command: discover-knowledge
---

## Outline

This atomic prompt is a backward-compatibility shim. Its execution is
delegated to the canonical command file at `templates/commands/discover-knowledge.md`.

The workflow runner resolves this id through the standard 3-tier override
chain (personal -> team -> stock) and forwards execution to the legacy
command body.
