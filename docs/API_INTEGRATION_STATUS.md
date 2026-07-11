# API Integration Status

Last updated: 2026-07-11

Toggle: `USE_REMOTE_API=true` in `.env`

## Summary

| Phase | Area | ~Complete |
|-------|------|-----------|
| 1 | Auth & onboarding | 95% |
| 2 | Customer module | 90% |
| 3 | Driver module | 95% |
| 4 | Shared services | 90% |
| 5 | Monetization & tracking | 25% |

**Overall: ~88%** of documented API surface wired in app.

---

## Phase 1 — Auth & Onboarding ✅

| Feature | Status |
|---------|--------|
| OTP send/verify/resend | ✅ |
| `/api/auth/me`, logout | ✅ |
| Onboarding role/lang/terms | ✅ |
| Customer profile create/update/avatar | ✅ |
| Driver profile create/update/avatar/get | ✅ |
| `GET /api/app/config` splash + dynamic runtime config | ✅ |

---

## Phase 2 — Customer ✅

| Feature | Status |
|---------|--------|
| Dashboard `GET /api/customer/dashboard` | ✅ |
| Shipments CRUD + cancel | ✅ |
| Shipment detail + interested drivers | ✅ |
| Assign driver `POST .../assign` | ✅ wired (confirm with backend) |
| Shipment masters | ✅ |
| Saved addresses CRUD | ✅ |
| Customer trip detail (real driver data) | ✅ |
| Report trip submit | ✅ |
| Support center | ✅ |
| Settings push/language sync | ✅ read + write |
| Tracking live map | ❌ UI only |
| Customer reported trips list | ⚠️ local cache (no list API) |

---

## Phase 3 — Driver ✅

| Feature | Status |
|---------|--------|
| Dashboard + filters | ✅ |
| Shipment detail + express interest | ✅ |
| Trips CRUD + cancel | ✅ |
| Trip detail + accept/reject | ✅ |
| Profile refresh + avatar | ✅ |
| Vehicles CRUD + masters | ✅ |
| Saved addresses CRUD | ✅ |
| Payment history | ✅ |
| Subscription / Razorpay | ❌ |
| Driver reported shipments list | ✅ screen + API |

---

## Phase 4 — Shared ⚠️

| Feature | Status |
|---------|--------|
| Notifications list/read | ✅ |
| Reports submit | ✅ |
| Customer support | ✅ |
| Customer settings sync | ✅ |
| App config splash/base URL/prefs/maintenance/version/branding | ✅ |
| FCM push | ❌ |

---

## Remaining (ordered by priority)

1. **Razorpay subscription flow** — driver monetization blocker
2. **Live tracking API** — needs backend contract
3. **FCM** — push token + notification delivery
4. **Customer reported-trips list** — needs backend endpoint
5. **Customer dashboard trip request** — wire CTA to backend

---

## Plan docs

- [Phase 2 — Customer](./plans/2026-06-17-phase-2-customer-api-integration.md)
- [Phase 3 — Driver](./plans/2026-06-17-phase-3-driver-api-integration.md)
- [Phase 4 — Shared](./plans/2026-06-17-phase-4-shared-api-integration.md)
- [Phase 5 — Monetization](./plans/2026-06-17-phase-5-driver-monetization.md)
