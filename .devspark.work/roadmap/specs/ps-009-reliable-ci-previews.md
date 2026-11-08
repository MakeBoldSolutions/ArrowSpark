---
id: ps-009
title: Reliable CI and PR previews
status: proposed
order: 15
depends_on: []
delivery: []
---

# ps-009: Reliable CI and PR previews

## Outcome

A failed CI run means something is wrong, and every pull request gets a working preview of the site.

## Current Reality

The Godot `--import` step has crashed with signal 11 on at least three occasions and passed on re-run
with no code change. PR preview uploads fail because the Azure Static Web App has reached its limit of
staging environments, which has forced merging over a red check on the last two pull requests.

## Scope and Independence

In scope: making import reliable or making the known crash retry safely without hiding real failures,
and clearing stale staging environments with a way to keep them from building up.

Out of scope: changing what the gates test.

Standalone boundary: with later items canceled, CI is trustworthy on its own.

## Future Health

Profile and level work will add more gates and longer runs, so a false red becomes more expensive. A
retry must only cover the identified crash, so a real import failure still fails the run.

## Dependencies and Decisions

No delivered prerequisites. Clearing the staging environments needs the owner's Azure access. Check
why previews from closed pull requests are not being removed before adding anything new.

## Completion Expectations

A real import failure still fails the run and the known crash no longer does. New pull requests get a
working preview, and closing one removes it.
