# Driver Vehicles API — Implementation Document

This document describes the implementation details for the **Driver Vehicles** API endpoints. These endpoints allow a driver to manage their own vehicles (list, view, add, update, delete) and fetch master/dropdown data used in vehicle forms.

## Conventions

- **Base URL:** `{{base_url}}`
- **Auth:** All endpoints require a Bearer token via the `Authorization` header.
- **Resource path prefix:** `/api/driver`

### Common Request Headers

| Header | Example Value | Required | Description |
|---|---|---|---|
| `Authorization` | `Bearer {{token}}` | Yes | Authenticated driver's access token. |
| `Accept` | `application/json` | Yes | Expected response format. |
| `Content-Type` | `application/json` | For JSON requests | Omit/replace with `multipart/form-data` when uploading files. |
| `Accept-Language` | `{{language}}` | No | Locale for localized messages. |
| `X-Device-Id` | `{{device_id}}` | No | Unique device identifier. |
| `X-Device-Type` | `{{device_type}}` | No | Platform (e.g. android/ios). |

---

## 1. List Driver Vehicles

Fetch the "My Vehicles" screen summary and the list of vehicles owned by the authenticated driver.

- **Method:** `GET`
- **Endpoint:** `{{base_url}}/api/driver/vehicles`
- **Auth:** Bearer token required
- **Body:** None

### Sample Request
```
GET {{base_url}}/api/driver/vehicles
Authorization: Bearer {{token}}
Accept: application/json
```

---

## 2. Driver Vehicle Masters

Fetch dropdown/master data used to populate driver vehicle forms (e.g. vehicle types, capacity units).

- **Method:** `GET`
- **Endpoint:** `{{base_url}}/api/driver/vehicle-masters`
- **Auth:** Bearer token required
- **Body:** None

### Sample Request
```
GET {{base_url}}/api/driver/vehicle-masters
Authorization: Bearer {{token}}
Accept: application/json
```

---

## 3. Add Driver Vehicle

Add a new vehicle with optional document/photo uploads.

- **Method:** `POST`
- **Endpoint:** `{{base_url}}/api/driver/vehicles`
- **Auth:** Bearer token required
- **Content-Type:** `multipart/form-data`

### Request Body (form-data)

| Field | Type | Example | Description |
|---|---|---|---|
| `vehicle_type_id` | text | `3` | ID of vehicle type (from masters). |
| `registration_number` | text | `MH-01-AB-1234` | Vehicle registration number. |
| `capacity` | text | `15` | Load capacity value. |
| `capacity_unit` | text | `TON` | Unit of capacity. |
| `driver_name` | text | `Vikram Singh R` | Driver's name. |
| `driver_country_code` | text | `+91` | Driver's phone country code. |
| `driver_phone` | text | `9876543210` | Driver's phone number. |
| `license_front` | file | — | License front image (optional). |
| `license_back` | file | — | License back image (optional). |
| `profile_photo` | file | — | Driver profile photo (optional). |
| `vehicle_photo` | file | — | Vehicle photo (optional). |

---

## 4. Get Driver Vehicle Detail

Fetch the "Vehicle Details" screen data for a single vehicle.

- **Method:** `GET`
- **Endpoint:** `{{base_url}}/api/driver/vehicles/{id}`
- **Auth:** Bearer token required
- **Path Parameter:** `id` — the vehicle ID (e.g. `1`).
- **Body:** None

### Sample Request
```
GET {{base_url}}/api/driver/vehicles/1
Authorization: Bearer {{token}}
Accept: application/json
```

---

## 5. Update Driver Vehicle

Update the authenticated driver's own vehicle details and optionally replace uploaded images.

- **Method:** `PUT`
- **Endpoint:** `{{base_url}}/api/driver/vehicles/{id}`
- **Auth:** Bearer token required
- **Path Parameter:** `id` — the vehicle ID (e.g. `1`).
- **Content-Type:** `multipart/form-data`

### Request Body (form-data)

| Field | Type | Example | Description |
|---|---|---|---|
| `vehicle_type_id` | text | `3` | ID of vehicle type (from masters). |
| `registration_number` | text | `MH-01-AB-1234` | Vehicle registration number. |
| `capacity` | text | `15` | Load capacity value. |
| `capacity_unit` | text | `TON` | Unit of capacity. |
| `driver_name` | text | `Vikram Singh R` | Driver's name. |
| `driver_country_code` | text | `+91` | Driver's phone country code. |
| `driver_phone` | text | `9876543210` | Driver's phone number. |
| `license_front` | file | — | Replacement license front image (optional). |
| `license_back` | file | — | Replacement license back image (optional). |
| `profile_photo` | file | — | Replacement profile photo (optional). |
| `vehicle_photo` | file | — | Replacement vehicle photo (optional). |

---

## 6. Delete Driver Vehicle

Delete the authenticated driver's own vehicle. The vehicle cannot be deleted if it is currently used in a draft or published trip.

- **Method:** `DELETE`
- **Endpoint:** `{{base_url}}/api/driver/vehicles/{id}`
- **Auth:** Bearer token required
- **Path Parameter:** `id` — the vehicle ID (e.g. `1`).
- **Body:** None

### Sample Request
```
DELETE {{base_url}}/api/driver/vehicles/1
Authorization: Bearer {{token}}
Accept: application/json
```

### Business Rules
- A vehicle in use by a draft or published trip **cannot** be deleted; the API should return an error in that case.

---

## Endpoint Summary

| # | Operation | Method | Endpoint |
|---|---|---|---|
| 1 | List Driver Vehicles | GET | `/api/driver/vehicles` |
| 2 | Driver Vehicle Masters | GET | `/api/driver/vehicle-masters` |
| 3 | Add Driver Vehicle | POST | `/api/driver/vehicles` |
| 4 | Get Driver Vehicle Detail | GET | `/api/driver/vehicles/{id}` |
| 5 | Update Driver Vehicle | PUT | `/api/driver/vehicles/{id}` |
| 6 | Delete Driver Vehicle | DELETE | `/api/driver/vehicles/{id}` |
