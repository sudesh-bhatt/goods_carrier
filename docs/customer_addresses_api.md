# Customer Addresses API — Implementation Documentation

## Overview

Base URL: `{{base_url}}`
All endpoints require authentication via Bearer token.

---

## Common Headers

| Header | Value |
|---|---|
| Authorization | Bearer {{token}} |
| Accept | application/json |
| Content-Type | application/json |
| X-Language | {{language}} |
| X-Device-Id | {{device_id}} |
| X-Device-Type | {{device_type}} |

---

## APIs

### 1. List Customer Addresses

- **Method:** GET
- **Endpoint:** `/api/customer/addresses`
- **Description:** List saved addresses for the logged-in customer.
- **Request Body:** None

#### Success Response (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "label": "Home",
      "address_line": "123 Skyview Apartments, Sector 45",
      "city": "Gurgaon",
      "state": "Haryana",
      "pincode": "122003",
      "latitude": "28.4595",
      "longitude": "77.0266",
      "is_default": true,
      "created_at": "2024-01-01T00:00:00.000000Z",
      "updated_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 2. Create Customer Address

- **Method:** POST
- **Endpoint:** `/api/customer/addresses`
- **Description:** Create a saved address for the logged-in customer. If `is_default` is true, other addresses are unset.

#### Request Body

```json
{
  "label": "Home",
  "address_line": "123 Skyview Apartments, Sector 45",
  "city": "Gurgaon",
  "state": "Haryana",
  "pincode": "122003",
  "latitude": "28.4595",
  "longitude": "77.0266",
  "is_default": true
}
```

#### Request Body Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `label` | string | Yes | Label for the address (e.g., Home, Work) |
| `address_line` | string | Yes | Full address line |
| `city` | string | Yes | City name |
| `state` | string | Yes | State name |
| `pincode` | string | Yes | Postal/PIN code |
| `latitude` | string | Yes | Latitude coordinate |
| `longitude` | string | Yes | Longitude coordinate |
| `is_default` | boolean | No | Set as default address; unsets all others if true |

#### Success Response (200 OK)

```json
{
  "success": true,
  "message": "Address created successfully.",
  "data": {
    "id": 1,
    "label": "Home",
    "address_line": "123 Skyview Apartments, Sector 45",
    "city": "Gurgaon",
    "state": "Haryana",
    "pincode": "122003",
    "latitude": "28.4595",
    "longitude": "77.0266",
    "is_default": true,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 3. Get Customer Address Detail

- **Method:** GET
- **Endpoint:** `/api/customer/addresses/{id}`
- **Path Parameter:** `id` — ID of the address to retrieve
- **Description:** Fetch one saved address owned by the logged-in customer.
- **Request Body:** None

#### Success Response (200 OK)

```json
{
  "success": true,
  "data": {
    "id": 1,
    "label": "Home",
    "address_line": "123 Skyview Apartments, Sector 45",
    "city": "Gurgaon",
    "state": "Haryana",
    "pincode": "122003",
    "latitude": "28.4595",
    "longitude": "77.0266",
    "is_default": true,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 4. Update Customer Address

- **Method:** PUT
- **Endpoint:** `/api/customer/addresses/{id}`
- **Path Parameter:** `id` — ID of the address to update
- **Description:** Update one saved address owned by the logged-in customer.

#### Request Body

```json
{
  "label": "Warehouse",
  "address_line": "Warehouse 9, Freight Corridor",
  "city": "Gurgaon",
  "state": "Haryana",
  "pincode": "122005",
  "latitude": "28.4700",
  "longitude": "77.0400",
  "is_default": true
}
```

#### Request Body Fields

Same as [Create Customer Address](#2-create-customer-address). All fields are optional (partial update supported).

#### Success Response (200 OK)

```json
{
  "success": true,
  "message": "Address updated successfully.",
  "data": {
    "id": 1,
    "label": "Warehouse",
    "address_line": "Warehouse 9, Freight Corridor",
    "city": "Gurgaon",
    "state": "Haryana",
    "pincode": "122005",
    "latitude": "28.4700",
    "longitude": "77.0400",
    "is_default": true,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 5. Delete Customer Address

- **Method:** DELETE
- **Endpoint:** `/api/customer/addresses/{id}`
- **Path Parameter:** `id` — ID of the address to delete
- **Description:** Delete one saved address owned by the logged-in customer.
- **Request Body:** None

#### Success Response (200 OK)

```json
{
  "success": true,
  "message": "Address deleted successfully."
}
```

---

### 6. Set Default Customer Address

- **Method:** POST
- **Endpoint:** `/api/customer/addresses/{id}/set-default`
- **Path Parameter:** `id` — ID of the address to set as default
- **Description:** Mark one saved address as default and update `users.primary_address_id`.
- **Request Body:** None

#### Success Response (200 OK)

```json
{
  "success": true,
  "message": "Default address updated successfully.",
  "data": {
    "id": 1,
    "label": "Home",
    "address_line": "123 Skyview Apartments, Sector 45",
    "city": "Gurgaon",
    "state": "Haryana",
    "pincode": "122003",
    "latitude": "28.4595",
    "longitude": "77.0266",
    "is_default": true,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

## Notes

- All endpoints require a valid Bearer token in the `Authorization` header.
- The `{id}` path parameter refers to the address record ID.
- Setting `is_default: true` on Create or Update will automatically unset the default flag on all other addresses for that customer.
- The `set-default` endpoint also updates the `primary_address_id` field on the users table.
- The Get Customer Address Detail endpoint (endpoint 3) is unique to the Customer Addresses API and is not present in the Driver Addresses API.
