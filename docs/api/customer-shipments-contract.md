# Customer Shipments API Contract (Phase 2.1 / 2.2)

Source: Postman **Goods Carrier API** + live validation errors + [`API_IMPLEMENTATION.md`](../API_IMPLEMENTATION.md).

App mapping lives in:
- `lib/shared/data/api/customer/customer_shipment_api_client.dart`
- `lib/shared/data/api/customer/shipment_api_mapper.dart`
- `lib/shared/domain/entities/shipment_masters.dart`

---

## 1. GET `/api/customer/shipment-masters`

**Auth:** Bearer token required.

**Response envelope:**
```json
{
  "success": true,
  "message": "...",
  "data": {
    "goods_types": [{ "id": 1, "name": "Textiles" }],
    "vehicle_types": [{ "id": 1, "name": "Mini Truck", "slug": "mini" }],
    "weight_units": [{ "value": "KG", "label": "KG" }, { "value": "Ton", "label": "Ton" }]
  }
}
```

**App:** `ShipmentMasters.fromJson()` — used by shipment form pickers for IDs.

---

## 2. GET `/api/customer/shipments`

**Query params (Postman):**
| Param | Example | App |
|-------|---------|-----|
| `status` | `published` | Optional — API uses `published` for active listings |
| `search` | `Mumbai` | Optional |
| `page` | `1` | Default `1`, auto-fetches all pages |
| `per_page` | `10` | Default `20` |

**Response:** Paginated list inside `data`:
```json
{
  "success": true,
  "data": [
    {
      "id": 3,
      "shipment_id": "TRK-D8BV",
      "status": "published",
      "estimated_price": 2000,
      "from_address": "Ahmedabad, Gujarat",
      "to_address": "Rajkot, Gujarat",
      "pickup_date": "2026-06-22",
      "pickup_time": "15:00",
      "vehicle_type": "Mini",
      "capacity": "200 KG",
      "interest_count": 0
    }
  ],
  "meta": { "current_page": 1, "last_page": 1, "total": 1 }
}
```

Also accepts `data: { shipments: [...], meta: {...} }` nested shape.

**App:** `ShipmentApiMapper.fromJson()` per row. Status `published` → `ShipmentStatus.pending`.

---

## 3. POST `/api/customer/shipments` (Create)

**Request body (confirmed by 422 validation):**
```json
{
  "from_address": "Ahmedabad, Gujarat",
  "from_city": "Ahmedabad",
  "from_latitude": 23.022505,
  "from_longitude": 72.5713621,
  "to_address": "Rajkot, Gujarat",
  "to_city": "Rajkot",
  "to_latitude": 22.3038945,
  "to_longitude": 70.8021599,
  "pickup_date": "2026-06-22",
  "pickup_time": "08:00:00",
  "goods_type_id": 3,
  "vehicle_type_id": 1,
  "estimated_weight": 200,
  "weight_unit": "KG",
  "budget": 2000,
  "terms_accepted": true,
  "comments": "optional",
  "is_fragile": false
}
```

**Required fields:** `from_address`, `to_address`, `goods_type_id`, `vehicle_type_id`, `estimated_weight`, `weight_unit`, `pickup_date`, `pickup_time`, `budget`, `terms_accepted`.

**Response:** `{ success, data: { /* shipment */ } }`

---

## 4. GET `/api/customer/shipments/{id}/edit`

**Response:** Same shipment shape as create + `goods_type_id`, `vehicle_type_id`, `estimated_weight`, `weight_unit`.

**App:** `getShipmentForEdit()` → `ShipmentFormPrefill` (shipment + submit options for form).

---

## 5. PUT `/api/customer/shipments/{id}` (Update)

**Request body:** Same as POST create.

**Response:** `{ success, data: { /* updated shipment */ } }`

---

## 6. GET `/api/customer/shipments/{id}` (Detail)

**Request body (PUT update — Postman):**
```json
{
  "from_address": "Mumbai Central, MH",
  "from_city": "Mumbai",
  "to_address": "New Delhi",
  "to_city": "Delhi",
  "goods_type_id": 2,
  "vehicle_type_id": 3,
  "estimated_weight": 150,
  "weight_unit": "KG",
  "pickup_date": "2026-04-16",
  "pickup_time": "10:30",
  "budget": 2500,
  "additional_comments": "Updated details",
  "terms_accepted": true
}
```

Note: Update does **not** send lat/lng or `comments` / `special_instructions`. Create may still include coordinates and `pickup_time` with seconds.

**Response fields used by app:**
- Locations: `from_address`, `to_address`, `from_city`, `to_city`, lat/lng
- Schedule: `pickup_date`, `pickup_time`
- Goods: `goods_type` (object or string), `estimated_weight`, `weight_unit`
- Pricing: `budget`
- Status: `published`, `assigned`, `cancelled`, etc.
- Drivers: `interested_drivers`, `driver_requests`, `shipment_requests`

---

## 7. POST `/api/customer/shipments/{id}/cancel`

**Method:** POST (not PATCH).

**Request body:** `{}` or `{ "reason": "..." }` / `{ "cancellation_reason": "..." }`

**Response:** `{ success, message }` — no shipment body required.

---

## Status mapping

| API status | App enum |
|------------|----------|
| `published` | `ShipmentStatus.pending` |
| `interest_received` | `ShipmentStatus.interestReceived` |
| `assigned` | `ShipmentStatus.assigned` |
| `in_transit` | `ShipmentStatus.inTransit` |
| `delivered` | `ShipmentStatus.delivered` |
| `cancelled` | `ShipmentStatus.cancelled` |

---

## Not in Postman collection

- `POST /api/customer/shipments/{id}/assign` — driver assignment not wired.

---

## Verification checklist

1. `GET shipment-masters` — goods/vehicle IDs resolve in form
2. `POST shipments` — no 422 on required fields
3. `GET shipments` — list renders with `published` status
4. `GET shipments/{id}/edit` — edit form pre-fills correctly
5. `PUT shipments/{id}` — update succeeds
6. `POST shipments/{id}/cancel` — cancel succeeds
