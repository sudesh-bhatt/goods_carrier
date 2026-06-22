# Driver Trips API Contract (Phase 3.1 / 3.2)

Base: `https://goodscarrier.ajonetech.com`

## List / detail response fields

Mapped in `TripApiMapper.fromJson()`:

- `id` (numeric) + `trip_id` / `trip_code` (display, e.g. `VB-9928`)
- `from_city`, `to_city`, optional addresses
- `estimated_start_date`, `estimated_start_time`
- `estimated_end_date`, `estimated_end_time`
- `vehicle_type_id` or nested `vehicle_type`
- `vehicle_number`
- `capacity`, `capacity_unit`
- `budget` / `estimated_price`
- `status` (`published`, `cancelled`, etc.)
- `interest_count` / `requests_count`

## Publish / update body (`POST` / `PUT`)

```json
{
  "from_city": "Mumbai",
  "to_city": "Delhi",
  "estimated_start_date": "2026-04-15",
  "estimated_start_time": "09:00",
  "estimated_end_date": "2026-04-17",
  "estimated_end_time": "19:00",
  "vehicle_type_id": 2,
  "vehicle_number": "MH 02 CC 4156",
  "capacity": 1,
  "capacity_unit": "TON",
  "budget": 2100,
  "driver_name": "Vikram Singh",
  "driver_phone": "+919876543210"
}
```

## Cancel body (`POST .../cancel`)

Same shape as customer shipment cancel:

```json
{
  "reason": "Change of plans",
  "other_reason": null
}
```

## Driver dashboard (`GET /api/driver/dashboard`)

Same query params as customer dashboard: `search`, `vehicle_type_id`, `from_city`, `to_city`, `pickup_date`, `capacity_min`, `capacity_max`, `page`, `per_page`.

Rows map through `ShipmentApiMapper` (same as customer shipment list).

## Express interest

`POST /api/driver/shipments/{id}/requests`

Optional body: `{ "quoted_price": 2000 }`

## Trip customer requests

- `GET /api/driver/trips/{id}/requests` — list interested customers
- `POST /api/driver/trips/{id}/requests/{requestId}/accept`
- `POST /api/driver/trips/{id}/requests/{requestId}/reject`

Response rows map to `DriverTripRequest` via `TripApiMapper.parseRequestItem()`.
Nested customer fields: `customer.name`, `customer.phone`, `quoted_price`, `status`.
