# Phase 3 — Driver API Integration Plan

> **Status:** ~92% complete. Core driver flows use remote APIs when `USE_REMOTE_API=true`.

**Goal:** Wire the driver role to real Goods Carrier APIs.

See also: [API Integration Status](../API_INTEGRATION_STATUS.md)

---

## PR map

| PR | Scope | Status |
|----|-------|--------|
| **3.1** | `DriverTripApiClient` + `TripApiMapper` + `RemoteDriverTripRepository` | ✅ Done |
| **3.2** | Wire `tripRepositoryProvider` + dashboard + express interest | ✅ Done |
| **3.3** | Driver profile page + avatar | ✅ Done |
| **3.4** | Trip detail interested customers + accept/reject | ✅ Done |
| **3.5** | Driver vehicles CRUD | ✅ Done |
| **3.6** | Driver saved addresses CRUD | ✅ Done |
| **3.7** | Payment history → earnings screen | ✅ Done |

---

## Wired endpoints

| Method | Path | App usage |
|--------|------|-----------|
| GET | `/api/driver/dashboard` | Driver home |
| POST | `/api/driver/shipments/{id}/requests` | Express interest |
| GET | `/api/driver/shipments/{id}` | Shipment detail |
| GET/POST/PUT | `/api/driver/trips` | My trips CRUD |
| GET | `/api/driver/trips/{id}` | Trip detail |
| GET | `/api/driver/trips/{id}/requests` | Interested customers |
| POST | `.../requests/{id}/accept\|reject` | Accept/reject |
| POST | `/api/driver/trips/{id}/cancel` | Cancel trip |
| GET/PUT | `/api/driver/profile` | Profile |
| POST | `/api/driver/profile/avatar` | Avatar |
| GET/POST/PUT/DELETE | `/api/driver/vehicles` | Vehicle management |
| GET | `/api/driver/vehicle-masters` | Add vehicle form |
| GET/POST/PUT/DELETE | `/api/driver/addresses` | Saved addresses |
| GET | `/api/driver/payment-history` | Earnings screen |

Contract: [`docs/api/driver-trips-contract.md`](./api/driver-trips-contract.md)

---

## Remaining (→ Phase 5)

| Feature | Notes |
|---------|-------|
| Subscription plans + Razorpay | Profile "Manage subscription" still coming soon |
| Driver reported shipments UI | `GET /api/driver/reported-shipments` | ✅ |
| Server-side dashboard filter polish | Pagination UI optional |

---

## Verification (`USE_REMOTE_API=true`)

1. Driver home → `GET /api/driver/dashboard`
2. Express interest → `POST /api/driver/shipments/{id}/requests` with `vehicle_id`
3. My Trips → `GET /api/driver/trips`
4. Publish / edit / cancel trip
5. Trip detail → requests + accept/reject
6. Profile edit + avatar refresh
7. Vehicles CRUD
8. Saved addresses CRUD
9. Earnings → `GET /api/driver/payment-history`
