# Handoff to the MakeBoldSpark API project (reactions endpoint)

This is a handoff only. Spec 011 builds no API code. The endpoint, its validation, CORS, rate limiting, storage and purge are owned and verified by a separate API project spec in `MakeBoldSolutions/MakeBoldSpark.com`.

## Contract

- `POST {base}/api/public/arrowspark/reactions`, `Content-Type: application/json`, anonymous.
- Exact request schema, responses, CORS, rate limiting, logging and conformance examples: this bundle's `contracts/reactions-api.md` (schemaVersion 1). Any change is breaking: bump `schemaVersion` and update both sides.
- **Agreed base URL:** `https://makeboldspark.com` (owner answer, 2026-10-02). The site reads it at build time from the repository variable `PUBLIC_REACTIONS_URL`; the production CSP's `connect-src` is generated from the same value.
- Allowed browser origin: `https://arrow.makeboldspark.com` only (plus explicit development origins from configuration, no wildcards).

## What the client does (already built and tested in this repository)

- Sends only contract-valid bodies (validated client-side), with `credentials: 'omit'`, no cookies, no custom headers beyond `Content-Type`, an 8 s timeout.
- `202` = sent. `400`/`413`/`415` = dropped, never retried. Everything else (`404`, `405`, `429`, `5xx`, network error, timeout, CORS or CSP block) = kept in the visitor's local pending queue (at most 5, 7-day expiry) and retried once per page load or before a new submission. So the API may deploy after the site; reactions saved before then arrive when it does.
- Duplicates are possible in principle (each reaction is an independent observation; there is no de-duplication by design).

## Privacy requirements the API must meet (FR-018)

- No login or account; no persistent visitor id, cookie, tracking or advertising id; no fingerprinting.
- Never store IP address, user agent, referrer, headers or cookies with a reaction; source information used for rate limiting stays in limiter memory only and is never logged.
- Each submission is an independent observation; never correlate submissions.

## Server-side bounds (FR-026 part B)

- Reject unknown fields, missing or unknown `reactionType`, values outside the sets or ranges, comments over 1,000 characters, bodies over 4,096 bytes, non-JSON media types. Rejected requests store nothing.
- `202` with no body and no record id; RFC 7807 problem naming the failing property only (never echoing text) on `400`; `413`, `415`, `429` where they apply; `Cache-Control: no-store` on every response; never set a cookie.
- Free text is untrusted plain text; escape wherever it is displayed.
- Failures logged by exception type and trace id only.

## Storage and purge (FR-031)

- One JSON file per accepted reaction, `<recordId>.json`, in a dedicated directory on the API host's persistent storage, outside any repository and any web-served path. Written under a temporary name in the same directory, then renamed; no locking, no database, no shared append file.
- Record fields only: `schemaVersion`, `receivedUtc` (truncated to the minute), `recordId` (random, server-generated, never returned or derived from request data), and the validated reaction fields.
- No read, list, export or dashboard endpoint. For the closeout the owner copies the files to a private folder outside any repository.
- After the closeout report is written: delete every reaction file and every private copy, record the date, then disable the endpoint (remove it, or return `410 Gone` behind a configuration switch). The site is rebuilt with `PUBLIC_FEEDBACK_CLOSED=true` at the same time.
