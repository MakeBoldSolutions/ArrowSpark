# Human Calibration Worksheet Template

Fill one copy of this block per experimental puzzle immediately after playing it to completion, into `calibration/records.md`. Target: seconds, not minutes. No telemetry, no account, no app — this is a plain markdown note (spec FR-022).

```markdown
## <puzzle_id> — <experiment name>

- score / mistakes / accuracy: <from Results panel>
- perceived challenge (1-5): <n>
- scanning load: low | medium | high
- sequence discoverability: obvious | required some tracing | required significant tracing
- aha / unlock moment: yes | no
- felt solved before completion: yes | no
- interesting because: <short free text>
- frustrating because (optional): <short free text>
```

Do not infer or backfill any of these fields from `PuzzleAnalyzer` output — they are only valid if recorded from an actual play session (spec FR-022, Edge Cases).
