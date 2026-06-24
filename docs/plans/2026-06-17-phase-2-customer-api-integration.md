# Phase 2 — Customer API Integration Plan

> **Status:** ~90% complete. Core customer flows use remote APIs when `USE_REMOTE_API=true`.

**Goal:** Wire the customer role to real Goods Carrier APIs.

See also: [API Integration Status](../API_INTEGRATION_STATUS.md)

---

## Completed

| Feature | API | Status |
|---------|-----|--------|
| Customer home feed | `GET /api/customer/dashboard` | ✅ |
| My shipments tab | `GET /api/customer/shipments` | ✅ |
| Post / edit shipment | `POST/PUT /api/customer/shipments` | ✅ |
| Cancel shipment | `POST .../cancel` | ✅ |
| Shipment detail + interested drivers | `GET .../shipments/{id}` | ✅ |
| Assign driver | `POST .../shipments/{id}/assign` | ✅ |
| Shipment masters | `GET /api/customer/shipment-masters` | ✅ |
| Saved addresses CRUD | `/api/customer/addresses` | ✅ |
| Profile create/edit + avatar | `/api/customer/profile` | ✅ |
| Report trip | `POST /api/reports` | ✅ |
| Support center | `GET /api/customer/support` | ✅ |
| Settings sync | `/api/customer/settings/*` | ✅ read + write |
| Customer trip detail (driver card) | Uses shipment detail API | ✅ |

---

## Remaining

| Feature | Notes |
|---------|-------|
| Live tracking | UI placeholder; no tracking API contract |
| Customer reported trips list | No list endpoint; shows local submissions after submit |
| Customer dashboard trip request CTA | Snackbar placeholder |
| Server-side price estimate | Client-side calculation in form |

---

## Verification checklist (`USE_REMOTE_API=true`)

| # | Test | Expected |
|---|------|----------|
| 1 | Customer home | API driver trips, not dummy |
| 2 | Pull to refresh | `GET /api/customer/dashboard` |
| 3 | Create shipment | `POST` success; appears in list |
| 4 | Edit shipment | `PUT` success |
| 5 | Cancel shipment | `POST .../cancel` |
| 6 | Shipment detail → interested drivers | API list |
| 7 | Assign driver | `POST .../assign`; status updates |
| 8 | Saved addresses CRUD | Full flow |
| 9 | Report trip | `POST /api/reports` |
| 10 | Support center | API FAQs/contact or fallback |
| 11 | Settings push/language | Backend sync |

---

## Architecture notes

- Remote toggle: `shipmentRepositoryProvider`, `customerAddressRepositoryProvider`
- Use `ApiExceptionMapper.userMessage(e)` in notifiers
- Use `FlowScreenAppBar` for screens with top bar
- Assign driver uses `apiResourceIdFor()` for numeric backend id
