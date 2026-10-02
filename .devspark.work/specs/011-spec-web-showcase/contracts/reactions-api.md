# Contract: ArrowSpark Reactions API (schemaVersion 1)

**Owner of implementation:** `MakeBoldSolutions/MakeBoldSpark.com`, as its own feature. **Consumer:** the ArrowSpark showcase (`web/`) in this repository.
**Status:** contract for Spec 011. Both sides implement and test against this document independently.
**Change policy:** any change to fields, enums, limits or responses is breaking. Bump `schemaVersion`, update both sides, and re-run analyze and critic.

## Endpoint

```
POST https://makeboldspark.com/api/public/arrowspark/reactions
Content-Type: application/json
```

- The base URL is a build-time setting in the consumer (`PUBLIC_REACTIONS_URL`). The path is fixed.
- Anonymous: no authentication, no cookie, no API key.
- Served only for ArrowSpark showcase reactions.

## Request body

Exactly one of the two shapes below. **Any property not listed is rejected.** Every answer property is optional, but `reactionType` is required. An empty answer set (`{"reactionType":"story"}`) is valid; the client simply doesn't send one.

### Game reaction

| Property | Type | Allowed values |
|---|---|---|
| `reactionType` | string | `"game"` (required) |
| `readStoryFirst` | string | `"yes"`, `"no"` |
| `finished` | string | `"finished"`, `"partway"`, `"notStarted"` |
| `satisfaction` | integer | 1, 2, 3, 4, 5 |
| `playAnother` | string | `"yes"`, `"maybe"`, `"no"` |
| `comment` | string | 1-1,000 characters (UTF-16 code units), after the client trims |
| `attempt` | object | optional; present only when the page holds a valid `attemptCompleted` event (see attempt-completed-event.md) |

`attempt` object. **All properties are required when `attempt` is present; no others are allowed:**

| Property | Type | Rule |
|---|---|---|
| `puzzleId` | string | 1-64 chars, `^[a-z0-9_-]+$` |
| `puzzleVersion` | string | 1-64 chars, `^[a-z0-9_-]+$` |
| `mistakes` | integer | 0-10,000 |
| `openMoveAssists` | integer | 0-10,000 |
| `score` | integer | 0-10,000 |
| `elapsedSeconds` | integer | 0-86,400 |

The endpoint validates format and range only. It holds no catalog and does not check that `puzzleId` or `puzzleVersion` are published values; that happens at analysis time.

### Story reaction

| Property | Type | Allowed values |
|---|---|---|
| `reactionType` | string | `"story"` (required) |
| `madeSense` | string | `"yes"`, `"partly"`, `"no"` |
| `changedView` | string | `"moreInterested"`, `"noChange"`, `"lessInterested"` |
| `wouldUse` | string | `"yes"`, `"maybe"`, `"no"` |
| `comment` | string | 1-1,000 characters |

A story reaction carries no `attempt`.

### Size

The whole request body may be at most **4,096 bytes**.

## Responses

| Status | When | Body |
|---|---|---|
| `202 Accepted` | stored | **none**, and no `Location` header. No identifier is ever returned |
| `400 Bad Request` | unknown property, missing or invalid `reactionType`, bad enum, out of range, bad pattern, over-length `comment`, or malformed JSON | RFC 7807 validation problem naming the failing property only; it never echoes submitted text |
| `413 Payload Too Large` | body over 4,096 bytes | none or a short problem |
| `415 Unsupported Media Type` | not `application/json` | none or a short problem |
| `429 Too Many Requests` | rate limit exceeded | short message |
| `5xx` | server failure | short problem; the consumer shows "not sent" |

Every response sets `Cache-Control: no-store`. No response sets a cookie.

## CORS

- A feature-specific policy allows the origin `https://arrow.makeboldspark.com` only, the method `POST` and the request header `Content-Type`.
- Development origins come from configuration and must be explicit HTTP(S) origins with no wildcards or paths, validated at startup the same way the existing `FamilyMemoryEndpoints` policy validates them.
- Preflight `OPTIONS` is answered by the policy.

## Rate limiting

- A fixed-window limiter partitioned by connection IP, using the API's existing in-memory `RateLimitPartition.GetFixedWindowLimiter` pattern. Suggested limit: 10 requests per minute per partition, with a queue of 0.
- The partition key lives only in limiter memory. It is **never written** to storage or logs.

## Logging

On failure, log the exception type and trace id only, following the existing feature-filter pattern. Never log the request body, `comment` text, IP address, user agent or referrer.

## Storage (implementer-side contract)

Each accepted request becomes exactly one insert-only record:

| Field | Value |
|---|---|
| `recordId` | random GUID generated server-side; internal only, never returned, never derived from the request |
| `schemaVersion` | `1` |
| `receivedUtc` | server UTC time **truncated to the minute** (ISO 8601, e.g. `2026-10-20T14:03Z`) |
| `reactionType` | `game` or `story` |
| `payload` | the validated request, re-serialized canonically (only contract properties, in contract order) |

**Never stored:** IP address, user agent, referrer, cookies, headers, or any visitor, session or device identifier.

**Mechanism:** a new insert-only table in the API's existing SQLite database (research R3). There is no read, update, delete, list or export endpoint; the owner reads the table directly for analysis.

## Conformance examples

Valid game reaction with attempt, giving `202`:

```json
{"reactionType":"game","readStoryFirst":"no","finished":"finished","satisfaction":4,"playAnother":"yes","comment":"The long arrow on the right was great.","attempt":{"puzzleId":"reference_knot","puzzleVersion":"g1-0123456789ab","mistakes":2,"openMoveAssists":2,"score":103,"elapsedSeconds":1260}}
```

Valid story reaction, giving `202`:

```json
{"reactionType":"story","madeSense":"partly","changedView":"moreInterested","wouldUse":"maybe"}
```

Invalid, giving `400`:
- `{"reactionType":"game","visitorId":"x"}`: unknown property.
- `{"reactionType":"game","satisfaction":6}`: out of range.
- `{"reactionType":"story","attempt":{...}}`: attempt not allowed on a story reaction.
- `{"reactionType":"game","attempt":{"puzzleId":"reference_knot"}}`: incomplete attempt.
- `{"reactionType":"poll"}`: unknown type.
- a `comment` of 1,001 characters.
