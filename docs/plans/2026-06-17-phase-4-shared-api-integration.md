# Phase 4 — Shared Services API Integration

> **Status:** ~85% complete — core shared services wired; FCM deferred.

**Goal:** Replace dummy/shared local data with real APIs for notifications, reports, support, settings, and app config.

See also: [API Integration Status](../API_INTEGRATION_STATUS.md)

---

## PR map

| PR | Scope | Status |
|----|-------|--------|
| **4.1** | `NotificationsApiClient` + repo + tab wiring | ✅ Done |
| **4.2** | `ReportsApiClient` + report trip submit + driver reported list | ✅ Done |
| **4.3** | Customer support + settings sync (read + write) | ✅ Done |
| **4.4** | `GET /api/app/config` on splash | ✅ Done |
| **4.5** | FCM token registration + push delivery | ❌ Deferred |

---

## Wired endpoints

| Method | Path | App usage |
|--------|------|-----------|
| GET | `/api/notifications` | Customer & driver notifications tabs |
| POST | `/api/notifications/{id}/read` | Mark single read |
| POST | `/api/notifications/read-all` | Mark all read |
| DELETE | `/api/notifications/{id}` | Delete (client ready; UI not wired) |
| POST | `/api/reports` | Report trip submit |
| GET | `/api/reports/{id}` | Report status (client ready) |
| GET | `/api/driver/reported-shipments` | Driver reported shipments screen |
| GET | `/api/customer/support` | Support center FAQs + contact |
| GET | `/api/customer/settings` | Settings load on screen open |
| POST | `/api/customer/settings/push-notification` | Push toggle sync |
| POST | `/api/customer/settings/language` | Language sync |
| GET | `/api/app/config` | Splash bootstrap (`appConfigProvider`) |

---

## Deferred

- FCM push registration + delivery
- Global `/api/settings` (role-agnostic) — customer endpoints used for now
- Customer reported-trips list API (no backend list endpoint; local cache after submit)
- Notification delete UI

---

## Verification (`USE_REMOTE_API=true`)

1. Splash fetches `GET /api/app/config` (non-blocking)
2. Notifications tab loads from API; mark read persists
3. Report trip → `POST /api/reports` returns report id
4. Driver profile → Reported Shipments → `GET /api/driver/reported-shipments`
5. Support center shows API FAQs/contact when available
6. Settings screen loads remote push/language on open; toggles sync to backend
