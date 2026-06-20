# Goods Carrier API — Implementation Guide

## Overview

The Goods Carrier API is the backend for a **goods carrier logistics platform** that connects two primary user roles:

- **Customers** — users who post shipments that need to be transported.
- **Drivers** — users who publish trips, manage their vehicles, and accept shipment requests.

The platform supports the following capabilities:

- **OTP-based authentication** and session management.
- **Onboarding** flows (role selection, language, agreements).
- **Profile & address management** for both customers and drivers.
- **Shipments** (create, edit, list, cancel) posted by customers.
- **Trips** published by drivers, with trip requests handling.
- **Subscriptions & payments** for drivers (plans, payment history, invoices).
- **Notifications**, **reports**, and **help & support**.

This document describes the implementation conventions and the full set of endpoints exposed by the API, organized by feature area.

## Base URL & Environment

All endpoints are relative to the `{{base_url}}` variable.

- `{{base_url}}` is defined in the **Goods Carrier Local** Postman environment.
- Every path documented below should be appended to `{{base_url}}` (e.g. `{{base_url}}/api/auth/send-otp`).

> Switch or update the active environment to target a different deployment (local, staging, production) without changing individual requests.

## Authentication

The API uses an **OTP-based authentication** flow:

1. **Send OTP** — `POST /api/auth/send-otp` initiates the flow by sending a one-time password to the user.
2. **Verify OTP** — `POST /api/auth/verify-otp` validates the OTP and returns a **session/token** on success.
3. The returned token must be sent on **all subsequent authenticated requests** (typically via an `Authorization` header).
4. **Resend OTP** — `POST /api/auth/resend-otp` re-issues an OTP if the previous one expired or was not received.
5. **Me** — `GET /api/auth/me` returns the currently authenticated user.
6. **Logout** — `POST /api/auth/logout` invalidates the active session/token.

### Public vs. Authenticated Endpoints

**Public** (no authentication required):

- `POST /api/auth/send-otp`
- `POST /api/auth/resend-otp`
- `POST /api/auth/verify-otp`
- `GET /api/app/config`

**Authenticated** (valid token required) — including but not limited to:

- `/api/driver/...`
- `/api/customer/...`
- `/api/notifications`
- `/api/reports`

## Conventions

- **RESTful design** — resources are manipulated with standard HTTP methods (`GET`, `POST`, `PUT`, `DELETE`). `POST` to action sub-paths (e.g. `/cancel`, `/set-default`) performs state transitions.
- **JSON bodies** — request and response payloads are JSON, unless otherwise noted (file uploads use `multipart/form-data`).
- **List endpoints** commonly accept the following query parameters:
  - `search` — free-text search.
  - `page` — page number (pagination).
  - `per_page` — number of items per page.
  - Filters such as `status`, `from_city`, `to_city`, `pickup_date`, `vehicle_type_id`, `capacity_min`, `capacity_max`.
- **Path IDs** — numeric segments like `/1` (and string IDs like `/REP-7729` or `/privacy_policy`) are **placeholders** for the actual resource identifier.

## Endpoints

> Paths below are relative to `{{base_url}}`. Query strings are shown where applicable.

### Auth

OTP-based authentication, session retrieval, and logout.

| Name | Method | Path |
| --- | --- | --- |
| Send OTP | POST | `/api/auth/send-otp` |
| Verify OTP | POST | `/api/auth/verify-otp` |
| Resend OTP | POST | `/api/auth/resend-otp` |
| Me | GET | `/api/auth/me` |
| Logout | POST | `/api/auth/logout` |

### Onboarding

Guides a new user through session creation, role/language selection, and agreement acceptance.

| Name | Method | Path |
| --- | --- | --- |
| Create / Update Onboarding Session | POST | `/api/onboarding/session` |
| Update Onboarding Role | POST | `/api/onboarding/role` |
| Update Onboarding Language | POST | `/api/onboarding/language` |
| Accept Onboarding Agreement | POST | `/api/onboarding/accept-agreement` |
| Onboarding Status | GET | `/api/onboarding/status` |

### Profile

Create, read, and update the customer profile, including avatar upload.

| Name | Method | Path |
| --- | --- | --- |
| Create Customer Profile | POST | `/api/customer/profile` |
| Get My Customer Profile | GET | `/api/customer/profile` |
| Update Customer Profile | PUT | `/api/customer/profile` |
| Upload Customer Avatar | POST | `/api/customer/profile/avatar` |

### Addresses

Manage a customer's saved addresses, including setting a default.

| Name | Method | Path |
| --- | --- | --- |
| List Customer Addresses | GET | `/api/customer/addresses` |
| Create Customer Address | POST | `/api/customer/addresses` |
| Get Customer Address Detail | GET | `/api/customer/addresses/1` |
| Update Customer Address | PUT | `/api/customer/addresses/1` |
| Delete Customer Address | DELETE | `/api/customer/addresses/1` |
| Set Default Customer Address | POST | `/api/customer/addresses/1/set-default` |

### Shipments

Customer-posted shipments: create, edit, view, list, and cancel.

| Name | Method | Path |
| --- | --- | --- |
| My Shipments List | GET | `/api/customer/shipments?status=published&search=Mumbai&page=1&per_page=10` |
| Create Customer Shipment | POST | `/api/customer/shipments` |
| Get Customer Shipment For Edit | GET | `/api/customer/shipments/1/edit` |
| Update Customer Shipment | PUT | `/api/customer/shipments/1` |
| Shipment Detail | GET | `/api/customer/shipments/1` |
| Cancel Shipment | POST | `/api/customer/shipments/1/cancel` |

### Dashboard

Customer dashboard that supports searching available driver trips with filters.

| Name | Method | Path |
| --- | --- | --- |
| Customer Dashboard / Driver Trips Search | GET | `/api/customer/dashboard?search=Bandra&vehicle_type_id=2&from_city=Bandra East&to_city=Andheri West&pickup_date=2026-04-15&capacity_min=1&capacity_max=2&page=1&per_page=10` |

### Help & Support

Retrieves help and support content for customers.

| Name | Method | Path |
| --- | --- | --- |
| Help & Support Data | GET | `/api/customer/support` |

### Settings

Customer and general app settings, including notifications, language, and static legal pages.

| Name | Method | Path |
| --- | --- | --- |
| Get Customer Settings | GET | `/api/customer/settings` |
| Update Push Notification Setting | POST | `/api/customer/settings/push-notification` |
| Update Language | POST | `/api/customer/settings/language` |
| Static Legal Page Detail | GET | `/api/customer/pages/privacy_policy` |
| Get Settings | GET | `/api/settings` |
| Update Push Notification | POST | `/api/settings/push-notification` |
| Update Settings Language | POST | `/api/settings/language` |
| Get Static Page | GET | `/api/pages/privacy_policy` |

### Master Data

Public app configuration and shipment-related master/reference data.

| Name | Method | Path |
| --- | --- | --- |
| Public App Config / Splash Data | GET | `/api/app/config` |
| Shipment Master Data | GET | `/api/customer/shipment-masters` |

### Driver Profile

Create, read, and update the driver profile, including avatar upload.

| Name | Method | Path |
| --- | --- | --- |
| Create Driver Profile | POST | `/api/driver/profile` |
| Get Driver Profile | GET | `/api/driver/profile` |
| Update Driver Profile | PUT | `/api/driver/profile` |
| Upload Driver Avatar | POST | `/api/driver/profile/avatar` |

### Driver Dashboard

Driver dashboard showing active shipments with search and filtering.

| Name | Method | Path |
| --- | --- | --- |
| Driver Dashboard Active Shipments | GET | `/api/driver/dashboard?search=TRK&from_city=Mumbai&to_city=Delhi&pickup_date=2026-04-15&vehicle_type_id=2&capacity_min=1&capacity_max=2&page=1&per_page=10` |

### Driver Shipments

Driver-side shipment detail viewing and submitting requests against shipments.

| Name | Method | Path |
| --- | --- | --- |
| Get Driver Shipment Detail | GET | `/api/driver/shipments/1` |
| Add Shipment Request | POST | `/api/driver/shipments/1/requests` |

### Reports

Submit reports and check report status; drivers can list reported shipments.

| Name | Method | Path |
| --- | --- | --- |
| Submit Report | POST | `/api/reports` |
| Get Report Status | GET | `/api/reports/REP-7729` |
| Driver Reported Shipments | GET | `/api/driver/reported-shipments?search=TRK&page=1&per_page=10` |

### Driver Subscription and Payments

Driver subscription plans, payment initiation/confirmation, history, and invoices.

| Name | Method | Path |
| --- | --- | --- |
| Get Subscription Plans | GET | `/api/driver/subscription-plans` |
| Initiate Subscription Payment | POST | `/api/driver/subscriptions/initiate` |
| Confirm Subscription Payment | POST | `/api/driver/subscriptions/confirm` |
| Get Current Subscription | GET | `/api/driver/subscriptions/current` |
| Get Payment History | GET | `/api/driver/payment-history` |
| Get Payment Detail | GET | `/api/driver/payment-history/1` |
| Get Payment Invoice | GET | `/api/driver/payment-history/1/invoice` |

### Notifications

List, read, and delete user notifications.

| Name | Method | Path |
| --- | --- | --- |
| List Notifications | GET | `/api/notifications?unread_only=false&page=1&per_page=10` |
| Mark Notification Read | POST | `/api/notifications/1/read` |
| Mark All Notifications Read | POST | `/api/notifications/read-all` |
| Delete Notification | DELETE | `/api/notifications/1` |

### Driver Trip Requests

Manage incoming requests on a driver's trips (list, accept, reject).

| Name | Method | Path |
| --- | --- | --- |
| List Driver Trip Requests | GET | `/api/driver/trips/1/requests` |
| Accept Driver Trip Request | POST | `/api/driver/trips/1/requests/1/accept` |
| Reject Driver Trip Request | POST | `/api/driver/trips/1/requests/1/reject` |

### Driver Trips

Publish, list, view, edit, and cancel driver trips.

| Name | Method | Path |
| --- | --- | --- |
| Publish Driver Trip | POST | `/api/driver/trips` |
| List Driver Trips | GET | `/api/driver/trips?status=published&search=Mumbai&page=1&per_page=10` |
| Get Driver Trip Detail | GET | `/api/driver/trips/1` |
| Get Driver Trip For Edit | GET | `/api/driver/trips/1/edit` |
| Update Driver Trip | PUT | `/api/driver/trips/1` |
| Cancel Driver Trip | POST | `/api/driver/trips/1/cancel` |

### Driver Vehicles

Manage a driver's vehicles and related vehicle master data.

| Name | Method | Path |
| --- | --- | --- |
| List Driver Vehicles | GET | `/api/driver/vehicles` |
| Add Driver Vehicle | POST | `/api/driver/vehicles` |
| Get Driver Vehicle Detail | GET | `/api/driver/vehicles/1` |
| Update Driver Vehicle | PUT | `/api/driver/vehicles/1` |
| Delete Driver Vehicle | DELETE | `/api/driver/vehicles/1` |
| Driver Vehicle Masters | GET | `/api/driver/vehicle-masters` |

### Driver Addresses

Manage a driver's saved addresses, including setting a default.

| Name | Method | Path |
| --- | --- | --- |
| List Driver Addresses | GET | `/api/driver/addresses` |
| Create Driver Address | POST | `/api/driver/addresses` |
| Update Driver Address | PUT | `/api/driver/addresses/1` |
| Delete Driver Address | DELETE | `/api/driver/addresses/1` |
| Set Default Driver Address | POST | `/api/driver/addresses/1/set-default` |

### Support

Retrieves general support information.

| Name | Method | Path |
| --- | --- | --- |
| Get Support | GET | `/api/support` |

## Implementation Notes

- **HTTP status codes** — return appropriate codes (`200`/`201` for success, `400` for validation errors, `401` for missing/invalid tokens, `403` for unauthorized roles, `404` for missing resources, `422` for unprocessable input).
- **OTP expiry** — validate that the submitted OTP is unexpired and matches before issuing a session/token; support `resend-otp` for expired codes.
- **Pagination** — list endpoints should honor `page` and `per_page`, and return consistent pagination metadata (total count, current page, etc.).
- **Role-based authorization** — enforce that `/api/customer/...` routes are accessible only to customers and `/api/driver/...` routes only to drivers; shared routes (e.g. `/api/notifications`, `/api/reports`, `/api/settings`) should respect the authenticated user's permissions.
- **File uploads** — avatar endpoints (`/api/customer/profile/avatar`, `/api/driver/profile/avatar`) should accept `multipart/form-data` and validate file type/size.
- **Public endpoints** — keep `/api/auth/send-otp`, `/api/auth/resend-otp`, `/api/auth/verify-otp`, and `/api/app/config` accessible without authentication, and ensure all other endpoints reject unauthenticated requests.
- **Consistent error format** — return errors in a uniform JSON structure to simplify client handling.
