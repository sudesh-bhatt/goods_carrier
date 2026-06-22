# Postman ↔ App Code Sync

**Workspace:** [Goods Carriers API](https://jaydip-3661044.postman.co/workspace/c0dfbc91-83c1-455b-b0c1-2e61eb04bcd8)  
**Workspace ID:** `c0dfbc91-83c1-455b-b0c1-2e61eb04bcd8`  
**Collection:** Goods Carrier API (80 endpoints)  
**Base URL:** `https://goodscarrier.ajonetech.com`

## Rule

When the Postman collection changes, update the app in this order:

1. **`lib/core/network/api_constants.dart`** — paths and helpers
2. **`lib/shared/data/api/<module>/`** — request/response clients
3. **`lib/shared/data/api/<module>/*_mapper.dart`** — field name mapping
4. **`lib/shared/domain/entities/`** — `fromJson` / enums if response shape changed
5. **`docs/plans/`** — phase plan if scope shifts

## Source of truth map

| Postman folder | App files |
|----------------|-----------|
| Auth | `api/auth/auth_api_client.dart` |
| Onboarding | `api/onboarding/onboarding_api_client.dart` |
| Customer → Profile | `api/auth/auth_api_client.dart` (Phase 1; may split later) |
| Customer → Shipments | `api/customer/customer_shipment_api_client.dart`, `shipment_api_mapper.dart` |
| Customer → Addresses | *not wired* (Phase 4) |
| Customer → Dashboard | *not wired* |
| Driver → Trips | `api/driver/driver_trip_api_client.dart`, `trip_api_mapper.dart` |
| Driver → Dashboard / Shipments | `api/driver/driver_dashboard_api_client.dart` |
| Driver → Profile | *Phase 3.3* |
| Notifications | *Phase 4* |

## Customer shipments (Phase 2 — wired)

| Method | Postman path | `ApiConstants` |
|--------|--------------|----------------|
| GET | `/api/customer/shipments` | `customerShipments` |
| POST | `/api/customer/shipments` | `customerShipments` |
| GET | `/api/customer/shipments/{id}` | `customerShipment(id)` |
| GET | `/api/customer/shipments/{id}/edit` | `customerShipmentEdit(id)` |
| PUT | `/api/customer/shipments/{id}` | `customerShipment(id)` |
| POST | `/api/customer/shipments/{id}/cancel` | `cancelShipment(id)` |
| GET | `/api/customer/shipment-masters` | `customerShipmentMasters` |

**Not in collection (do not invent):** `PATCH/POST .../assign` — driver assignment endpoint TBD.

## MCP setup (required for live sync)

Postman MCP currently returns `403 Invalid API Key`. To enable live collection pull:

1. In Cursor, run Postman MCP **setup** and add a valid Postman API key
2. Confirm access to workspace `c0dfbc91-83c1-455b-b0c1-2e61eb04bcd8`
3. Re-run `searchPostmanElements` for changed folders before coding

Until MCP works, use the collection export or device API logs as the contract source.

## Request body — create/update shipment

Mapped in `ShipmentApiMapper.toRequestBody()` (Postman **Create Customer Shipment**):

```json
{
  "from_address": "...",
  "from_city": "...",
  "from_latitude": 23.02,
  "from_longitude": 72.57,
  "to_address": "...",
  "to_city": "...",
  "to_latitude": 22.30,
  "to_longitude": 70.80,
  "pickup_date": "2026-06-22",
  "pickup_time": "08:00",
  "goods_type_id": 1,
  "vehicle_type_id": 1,
  "estimated_weight": 200,
  "weight_unit": "KG",
  "budget": 2000,
  "terms_accepted": true,
  "special_instructions": "..."
}
```

Full request/response contract: [`docs/api/customer-shipments-contract.md`](../api/customer-shipments-contract.md)

## Verification after Postman change

```bash
dart analyze lib
```

Device test with `USE_REMOTE_API=true`:

1. Pull-to-refresh home → `GET /api/customer/shipments` in logs
2. Create shipment → `POST /api/customer/shipments`
3. Cancel → `POST .../cancel` (not PATCH)
