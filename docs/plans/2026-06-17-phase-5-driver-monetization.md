# Phase 5 — Driver Monetization & Tracking

> **Status:** Payment history wired; subscription + Razorpay deferred.

**Goal:** Driver subscription flow, payment invoices, live tracking.

---

## PR map

| PR | Scope | Status |
|----|-------|--------|
| **5.1** | `GET /api/driver/payment-history` → earnings screen | Done |
| **5.2** | Subscription plans + current subscription UI | Not started |
| **5.3** | Razorpay initiate/confirm | Not started |
| **5.4** | Live tracking API + map | Not started |
| **5.5** | Customer dashboard "request trip" action | Not started |

---

## Wired endpoints

| Method | Path | App usage |
|--------|------|-----------|
| GET | `/api/driver/payment-history` | Driver earnings / payment history |
| GET | `/api/driver/payment-history/{id}` | Payment detail (client ready) |
| GET | `/api/driver/payment-history/{id}/invoice` | Invoice download (client ready) |

---

## Deferred

| Method | Path |
|--------|------|
| GET | `/api/driver/subscription-plans` |
| POST | `/api/driver/subscriptions/initiate` |
| POST | `/api/driver/subscriptions/confirm` |
| GET | `/api/driver/subscriptions/current` |
