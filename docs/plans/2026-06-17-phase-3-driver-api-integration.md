# Phase 3 — Driver API Integration Plan

> **Status:** PR 3.1 + 3.2 started (trip + dashboard foundation wired).

**Goal:** Wire the driver role to real Goods Carrier APIs for home feed, my trips, publish/edit/cancel, and express interest.

**Architecture:** Mirror Phase 2 — thin `Driver*ApiClient` classes, mappers, remote repos, `USE_REMOTE_API` toggle in `repository_providers.dart`.

---

## PR map

| PR | Scope | Status |
|----|-------|--------|
| **3.1** | `DriverTripApiClient` + `TripApiMapper` + `RemoteDriverTripRepository` | Done |
| **3.2** | Wire `tripRepositoryProvider` + `driverShipmentRequestsProvider` + tab refresh | Done |
| **3.3** | Driver profile page + avatar (mirror customer) | Not started |
| **3.4** | Trip detail interested customers + accept/reject requests | Not started |

---

## Wired endpoints (PR 3.1 / 3.2)

| Method | Path | App usage |
|--------|------|-----------|
| GET | `/api/driver/dashboard` | Driver home — active shipments |
| POST | `/api/driver/shipments/{id}/requests` | Express interest |
| GET | `/api/driver/trips` | My Trips list |
| POST | `/api/driver/trips` | Publish trip |
| GET | `/api/driver/trips/{id}` | Trip detail (client ready) |
| GET | `/api/driver/trips/{id}/edit` | Edit form prefill (client ready) |
| PUT | `/api/driver/trips/{id}` | Update trip |
| POST | `/api/driver/trips/{id}/cancel` | Cancel trip (`reason`, `other_reason`) |

Contract details: [`docs/api/driver-trips-contract.md`](./api/driver-trips-contract.md)

---

## Verification (`USE_REMOTE_API=true`)

1. Driver home tab → `GET /api/driver/dashboard`
2. Express interest → `POST /api/driver/shipments/{id}/requests`
3. My Trips tab → `GET /api/driver/trips`
4. Publish trip → `POST /api/driver/trips`
5. Cancel trip → `POST .../cancel` with reason body
6. Tab revisit refreshes list (no stale cancelled trips)
7. Driver profile edit → `GET /api/driver/profile` refresh + avatar upload on save
8. Trip detail → `GET /api/driver/trips/{id}` + `GET .../requests`
9. Accept/reject request → `POST .../requests/{id}/accept|reject`

---

## Completed (Phase 3.3 / 3.4)

- `getDriverProfile()` + `refreshDriverProfile()` on edit screen and profile tab
- `ProfileImageUtils.resolveForApiSubmission` on driver edit form
- `DriverTripDetail` / `DriverTripRequest` models + `TripApiMapper.parseDetail`
- Trip detail screen loads API data; accept/reject wired
- Local dummy repo returns sample interested customers for offline testing

---

## Deferred (Phase 3.5+)

- Driver vehicles CRUD
- Driver subscription / payments
- Server-side dashboard filters from driver home search sheet
