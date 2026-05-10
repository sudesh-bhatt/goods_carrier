# Goods Carrier — Flutter Build Checklist

Dual-role Indian logistics marketplace (Customer + Driver).  
Architecture: Feature-first Clean Architecture · Riverpod + riverpod_generator · GoRouter · flutter_screenutil · ThemeExtension.

---

## SESSION 1 — Core Foundation ✅
> "Everything a screen needs to exist — no screens yet."

### Enums
- [x] `lib/shared/domain/enums/user_role.dart` — `UserRole.customer / .driver`
- [x] `lib/shared/domain/enums/vehicle_type.dart` — mini / pickupTruck / truck / heavyDuty + label/capacityLabel
- [x] `lib/shared/domain/enums/shipment_status.dart` — pending → cancelled + label
- [x] `lib/shared/domain/enums/trip_status.dart` — active → cancelled + label

### Domain Entities (plain Dart, no Freezed yet)
- [x] `lib/shared/domain/entities/user.dart` — User + copyWith + initials
- [x] `lib/shared/domain/entities/shipment.dart` — Shipment + ShipmentLocation + GoodsDetail
- [x] `lib/shared/domain/entities/driver_trip.dart` — DriverTrip + copyWith
- [x] `lib/shared/domain/entities/notification_item.dart` — NotificationItem + NotificationType enum

### Dummy Data
- [x] `lib/core/dummy/dummy_user.dart` — DummyUser.customer / .driver
- [x] `lib/core/dummy/dummy_shipments.dart` — 4 shipments (all statuses)
- [x] `lib/core/dummy/dummy_trips.dart` — 3 driver trips (all statuses)
- [x] `lib/core/dummy/dummy_notifications.dart` — customer (3) + driver (4) notifications

### Theme
- [x] `lib/core/theme/app_color_scheme.dart` — AppColorScheme ThemeExtension (17 tokens, light + dark)
- [x] `lib/core/theme/app_theme.dart` — AppTheme.light() / .dark() with Manrope font

### Extensions
- [x] `lib/core/extensions/size_ext.dart` — `.w .h .sp .r` via ScreenUtil
- [x] `lib/core/extensions/theme_ext.dart` — `context.colors`, `context.isDark`, `context.cardShadow`
- [x] `lib/core/extensions/num_ext.dart` — `2100.inr` → "₹2,100"
- [x] `lib/core/extensions/string_ext.dart` — `capitalised`, `titleCase`, `initials`, DateTimeExt

### Constants
- [x] `lib/core/constants/app_dimensions.dart` — spacing, radius, heights, icon sizes
- [x] `lib/core/constants/id_prefixes.dart` — TRK- / VB- / INV- / USR-

### Utils
- [x] `lib/core/utils/validators.dart` — phone (+91), GST, vehicleNumber, email, OTP, required
- [x] `lib/core/utils/platform_utils.dart` — statusBar, edgeToEdge, haptics, safeArea, keyboard

### Settings Feature
- [x] `lib/features/settings/presentation/providers/theme_provider.dart` — ThemeNotifier + Hive persistence

### Localisation
- [x] `l10n.yaml` — gen-l10n config (arb-dir, output-class, synthetic-package: false)
- [x] `lib/l10n/app_en.arb` — English strings (all keys)
- [x] `lib/l10n/app_hi.arb` — Hindi translations
- [x] `lib/l10n/app_gu.arb` — Gujarati translations
- [x] `lib/features/settings/presentation/providers/locale_provider.dart` — LocaleNotifier + SharedPreferences persistence

### App Bootstrap
- [x] `lib/main.dart` — ProviderScope + SharedPreferences seed (theme + locale) + edge-to-edge
- [x] `lib/app.dart` — GoodsCarrierApp (MaterialApp + themeMode + locale wired + textScale clamp)

### Rule enforced
- [x] `context.l10n` shortcut added to `theme_ext.dart`
- [x] **NO hardcoded string literals in widget build methods — always use `context.l10n.<key>`**

---

## SESSION 2 — Shared Widget Library ✅
> "Every reusable UI primitive before the first real screen."

### Buttons & Inputs
- [x] `AppButton` — primary / secondary / ghost variants, loading state, haptic feedback
- [x] `AppTextField` — prefix icon, suffix action, error state, label, India-optimised keyboard types
- [x] `AppOtpField` — **4-box** OTP entry (corrected from 6 per Figma), auto-advance, paste support, blinking cursor

### Cards & Status
- [x] `ShipmentCard` — TRK-XXXX header, route, status chip, date, price, fragile banner, optional CTA
- [x] `DriverTripCard` — VB-XXXX header, route, vehicle info, capacity, price, optional CTA
- [x] `StatusChip` — colour-coded pill per ShipmentStatus / TripStatus
- [x] `FragileBanner` — orange warning strip ("⚠ Handle with care — fragile goods")
- [x] `RouteTimeline` — vertical dotted line: pickup city → drop city (compact + full modes)

### Notifications & Feedback
- [x] `NotificationTile` — read/unread state, type icon, relative timestamp, long-press mark-read
- [x] `AppLoader` — centred CircularProgressIndicator using AppColorScheme.primary
- [x] `SkeletonCard` — shimmer placeholder via AnimationController + TweenSequence (no package)
- [x] `ErrorView` — icon + message + optional retry button (full-page + inline modes)
- [x] `EmptyState` — illustration placeholder + headline + sub-text + optional action CTA

### Navigation & Overlays
- [x] `AppBarWidget` — back / hamburger / none leading, badge support on action icons
- [x] `ConfirmationBottomSheet` — drag handle + title + body + confirm/cancel CTAs, `isDangerous` flag

### Barrel export
- [x] `lib/shared/presentation/widgets/shared_widgets.dart` — single import for all 15 widgets

### OTP fix applied
- [x] `validators.dart` — otp() changed from 6-digit to 4-digit
- [x] `app_en.arb` + `app_localizations_en.dart` — validationOtpInvalid / validationOtpDigitsOnly corrected to 4-digit

---

## SESSION 3 — Navigation + Auth/Onboarding Screens ✅

### GoRouter Setup
- [x] `lib/core/router/app_router.dart` — GoRouter + `_RouterNotifier` (ChangeNotifier bridging Riverpod → GoRouter refresh), role-based redirect, placeholder home routes for Sessions 4/5
- [x] `lib/core/router/app_routes.dart` — All named routes as `abstract final class AppRoutes` with helper methods
- [x] `lib/features/auth/presentation/providers/auth_provider.dart` — `AuthState` (unauthenticated / profileSetupPending / authenticated) + `AuthNotifier` (selectRole, sendOtp, verifyOtp, submitCustomerProfile, submitDriverProfile, logout, loginAsDummyUser)
- [x] `app.dart` updated — `MaterialApp` → `MaterialApp.router` wired to `appRouterProvider`

### Auth Screens
- [x] `SplashScreen` — fade + scale animation, auto-navigate after 2 s
- [x] `RoleSelectionScreen` — Customer / Driver role cards, haptic selection
- [x] `LanguageSelectionScreen` — EN / HI / GU tiles, checkmark animation, persists via `LocaleNotifier`
- [x] `TermsScreen` — scrollable 10-section T&C, animated checkbox, CTA gated on acceptance
- [x] `PhoneInputScreen` — +91 emoji flag prefix, 10-digit only, `Validators.phone`
- [x] `OtpVerificationScreen` — 4-box `AppOtpField`, 60 s countdown timer, resend CTA, error state with red boxes, redirect-driven navigation
- [x] `CustomerProfileSetupScreen` — name + email (required), company + GST (optional with divider), avatar placeholder
- [x] `DriverProfileSetupScreen` — name, 4-chip vehicle type selector, vehicle number, auto-filled capacity field

---

## SESSION 4 — Customer Flow Screens ✅

### Providers
- [x] `lib/features/customer/presentation/providers/customer_shipments_provider.dart` — `CustomerShipmentsState` + `CustomerShipmentsNotifier` (addShipment, cancelShipment, selectDriver, byId) seeded from `DummyShipments.all`
- [x] `lib/features/customer/presentation/providers/customer_notifications_provider.dart` — `CustomerNotificationsNotifier` (markRead, markAllRead) + `customerUnreadCountProvider`

### Screens
- [x] `CustomerHomeScreen` — greeting header, active-shipments SliverList, SkeletonCard loading, EmptyState, FAB "Post Shipment", AppBar notification badge + profile action
- [x] `PostShipmentScreen` — 4-step PageView (Pickup → Drop → Goods → Vehicle+Date), animated step-indicator bar, per-step form validation, fragile toggle, date picker, price estimation, `addShipment()` on submit
- [x] `ShipmentDetailScreen` — status + price header, RouteTimeline with full addresses, goods/schedule section cards, FragileBanner, interested-drivers list, cancel CTA with `ConfirmationBottomSheet`
- [x] `DriverDetailSheet` — `DraggableScrollableSheet`, driver avatar + verified badge, stats row (trips/rating/years), vehicle info card, "Select Driver" CTA → `selectDriver()` + pop
- [x] `TrackingScreen` — `CustomPaint` map grid placeholder, pickup/drop pins, animated truck centrepiece, status timeline with animated dots
- [x] `CustomerNotificationsScreen` — `NotificationTile` list, "mark all read" AppBar action, EmptyState
- [x] `CustomerProfileScreen` — avatar + initials, personal info card, optional GST/company card, 3-segment theme toggle (Light/Dark/System), logout with `ConfirmationBottomSheet`
- [x] `CustomerHistoryScreen` — TabBar (Completed / Cancelled) via `AppBarWidget.bottom`, `ShipmentCard` list per tab, EmptyState per tab

### Infrastructure updates
- [x] `app_router.dart` — 7 new customer routes wired (home, post-shipment, shipment/:id, tracking/:id, notifications, profile, history); placeholder removed
- [x] `AppBarWidget` — added `bottom: PreferredSizeWidget?` + `preferredSize` accounts for tab-bar height

---

## SESSION 5 — Driver Flow Screens ✅

### Providers
- [x] `lib/features/driver/presentation/providers/driver_trips_provider.dart` — `DriverTripsState` + `DriverTripsNotifier` (postTrip, cancelTrip) seeded from `DummyTrips.myTrips`; exposes `.active`, `.completed`, `.history`, `.byId()`
- [x] `lib/features/driver/presentation/providers/driver_notifications_provider.dart` — `DriverNotificationsNotifier` (markRead, markAllRead) + `driverUnreadCountProvider`
- [x] `lib/features/driver/presentation/providers/driver_shipment_requests_provider.dart` — `DriverShipmentRequestsNotifier` seeded from `DummyShipments.pending`; tracks expressed-interest set per session

### Widgets
- [x] `ShipmentRequestCard` — TRK-ID + status chip header, compact RouteTimeline, goods meta chips, price, "Express Interest" CTA → transitions to "Interest Submitted" badge once expressed
- [x] `ExpressInterestSheet` — `DraggableScrollableSheet`, platform-estimate display, optional custom quote TextField, confirm/cancel CTAs, calls `expressInterest()` on submit

### Screens
- [x] `DriverHomeScreen` — greeting, active trips `SliverList` (DriverTripCard), available requests feed (ShipmentRequestCard), notification badge, FAB "Post Trip"
- [x] `PostTripScreen` — from/to city, date picker, vehicle type chip selector (4 chips), vehicle number, auto-derived capacity (read-only), quoted price; calls `postTrip()` on submit
- [x] `DriverTripDetailScreen` — status + earnings header, route/vehicle/schedule section cards, accepted shipment placeholder, cancel CTA with `ConfirmationBottomSheet`
- [x] `DriverNotificationsScreen` — `NotificationTile` list, mark-all-read AppBar action, EmptyState
- [x] `DriverProfileScreen` — Gold Member subscription tier badge (gradient), stats row (trips/completed/rating), personal + vehicle + business info cards, theme toggle, logout
- [x] `DriverEarningsScreen` — total earned + pending summary cards, INV-XXXX invoice list with paid/pending status chips and trip reference

### Infrastructure updates
- [x] `app_router.dart` — 6 new driver routes wired (home, post-trip, trip/:id, notifications, profile, earnings); `_DriverHomePlaceholder` removed; 21 total GoRoute entries (8 auth + 7 customer + 6 driver)

---

## SESSION 6 — Polish, Theme Toggle & Platform QA ✅

- [x] Theme toggle entry in Profile screens (Light / Dark / System) — `_ThemeToggleCard` in CustomerProfileScreen + DriverProfileScreen, wired to `ThemeNotifier.setMode()`
- [x] Android status-bar style — `AppBarWidget` applies `SystemUiOverlayStyle` per-screen; `PlatformUtils.enableEdgeToEdge()` sets transparent nav bar in `main()`
- [x] iOS safe-area — `SafeArea` wraps body on every screen; `MediaQuery.padding` respected
- [x] flutter_screenutil tablet breakpoint guard — `app.dart` constrains layout to 480 px on `shortestSide ≥ 600` with `Center + SizedBox`
- [x] Custom `ScrollBehavior` — `_AppScrollBehavior` suppresses Android glow/stretch indicator; uses `BouncingScrollPhysics` on iOS, `ClampingScrollPhysics` on Android
- [x] `RefreshIndicator` on `CustomerHomeScreen` + `DriverHomeScreen` (stub; real refresh in Session 7)
- [x] `PopScope` on `PostShipmentScreen` — Android back steps through form pages; only pops route on step 0
- [x] Haptic feedback on theme-toggle segment taps (`HapticFeedback.selectionClick()`) in both profile screens
- [x] Deprecated `splashRadius` removed from `AppBarWidget` (×3) and `AppTextField` (×1)
- [x] Dark-mode colour audit — grep confirms all `colors.xxx` refs match 17 valid `AppColorScheme` tokens; no invalid tokens found

---

## SESSION 7 — API Integration ✅

### Network layer
- [x] `pubspec.yaml` — added `dio: ^5.7.0`
- [x] `lib/core/network/api_constants.dart` — baseUrl, timeouts, all endpoint paths, secure-storage keys
- [x] `lib/core/network/app_exception.dart` — sealed class hierarchy (`NetworkException`, `TimeoutException`, `UnauthorisedException`, `ServerException`, `CacheException`) + `AppException.fromDioException()`
- [x] `lib/core/network/interceptors/auth_interceptor.dart` — Bearer token injection + silent 401 refresh with retry; clears tokens on repeated failure
- [x] `lib/core/network/interceptors/error_interceptor.dart` — `DioException` → `AppException` mapping
- [x] `lib/core/network/interceptors/logging_interceptor.dart` — debug-only cURL-style console output
- [x] `lib/core/network/dio_client.dart` — `secureStorageProvider` (EncryptedSharedPreferences / Keychain) + `dioProvider` with all 3 interceptors

### Repository contracts
- [x] `lib/shared/domain/repositories/i_shipment_repository.dart` — abstract interface (getCustomerShipments, createShipment, cancelShipment, assignDriver, getPendingRequests, expressInterest)
- [x] `lib/shared/domain/repositories/i_trip_repository.dart` — abstract interface (getDriverTrips, postTrip, cancelTrip)
- [x] `lib/shared/domain/repositories/i_auth_repository.dart` — abstract interface (sendOtp, verifyOtp, createCustomerProfile, createDriverProfile, saveTokens, clearTokens, getAccessToken)

### Local implementations (dummy/dev)
- [x] `lib/shared/data/repositories/local_shipment_repository.dart` — in-memory, seeded from DummyShipments; 400 ms simulated delay
- [x] `lib/shared/data/repositories/local_trip_repository.dart` — in-memory, seeded from DummyTrips; 400 ms simulated delay
- [x] `lib/shared/data/repositories/local_auth_repository.dart` — dummy OTP (any 4-digit), dummy profile creation, no-op token storage

### Remote implementations (production-ready)
- [x] `lib/shared/data/repositories/remote_shipment_repository.dart` — full Dio/REST implementation for all 6 contract methods
- [x] `lib/shared/data/repositories/remote_trip_repository.dart` — Dio implementation for all 3 contract methods
- [x] `lib/shared/data/repositories/remote_auth_repository.dart` — Dio implementation for OTP + profile + token management

### One-line toggle
- [x] `lib/core/providers/repository_providers.dart` — single file to switch Local ↔ Remote for shipment, trip, auth repositories

### Entity serialisation
- [x] `user.dart` — `User.fromJson()` / `toJson()` added
- [x] `shipment.dart` — `ShipmentLocationJson`, `GoodsDetailJson` extensions + `Shipment.fromJson()` / `toJson()`
- [x] `driver_trip.dart` — `DriverTrip.fromJson()` / `toJson()` added

### Provider refactor (repository injection)
- [x] `customer_shipments_provider.dart` — injects `IShipmentRepository`; full optimistic-update pattern for addShipment, cancelShipment, selectDriver; refresh() for pull-to-refresh
- [x] `driver_trips_provider.dart` — injects `ITripRepository` + `Ref`; `_load()` on boot, optimistic postTrip with rollback, async cancelTrip with rollback, refresh()
- [x] `driver_shipment_requests_provider.dart` — injects `IShipmentRepository`; getPendingRequests() from repo, expressInterest() with optimistic update + rollback; added `isLoading`/`error` to state
- [x] `auth_provider.dart` — injects `IAuthRepository`; sendOtp/verifyOtp/submitProfile delegate fully to repo; logout clears secure-storage tokens; `_tryRestoreSession()` on boot

### Connectivity
- [x] `lib/core/providers/connectivity_provider.dart` — `connectivityProvider` (StreamProvider) + `isOnlineProvider` (bool convenience, optimistic default)
- [x] `lib/shared/presentation/widgets/feedback/connectivity_banner.dart` — animated `ClipRect`+`AnimatedContainer` banner that slides in/out; pushes content down (no overlay)
- [x] `app.dart` — `ref.watch(isOnlineProvider)` in builder; `ConnectivityBanner` wraps all content

### Not implemented (deferred to Session 8)
- [ ] Drift offline cache — local-first SQLite layer via Drift DAOs (deferred; Local repository covers dev needs)
- [ ] `build_runner` / Freezed — entities remain hand-written; Freezed migration deferred with Firebase refactor

---

## SESSION 8 — Firebase + Payments ⬜

- [ ] Firebase project setup (Android + iOS google-services / GoogleService-Info)
- [ ] Firebase Auth — phone OTP flow (replace mock auth)
- [ ] Firebase Firestore — shipment / trip collections
- [ ] FCM push notifications — driver interest, assignment, delivery alerts
- [ ] Razorpay integration — payment gateway for subscription & invoicing

---

## Design Tokens Reference

| Token | Value |
|-------|-------|
| Primary Orange | `#FF6D00` |
| Dark Orange | `#9F4200` |
| Background | `#F5FAFF` |
| Brown Text | `#594136` |
| Font | Manrope (800 ExtraBold, 600 SemiBold, 400 Regular) |
| Design Width | 390 px (iPhone 14 / Galaxy A54) |
| Design Height | 844 px |

## ID Taxonomy

| Prefix | Meaning |
|--------|---------|
| `TRK-` | Customer shipment request |
| `VB-`  | Driver-posted trip |
| `INV-` | Payment invoice |
| `USR-` | User account |
