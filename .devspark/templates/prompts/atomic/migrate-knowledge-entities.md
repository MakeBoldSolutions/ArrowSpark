---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
id: migrate-knowledge-entities
name: migrate-knowledge-entities
audience: expert
exposed: false
category: legacy-command
description: Atomic shim for /devspark.migrate-knowledge-entities. Resolves to templates/commands/migrate-knowledge-entities.md.
inputs: []
outputs: []
legacy_command: migrate-knowledge-entities
---

## Outline

This atomic prompt is a backward-compatibility shim. Its execution is
delegated to the canonical command file at `templates/commands/migrate-knowledge-entities.md`.

The workflow runner resolves this id through the standard 3-tier override
chain (personal -> team -> stock) and forwards execution to the legacy
command body.
