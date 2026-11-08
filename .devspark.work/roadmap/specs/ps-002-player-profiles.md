---
id: ps-002
title: Online player accounts and sign-in
status: proposed
order: 70
depends_on: [ps-001]
delivery: []
---

# ps-002: Online player accounts and sign-in

## Outcome

A player can create an online account and sign in from the game, and the API stores that account
securely. Signing in stays optional, and the game remains fully playable with only a local profile.

## Current Reality

The only player-facing endpoint is anonymous and write-only, and its requirements forbid accounts and
identifiers (`.devspark.work/development/15-reactions-api-requirements.md`). The API in
`MakeBoldSolutions/MakeBoldSpark.com` has authentication for admin routes and a database, but no
player accounts. The game never calls an API; the web page does. The live security policy already
allows connections to `makeboldspark.com`. The site has no privacy policy page, only a short notice
on the Play page.

## Scope and Independence

In scope: player account creation, sign-in and sign-out, a basic profile, account deletion, the game
and site experience for these, and a published privacy policy. Everything public that says otherwise
is corrected in the same delivery: the Play page's "No account, no tracking and no visitor ID", the
site's meta description, and the gameplay contract.

Out of scope: syncing scores (ps-003), activity tracking (ps-004), leaderboards, and changing the
anonymous reactions flow, which stays anonymous.

Standalone boundary: with later items canceled, players have a working optional profile, and the
game and site state truthfully what is collected. Delivery spans two repositories. The API may ship
first and inactive, provided the capability is complete.

## Future Health

Keep the player identity separate from the reaction data, so anonymous reactions cannot be linked to
profiles. The design must work for the Web build first and not rule out the desktop build. Keep the
game and API talking through a small, versioned contract.

## Dependencies and Decisions

Deliberately later: the owner chose local profiles first to delay the authentication provider
decision. Depends on ps-001 for the local profile an account would extend. This changes a public
promise, so the owner needs to decide these before
delivery: how players sign in (email and password, email link, or a social or Microsoft/Google
login); what a profile holds; what minimum age applies; how long data is kept; and whether the game
calls the API directly or goes through the web page. Personal data brings legal duties that depend
on where players live, so the privacy terms deserve a proper review and not only an engineering one.

## Completion Expectations

A player can create, use and delete a profile on the live site. Signed-out play is unchanged. A
player's data cannot be read by another player. No public page still claims there are no accounts.
Regression gates, API tests and browser and phone smoke tests pass.
