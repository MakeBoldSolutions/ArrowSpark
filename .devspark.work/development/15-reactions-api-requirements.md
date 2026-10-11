# Requirements: makeboldspark.com Reactions API for ArrowSpark

**Version:** 1.0 (contract `schemaVersion` 1)
**Date:** 2026-10-11
**Audience:** engineers implementing and operating the endpoint in `MakeBoldSolutions/MakeBoldSpark.com`.
**Consumer:** the ArrowSpark showcase at `https://arrow.makeboldspark.com` (source: `MakeBoldSolutions/ArrowSpark`, folder `web/`).
**Authoritative client code:** `web/src/scripts/reaction-schema.ts` (the contract, mirrored exactly) and `web/src/scripts/reaction-client.ts` (what the browser sends and how it reads responses).

Words: **MUST**, **MUST NOT**, **SHOULD** and **MAY** carry their usual requirement meanings. Each requirement has an id (`API-nn`) so tests and reviews can cite it.

---

## 1. Purpose and context

ArrowSpark is a puzzle game with a public showcase site. The site asks visitors for two kinds of optional, anonymous feedback: a short **game reaction** after playing, and a short **story reaction** after reading how the game was built. This API accepts those reactions and stores them so the owner can read them once, at the end of a fixed learning window.

The API exists to answer one question: **what did outside players think?** It does not exist to know who they are. The product promise made to visitors, in plain words on the Play page, is: no accounts, no cookies, no tracking, each submission an independent observation, comments anonymous and possibly quoted publicly.

The site is built to work with no API at all. The API therefore never gates gameplay or reading; it only receives optional submissions.

### 1.1 Scope

In scope:

- one public, anonymous `POST` endpoint with a strict request schema;
- validation, CORS, rate limiting, safe logging;
- insert-only storage, one JSON file per reaction;
- the owner's one-time export, then purge and disablement.

### 1.2 Out of scope (MUST NOT be built)

| Not built | Why |
|---|---|
| Accounts, sessions, API keys, any visitor, device or session identifier | Product promise and the consumer's privacy requirements |
| Any endpoint that reads, lists, updates, deletes or exports reactions | Storage is write-only from the web; the owner reads the files directly |
| A database (the API's existing one or a new one) | Decided: files only |
| Analytics, dashboards, aggregation, reporting | Analysis is done offline from the exported files |
| Deduplication or correlation of submissions | Each submission is an independent observation; there is nothing to correlate on |
| Content moderation or profanity filtering | Comments are stored as given and quoted as given, including negative ones |
| Extra fields beyond this contract | The contract may not grow without a version bump (section 9) |

### 1.3 Terms

| Term | Meaning |
|---|---|
| Reaction | One accepted submission: a game reaction or a story reaction |
| Attempt | The result of one completed play of a puzzle, attached to a game reaction when the player finished one in the current page visit |
| Learning window | The 14 days that start when the showcase is published and reachable; the API's useful life |
| Closeout | The owner's end-of-window report, after which data is purged and the endpoint is disabled |

---

## 2. Actors

| Actor | Interaction |
|---|---|
| Visitor's browser (the showcase page) | Sends `POST` requests; reads only the HTTP status |
| Owner | Copies the reaction files off the server once, at closeout; then confirms purge and disablement |
| API operator | Deploys, configures CORS origins, the storage path and the disable switch |
| Nobody else | There is no read path for anyone |

---

## 3. Endpoint

**API-01.** The API MUST expose exactly one route for this feature:

```
POST https://makeboldspark.com/api/public/arrowspark/reactions
Content-Type: application/json
```

**API-02.** The path is fixed. The consumer builds it as `<PUBLIC_REACTIONS_URL without trailing slashes>/api/public/arrowspark/reactions`, so the base URL may differ per environment but the path MUST NOT.

**API-03.** The endpoint MUST be anonymous: no authentication, no API key, no cookie. It MUST ignore any `Authorization` or `Cookie` header it receives and MUST NOT set a cookie on any response.

**API-04.** The endpoint MUST serve only ArrowSpark showcase reactions. It MUST NOT be reused by other features, so that it can be removed whole.

**API-05.** Methods other than `POST` and the CORS preflight `OPTIONS` MUST NOT be routed to a handler. The consumer treats `404` and `405` as "unavailable", so either is acceptable.

---

## 4. Request contract

The body is JSON, at most **4,096 bytes**. There are exactly two shapes, selected by `reactionType`.

**API-10.** `reactionType` is required and MUST be `"game"` or `"story"`. Anything else, missing or not a string, is invalid.

**API-11.** **Any property not listed for the selected shape is invalid**, at every level including inside `attempt`. Unknown properties MUST be rejected, never ignored or dropped. Duplicate property names in one object are invalid.

**API-12.** Every property except `reactionType` is optional. A body of just `{"reactionType":"story"}` is valid and MUST be accepted. (The consumer never sends an empty answer set, but the API does not need to enforce that.)

**API-13.** The top level of the body MUST be a JSON object. Arrays, scalars and `null` are invalid.

### 4.1 Game reaction (`reactionType: "game"`)

| Property | Type | Allowed values |
|---|---|---|
| `reactionType` | string | `"game"` (required) |
| `readStoryFirst` | string | `"yes"`, `"no"` |
| `finished` | string | `"finished"`, `"partway"`, `"notStarted"` |
| `satisfaction` | integer | `1`, `2`, `3`, `4`, `5` |
| `playAnother` | string | `"yes"`, `"maybe"`, `"no"` |
| `comment` | string | 1 to 1,000 characters |
| `attempt` | object | optional; see below |

`attempt` is present only when the player completed a puzzle during the current page visit. **When present, all six properties are required and no others are allowed:**

| Property | Type | Rule |
|---|---|---|
| `puzzleId` | string | 1 to 64 characters, matches `^[a-z0-9_-]+$` |
| `puzzleVersion` | string | 1 to 64 characters, matches `^[a-z0-9_-]+$` (example: `g1-0123456789ab`) |
| `mistakes` | integer | 0 to 10,000 |
| `openMoveAssists` | integer | 0 to 10,000 |
| `score` | integer | 0 to 10,000 |
| `elapsedSeconds` | integer | 0 to 86,400 (whole seconds) |

**API-14.** The API validates **format and range only**. It holds no puzzle catalog and MUST NOT check whether `puzzleId` or `puzzleVersion` name a real, published puzzle. That is done at analysis time.

**API-15.** The API MUST NOT recompute or cross-check the attempt (for example, that `score` agrees with `mistakes`). The values are the game's own report.

### 4.2 Story reaction (`reactionType: "story"`)

| Property | Type | Allowed values |
|---|---|---|
| `reactionType` | string | `"story"` (required) |
| `madeSense` | string | `"yes"`, `"partly"`, `"no"` |
| `changedView` | string | `"moreInterested"`, `"noChange"`, `"lessInterested"` |
| `wouldUse` | string | `"yes"`, `"maybe"`, `"no"` |
| `comment` | string | 1 to 1,000 characters |

**API-16.** A story reaction MUST NOT carry `attempt`. A story body with `attempt` is invalid.

### 4.3 Field rules

**API-17.** Enumerated strings are matched exactly and case-sensitively. No trimming, no aliases.

**API-18.** Integer fields MUST be JSON numbers with no fraction or exponent form and within range. Strings that look like numbers (`"4"`), booleans, `null`, fractions (`4.5`) and out-of-range values are invalid. `null` is invalid for every property: an absent answer is an omitted property.

**API-19.** `comment` length is counted in **UTF-16 code units** (the same unit as JavaScript's `String.length`) and MUST be between 1 and 1,000 inclusive. An empty `comment` is invalid. The consumer trims before sending and omits an empty comment; the API MUST NOT trim, rewrite or sanitize what it receives, and stores it exactly as validated.

**API-20.** The 4,096-byte limit applies to the request body as received (UTF-8 bytes). The API MUST enforce it **before** parsing the whole body, so an oversized request cannot cost parsing work.

**API-21.** The API MUST accept `Content-Type: application/json`, with or without a `charset=utf-8` parameter, and MUST reject any other media type. A body that is not valid UTF-8 or not valid JSON is invalid.

---

## 5. Responses

**API-30.** Responses are exactly these, and the consumer's behavior depends on the status code:

| Status | When | Body |
|---|---|---|
| `202 Accepted` | the reaction was validated and stored | **empty**; no `Location` header; no identifier of any kind |
| `400 Bad Request` | malformed JSON, non-object, unknown property, missing or invalid `reactionType`, bad enum, out of range, bad pattern, over-length or empty `comment`, incomplete `attempt`, `attempt` on a story, duplicate property | RFC 7807 problem naming the failing **property only** |
| `413 Payload Too Large` | body over 4,096 bytes | empty or a short problem |
| `415 Unsupported Media Type` | not `application/json` | empty or a short problem |
| `429 Too Many Requests` | rate limit exceeded | short message |
| `5xx` | server failure | short problem; no detail |

**API-31.** `202` MUST NOT be returned until the reaction is durably stored (the file has been renamed into place). A `202` is the only signal the consumer uses to delete its local copy, so a premature `202` loses the reaction.

**API-32.** Problem responses MUST NOT echo submitted text. They name the failing property (for example `satisfaction` or `attempt.score`) and nothing from the visitor's input.

**API-33.** Every response MUST include `Cache-Control: no-store`. No response sets a cookie.

**API-34.** Only the five statuses above are part of the contract. In particular, a successful store MUST be `202`, never `200` or `201`.

### 5.1 How the consumer reads each status

This is informative; the API's behavior must make this correct.

| Status | Consumer action |
|---|---|
| `202` | sent; local pending copy deleted |
| `400`, `413`, `415` | invalid; **dropped, never retried** |
| `404`, `405`, `429`, any `5xx`, network error, 8-second timeout, CORS or CSP block | unavailable; **kept in the visitor's pending queue and retried** on a later page load or submission |
| any other status (for example `410`) | also treated as unavailable and kept |

Consequences the API owner should know:

- **Duplicates are possible and acceptable.** If the API stores a reaction but the response is lost (timeout, dropped connection), the browser retries and the reaction is stored twice. There is no identifier to deduplicate on, by design. Analysis treats reactions as independent observations and tolerates occasional duplicates.
- **The client waits at most 8 seconds.** The handler SHOULD respond well inside that, normally in well under one second.
- **A `400` loses the reaction permanently.** The API MUST be at least as permissive as this contract for valid bodies, and never stricter. A body the client considers valid MUST NOT be rejected.

---

## 6. Cross-origin access (CORS)

The browser calls the API from a different origin, so the API must allow it.

**API-40.** A feature-specific CORS policy MUST allow:

- origin `https://arrow.makeboldspark.com` and no other production origin;
- method `POST` (plus the preflight `OPTIONS`);
- request header `Content-Type`.

**API-41.** The policy MUST NOT use a wildcard origin, MUST NOT allow credentials, and MUST NOT expose response headers beyond the defaults. The client sends `credentials: 'omit'`.

**API-42.** Development and preview origins MUST come from configuration, each an explicit HTTP(S) origin with no wildcard, path or trailing slash. The configuration MUST be validated at startup and refuse to start on a bad value, following the same validation the existing `FamilyMemoryEndpoints` policy uses.

**API-43.** Preflight `OPTIONS` MUST be answered by the policy with `204`, and SHOULD set a modest `Access-Control-Max-Age` (for example 600 seconds) so a visitor's submission is not delayed by a preflight each time.

**API-44.** A request from any other origin MUST receive no CORS headers. (Browsers then block it, which the consumer treats as "unavailable".)

---

## 7. Abuse resistance

The endpoint is public and unauthenticated, and the stored data is small. The protections are deliberately light, and none may weaken privacy.

**API-50.** A rate limit MUST apply. Required behavior: a fixed-window limiter partitioned by connection IP, using the API's existing in-memory `RateLimitPartition.GetFixedWindowLimiter` pattern. Suggested limit: **10 requests per minute per partition, queue length 0**. The consumer's pending queue holds at most 5 reactions and flushes once per page load, so a normal visitor never approaches this limit.

**API-51.** The limiter's partition key is the visitor's IP address. It MUST live **only in limiter memory**. It MUST NOT be written to storage, logs, headers, metrics labels or exception data, and MUST NOT be stored with the reaction.

**API-52.** When the limit is exceeded the API MUST return `429` and MUST NOT store anything.

**API-53.** Request size (4,096 bytes), strict schema and the comment length cap bound the cost of any one request. The API MUST NOT add per-visitor tracking, CAPTCHAs, cookies or fingerprinting to resist abuse. If abuse occurs, the response is to tighten the rate limit or disable the endpoint (section 10), not to identify visitors.

**API-54.** The storage directory MUST NOT be allowed to grow without bound. The operator SHOULD set a ceiling (for example a maximum file count or total size); when it is reached the endpoint SHOULD return `503`, which the consumer retries later. Suggested ceiling: far above any realistic volume for a 14-day window (for example 10,000 files), so it only triggers under abuse.

---

## 8. Storage

**API-60.** Each accepted request MUST become **exactly one insert-only record**, stored as **one JSON file named `<recordId>.json`**. There is no database and no shared append file.

**API-61.** The record contains these fields and nothing else:

| Field | Value |
|---|---|
| `recordId` | a random GUID generated server-side; equal to the file name; internal only; never returned; never derived from the request |
| `schemaVersion` | `1` |
| `receivedUtc` | server UTC time **truncated to the minute**, ISO 8601, for example `2026-10-20T14:03Z` |
| `reactionType` | `"game"` or `"story"` |
| `payload` | the validated request, re-serialized canonically: only contract properties, in the contract's order, with values exactly as received |

**API-62.** **Never stored, anywhere, in any form:** IP address, user agent, referrer, `Origin`, cookies, any request header, or any visitor, session or device identifier. The truncated timestamp is the only time data, and it is deliberately coarse.

**API-63.** Files MUST be written atomically: write the complete file under a temporary name in the **same directory**, then rename it into place. A reader never sees a partial file, and concurrent requests, including from overlapping server processes, never touch the same file. No locking is built or needed. Temporary files MUST use a name pattern that cannot be mistaken for a record (for example `.tmp-<random>`), and leftovers from a crash SHOULD be cleaned on startup.

**API-64.** The storage directory:

- is a dedicated directory on the API host's **persistent** storage, set by configuration;
- is **outside the web root**, outside any repository checkout, and never committed, synced or backed up into a repository;
- is writable by the API process and readable by the operator and owner only.

**API-65.** There is no read, update, delete, list or export endpoint, and the API process MUST NOT read these files back for any purpose (including startup checks beyond directory existence and the file-count ceiling in API-54).

**API-66.** Backups, if the host takes them, are subject to API-62 and API-80: they carry the same data and are deleted in the same purge.

---

## 9. Contract changes

**API-70.** Any change to fields, enums, limits, statuses or responses is **breaking**. It requires bumping `schemaVersion`, updating both sides and re-running review. The API MUST NOT accept extra fields "just in case" and MUST NOT add optional behaviors the consumer does not know about.

**API-71.** The API MAY accept more than one `schemaVersion` only if the request carries a version marker, which version 1 does not. Therefore a future version will use a different path or media type; that decision is made at that time.

---

## 10. Lifecycle: operate, close out, purge, disable

The endpoint has a short, planned life.

| Phase | When | State |
|---|---|---|
| Build and deploy | before or soon after the showcase is published | endpoint live; the site tolerates it being absent, so it may deploy later |
| Learning window | 14 days from publication | collecting reactions |
| Closeout | the end of the window | owner copies files to a private folder outside any repository, writes the report |
| Purge and disable | after the closeout report is written | all server files and all private copies deleted; endpoint disabled |

**API-80.** **Purge.** After the closeout report is written, every reaction file on the server (and every backup of it) and every private copy MUST be deleted, and the deletion date recorded in the closeout. The committed closeout keeps only counts and the anonymous quotes the on-page notice allows, never the raw files.

**API-81.** **Disable.** After purge the endpoint MUST be disabled: either removed, or returned as `410 Gone` behind a configuration switch. The switch MUST need no redeploy of code (a configuration change is enough) and MUST work independently of the storage path.

**API-82.** While disabled, the endpoint MUST NOT store anything and MUST NOT echo input.

**API-83.** The API SHOULD offer an operator-only way to stop accepting reactions early (the same switch as API-81) for use if abuse or a privacy concern appears during the window.

**Coordination with the site.** The site's forms stay visible until the site itself is rebuilt with `PUBLIC_FEEDBACK_CLOSED` set, which replaces them with a "Feedback for this showcase has closed" note. The client treats a `410` as "unavailable" and keeps the visitor's reaction queued. So: **disable the endpoint and publish the closed site build together**, in that order or at the same time, and not leave the endpoint disabled for long while the forms are still shown.

---

## 11. Non-functional requirements

### 11.1 Privacy and data protection

**API-90.** The guarantee covers the application and its data model: no login, no persistent visitor ID, no cross-session ID, no tracking cookie, no fingerprinting, no correlation between submissions, no retained network address in the stored record.

**API-91.** The guarantee does **not** claim that hosting and network infrastructure outside the application keeps no metadata of its own (for example transient platform request logs). The Play page's privacy note says so. The operator SHOULD minimize or disable access logging on this route where the platform allows it, and MUST document what the platform does keep.

**API-92.** Because free-text `comment` fields are quoted publicly with the visitor's agreement (a notice beside each text box says comments are anonymous and may be quoted), the API MUST NOT store comments anywhere other than the reaction file (no logs, no error trackers, no analytics).

### 11.2 Logging

**API-93.** On failure, log **only** the exception type and a trace id, following the existing feature-filter pattern. The API MUST NEVER log the request body, `comment` text, IP address, user agent, referrer, origin or any header.

**API-94.** Successful requests SHOULD NOT be logged individually. If a counter is useful, it MAY be an in-memory count of accepted reactions by `reactionType` that is not persisted with any request detail.

### 11.3 Performance and availability

**API-95.** The handler SHOULD complete in well under 1 second at the 95th percentile; the client abandons a request after 8 seconds.

**API-96.** Expected volume is tiny: a handful of reactions per day, bursts of at most a few per minute. No scaling, queueing or batching is required. The endpoint is not on the gameplay path, and its being down has no effect on play.

**API-97.** The endpoint MAY be unavailable at any time without data loss on the visitor side, because the browser keeps and retries unsent reactions. Planned downtime needs no coordination with the site.

### 11.4 Security

**API-98.** The endpoint MUST be served over HTTPS only.

**API-99.** The response MUST NOT reveal server version, stack traces, file paths or storage details. Standard security headers for an API route (for example `X-Content-Type-Options: nosniff`) SHOULD be set.

**API-100.** The comment is stored as inert text. The API MUST NOT interpret it (no HTML rendering, no templating, no evaluating) and MUST write it as a JSON string value, so it cannot alter the file's structure. File names come only from the generated GUID, never from request data, so a request cannot influence the path.

---

## 12. Configuration

| Setting | Purpose | Notes |
|---|---|---|
| Allowed origin(s) | CORS (API-40, 42) | production `https://arrow.makeboldspark.com`; preview and dev origins explicit, validated at startup |
| Storage directory | reaction files (API-64) | outside web root and repositories; must exist and be writable at startup or the endpoint fails closed |
| Rate limit (requests, window) | API-50 | default 10 per minute |
| File-count ceiling | API-54 | default 10,000 |
| Disabled switch | API-81 | when on, endpoint is removed or returns `410` |

**API-110.** If the storage directory is missing or not writable at startup or at request time, the endpoint MUST return `5xx` for the request (not `202`) and MUST NOT silently drop reactions.

---

## 13. Acceptance criteria and test plan

A requirement is met when its test passes. Tests run against the API alone, with no site.

### 13.1 Conformance cases

**Valid, expect `202` and exactly one new file:**

```json
{"reactionType":"game","readStoryFirst":"no","finished":"finished","satisfaction":4,"playAnother":"yes","comment":"The long arrow on the right was great.","attempt":{"puzzleId":"reference_knot","puzzleVersion":"g1-0123456789ab","mistakes":2,"openMoveAssists":2,"score":103,"elapsedSeconds":1260}}
```

```json
{"reactionType":"story","madeSense":"partly","changedView":"moreInterested","wouldUse":"maybe"}
```

```json
{"reactionType":"story"}
```

**Invalid, expect `400`, nothing stored, problem names only the property:**

| Body | Reason |
|---|---|
| `{"reactionType":"game","visitorId":"x"}` | unknown property |
| `{"reactionType":"game","satisfaction":6}` | out of range |
| `{"reactionType":"game","satisfaction":"4"}` | wrong type |
| `{"reactionType":"game","satisfaction":4.5}` | not an integer |
| `{"reactionType":"story","attempt":{...}}` | attempt not allowed on a story |
| `{"reactionType":"game","attempt":{"puzzleId":"reference_knot"}}` | incomplete attempt |
| `{"reactionType":"game","attempt":{...,"extra":1}}` | unknown attempt property |
| `{"reactionType":"game","attempt":{"puzzleId":"Reference Knot",...}}` | pattern violation |
| `{"reactionType":"poll"}` | unknown type |
| `{"reactionType":"game","finished":"Finished"}` | enum is case-sensitive |
| `{"reactionType":"game","comment":""}` | empty comment |
| `{"reactionType":"game","comment":"<1,001 characters>"}` | over-length comment |
| `{"reactionType":"game","comment":null}` | null is not an omission |
| `{"reactionType":"game"` | malformed JSON |
| `[]` and `"x"` and `null` | not an object |
| `{"reactionType":"game","reactionType":"story"}` | duplicate property |

**Boundaries, expect `202`:** `satisfaction` 1 and 5; `comment` of exactly 1 and exactly 1,000 UTF-16 units (include an emoji, which counts as 2); `puzzleId` of exactly 64 characters; `mistakes` 0 and 10,000; `elapsedSeconds` 86,400. **Just outside, expect `400`:** `satisfaction` 0; `mistakes` 10,001; `elapsedSeconds` 86,401; `puzzleId` of 65 characters; `comment` of 1,001 units.

**Size and media type:** a valid-shaped body of 4,097 bytes returns `413`; exactly 4,096 bytes returns `202` if otherwise valid; `Content-Type: text/plain` returns `415`; `application/json; charset=utf-8` returns `202`.

### 13.2 Behavior tests

| # | Test | Expected |
|---|---|---|
| T-01 | Send a valid reaction | `202`, empty body, no `Location`, no cookie, `Cache-Control: no-store` |
| T-02 | Inspect the stored file | one file `<guid>.json`; fields exactly as API-61; `receivedUtc` has no seconds; no IP, user agent, referrer or origin anywhere in the file |
| T-03 | Inspect the file's canonical form | properties in contract order; values byte-for-byte as validated; unknown properties absent |
| T-04 | Send 20 requests concurrently | all valid ones stored once each; no partial or corrupt file; no temp file left |
| T-05 | Kill the process mid-write | no record file is partial; temp leftovers cleaned on next start |
| T-06 | Exceed the rate limit from one IP | `429`; nothing stored; the IP appears in no file or log |
| T-07 | Make the storage directory read-only | `5xx`, never `202`; nothing silently dropped |
| T-08 | Preflight `OPTIONS` from `https://arrow.makeboldspark.com` | `204`, allows `POST` and `Content-Type`, no wildcard, no credentials |
| T-09 | Request from another origin | no CORS headers |
| T-10 | Inject an error (for example a forced failure after parsing) | the log has the exception type and trace id and **no** body, comment or IP |
| T-11 | Send a comment containing markup, quotes and newlines | stored as a JSON string, file stays valid JSON, nothing interpreted |
| T-12 | Turn the disabled switch on | endpoint returns `410` (or is gone) and stores nothing; switch off restores it |
| T-13 | Search the codebase and config for any route that reads or lists reaction files | none exists |
| T-14 | Search logs and storage after a test run | no body text, IP, user agent or referrer anywhere |

### 13.3 End-to-end check with the real site

After the endpoint is deployed, one manual check from `https://arrow.makeboldspark.com`:

1. Submit a story reaction and a game reaction (the latter after completing a puzzle, so `attempt` is present).
2. Confirm each shows as sent on the page and that exactly one file per submission appears on the server.
3. With the storage directory unwritable, submit again; the page must say "saved on this device, not sent yet", and after restoring storage, the next page load must send it, once.
4. Confirm the owner can copy the files, and that deleting them leaves no trace on the server.

---

## 14. Assumptions and open questions

| # | Item | Proposed answer |
|---|---|---|
| Q-1 | Does the endpoint already exist on makeboldspark.com? The site was built to work whether or not it does. | Confirm with the API owner; this document is the requirement either way |
| Q-2 | Exact rate-limit numbers | 10 per minute per IP, queue 0 (API-50); adjust if a shared network (an office or a school) proves to hit it |
| Q-3 | Should an empty-after-trim `comment` (whitespace only) be rejected? | The consumer trims first and omits it. The API validates 1 to 1,000 units as received and need not reject whitespace-only strings |
| Q-4 | `410 Gone` versus removing the route when disabled | `410` behind a switch is preferred, because it is reversible and tells the story to anyone who looks |
| Q-5 | File-count ceiling value | 10,000 (API-54); owner may change |
| Q-6 | Whether the platform's own request logs can be reduced for this route | Operator to confirm and document (API-91) |
| Q-7 | Backups | Operator to confirm whether the host backs up the storage directory; if so, API-66 applies |
| Q-8 | Owner's access method to the files | By direct file access on the host (copy to a private local folder). No API for this |

---

## 15. Traceability

| API requirements | Showcase requirement they serve |
|---|---|
| API-01 to API-05, API-10 to API-21 | Reaction contract (FR-026) |
| API-30 to API-34, section 5.1 | Consumer handling and the local pending queue (FR-032) |
| API-40 to API-44 | Cross-origin delivery from `arrow.makeboldspark.com` (FR-024, FR-026) |
| API-60 to API-66, API-80 to API-83 | Reaction storage and purge (FR-031), no new platform infrastructure (FR-033) |
| API-62, API-90 to API-94 | Anonymity and no correlation (FR-018), anonymous quoting notice (FR-017) |
| API-97, API-110 | Gameplay never degraded when feedback is unavailable (FR-018, FR-032) |
