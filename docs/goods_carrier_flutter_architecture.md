# Goods Carrier — Flutter App Architecture Plan

> Derived from full Figma prototype walkthrough (Customer Flow + Driver/Transporter Flow)  
> Target: Production-grade Flutter app, expert-level architecture  
> Market: India (INR, +91, GST, Hindi/Gujarati i18n)

---

## 1. App Overview & Business Model

**Goods Carrier** is a dual-role B2C logistics marketplace:

- **Customer (Shipper)** posts a shipment request with route, date, goods type, weight, and vehicle requirement. Multiple drivers bid/express interest. Customer selects one.
- **Driver/Transporter** browses available shipment requests, expresses interest, OR proactively posts their own trip availability (route + schedule + vehicle) for customers to discover.

This is fundamentally a **reverse auction / marketplace** — not a simple booking app. Both actors operate independently and are matched by the platform.

**ID Taxonomy**
| Entity | Prefix | Example |
|--------|--------|---------|
| Customer shipment request | `#TRK-` | `#TRK-8829` |
| Driver-posted trip | `#VB-` | `#VB-9928` |
| Invoice / Payment | `#INV-` | `#INV-7721` |

---

## 2. Design System Reference

### Colour Palette
```
Primary Orange   : #FF6D00  (CTAs, FAB, active states)
Dark Orange      : #9F4200  (progress bar start, dark accents)
Background       : #F5FAFF  (screen backgrounds)
Brown Text       : #594136  (secondary text)
White            : #FFFFFF  (cards, surfaces)
Success Green    : #4CAF50  (confirmation screens)
Warning Amber    : #FFF3E0  (fragile handling banner bg)
```

### Typography
- **Font Family**: Manrope (Google Fonts)
- **Weights used**: ExtraBold (800) for headings/IDs, SemiBold (600) for labels, Regular (400) for body
- **Price / ID text**: Manrope ExtraBold, Primary Orange

### Component Patterns
- Cards: white, 12px radius, subtle shadow
- Inputs: grey fill (`#F5F5F5`), 8px radius, no border at rest
- Buttons (primary): full-width, orange fill, 12px radius, white Manrope SemiBold
- Buttons (outline): white fill, orange border & text
- Bottom sheets: drag handle, white, 16px top radius
- Status chips: coloured pill with icon + label

---

## 3. Tech Stack

### Core
| Concern | Package | Rationale |
|---------|---------|-----------|
| State Management | `riverpod` + `flutter_riverpod` + `riverpod_generator` | Code-gen providers, compile-safe, scales cleanly across features |
| Navigation | `go_router` | Declarative, supports deep links, auth guards via `redirect`, role-based shell routes |
| DI | Riverpod providers | No need for `get_it`; providers are the DI graph |
| Code Gen | `build_runner`, `riverpod_generator`, `freezed`, `json_serializable` | All in one pipeline |

### Networking & Data
| Concern | Package |
|---------|---------|
| HTTP Client | `dio` with interceptors |
| REST Codegen | `retrofit` + `retrofit_generator` |
| Local Cache | `hive_flutter` (fast, typed, Flutter-native) |
| Secure Storage | `flutter_secure_storage` (JWT, refresh token) |
| Connectivity | `connectivity_plus` |

### Platform & Features
| Concern | Package |
|---------|---------|
| Maps | `google_maps_flutter` |
| Location | `geolocator` + `geocoding` |
| Push Notifications | `firebase_messaging` + `flutter_local_notifications` |
| Phone Auth / OTP | `firebase_auth` (phone sign-in) or custom OTP via Dio |
| Image Picker | `image_picker` |
| Date/Time Picker | `omni_datetime_range_picker` |
| Internationalisation | `flutter_localizations` + `intl` (English, Hindi, Gujarati) |
| In-App Payments | `razorpay_flutter` (INR, UPI, cards — Indian market standard) |
| Analytics | `firebase_analytics` |
| Crash Reporting | `firebase_crashlytics` |

### UI & Responsiveness
| Concern | Package | Rationale |
|---------|---------|-----------|
| Screen scaling | `flutter_screenutil` | Scales sizes/fonts proportionally against a fixed design baseline — handles Android xxhdpi vs iOS @3x uniformly |
| Platform detection | `dart:io` (`Platform`) | Conditional logic for iOS vs Android-specific insets, shadows, haptics |
| Device info | `device_info_plus` | Detect model/OS version where platform-specific workarounds are needed |

### Quality
| Concern | Package |
|---------|---------|
| Linting | `flutter_lints` + custom `analysis_options.yaml` |
| Testing | `mocktail`, `flutter_test`, `integration_test` |
| Golden tests | `golden_toolkit` |

---

## 4. Project Structure (Feature-First Clean Architecture)

```
lib/
├── main.dart
├── app.dart                          # MaterialApp.router + ProviderScope
│
├── core/
│   ├── config/
│   │   ├── app_config.dart           # env vars (base URL, keys)
│   │   └── flavors.dart              # dev / staging / prod
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_dimensions.dart
│   │   └── id_prefixes.dart          # TRK_, VB_, INV_
│   ├── di/
│   │   └── providers.dart            # shared infrastructure providers
│   ├── error/
│   │   ├── failures.dart             # sealed Failure hierarchy
│   │   └── exceptions.dart
│   ├── extensions/
│   │   ├── string_ext.dart
│   │   ├── datetime_ext.dart         # Indian date formats
│   │   └── num_ext.dart              # ₹ formatting
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── api_interceptors.dart     # auth, refresh, logging
│   │   └── network_info.dart
│   ├── storage/
│   │   ├── hive_service.dart
│   │   └── secure_storage_service.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_color_scheme.dart     # ThemeExtension with light/dark tokens
│   │   └── app_theme_data.dart
│   └── utils/
│       ├── validators.dart           # Indian phone, GST, vehicle number
│       ├── platform_utils.dart       # iOS vs Android inset helpers
│       └── logger.dart
│
├── shared/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   ├── shipment.dart
│   │   │   ├── trip.dart
│   │   │   └── notification_item.dart
│   │   └── value_objects/
│   │       ├── phone_number.dart     # +91 validation
│   │       └── vehicle_number.dart  # MH 02 CC 4156 format
│   ├── data/
│   │   ├── models/                  # Freezed + JsonSerializable DTOs
│   │   └── datasources/
│   └── presentation/
│       └── widgets/                 # shared UI components
│           ├── app_button.dart
│           ├── app_text_field.dart
│           ├── shipment_card.dart
│           ├── route_timeline.dart   # FROM ● — ● TO widget
│           ├── status_chip.dart
│           └── confirmation_screen.dart
│
└── features/
    ├── auth/
    ├── onboarding/
    ├── customer/
    │   ├── home/
    │   ├── book_shipment/
    │   ├── my_bookings/
    │   ├── shipment_detail/
    │   └── notifications/
    └── driver/
        ├── home/
        ├── shipment_detail/
        ├── add_trip/
        ├── my_trips/
        ├── notifications/
        └── profile/
```

Each feature follows the same internal layering:

```
features/[feature]/
├── domain/
│   ├── entities/
│   ├── repositories/          # abstract interface
│   └── use_cases/
├── data/
│   ├── models/                # DTO with fromJson/toJson
│   ├── datasources/
│   │   ├── remote_datasource.dart
│   │   └── local_datasource.dart
│   └── repositories/          # concrete implementation
└── presentation/
    ├── providers/             # Riverpod (riverpod_generator)
    ├── screens/
    └── widgets/
```

---

## 5. Navigation Architecture (GoRouter)

```dart
// core/router/app_router.dart

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) => _globalRedirect(state, authState),
    routes: [
      GoRoute(path: '/splash',     builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/role',       builder: (_, __) => const RoleSelectionScreen()),
      GoRoute(path: '/language',   builder: (_, __) => const LanguageScreen()),
      GoRoute(path: '/terms',      builder: (_, __) => const TermsScreen()),
      GoRoute(path: '/phone',      builder: (_, __) => const PhoneScreen()),
      GoRoute(path: '/otp',        builder: (_, s) => OtpScreen(phone: s.extra as String)),
      
      // Profile setup — role-branching
      GoRoute(path: '/profile/customer', builder: (_, __) => const CustomerProfileSetupScreen()),
      GoRoute(path: '/profile/driver',   builder: (_, __) => const DriverProfileSetupScreen()),

      // --- CUSTOMER SHELL ---
      ShellRoute(
        navigatorKey: _customerNav,
        builder: (_, __, child) => CustomerShell(child: child),
        routes: [
          GoRoute(path: '/customer/home',           builder: (_, __) => const CustomerHomeScreen()),
          GoRoute(path: '/customer/book',           builder: (_, __) => const BookShipmentScreen()),
          GoRoute(path: '/customer/bookings',       builder: (_, __) => const MyBookingsScreen()),
          GoRoute(
            path: '/customer/shipment/:id',
            builder: (_, s) => CustomerShipmentDetailScreen(id: s.pathParameters['id']!),
          ),
          GoRoute(path: '/customer/notifications',  builder: (_, __) => const CustomerNotificationsScreen()),
        ],
      ),

      // --- DRIVER SHELL ---
      ShellRoute(
        navigatorKey: _driverNav,
        builder: (_, __, child) => DriverShell(child: child),
        routes: [
          GoRoute(path: '/driver/home',             builder: (_, __) => const DriverHomeScreen()),
          GoRoute(
            path: '/driver/shipment/:id',
            builder: (_, s) => DriverShipmentDetailScreen(id: s.pathParameters['id']!),
          ),
          GoRoute(path: '/driver/add-trip',         builder: (_, __) => const AddTripScreen()),
          GoRoute(path: '/driver/my-trips',         builder: (_, __) => const MyTripsScreen()),
          GoRoute(path: '/driver/notifications',    builder: (_, __) => const DriverNotificationsScreen()),
          GoRoute(path: '/driver/profile',          builder: (_, __) => const DriverProfileScreen()),
        ],
      ),
    ],
  );
});

String? _globalRedirect(GoRouterState state, AsyncValue<UserRole?> authState) {
  return authState.when(
    data: (role) {
      final isOnboarding = state.matchedLocation.startsWith('/role') ||
                           state.matchedLocation.startsWith('/otp');
      if (role == null && !isOnboarding) return '/role';
      if (role == UserRole.customer && state.matchedLocation.startsWith('/driver')) return '/customer/home';
      if (role == UserRole.driver   && state.matchedLocation.startsWith('/customer')) return '/driver/home';
      return null;
    },
    loading: () => '/splash',
    error: (_, __) => '/role',
  );
}
```

---

## 6. Domain Entities

### UserRole
```dart
enum UserRole { customer, driver }
```

### User (Freezed)
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String phone,             // +91XXXXXXXXXX
    required String email,
    required UserRole role,
    String? profileImageUrl,
    String? address,
    // Driver-only
    String? companyName,
    String? gstName,
    String? gstNumber,
    String? businessEmail,
    String? businessPhone,
  }) = _User;
}
```

### Shipment (Customer Request)
```dart
@freezed
class Shipment with _$Shipment {
  const factory Shipment({
    required String id,                   // TRK-XXXX
    required String customerId,
    required ShipmentLocation pickup,
    required ShipmentLocation drop,
    required DateTime pickupDateTime,
    required DateTime dropDateTime,
    required GoodsDetail goods,
    required VehicleType vehicleType,
    required ShipmentStatus status,
    required double estimatedPrice,
    String? assignedDriverId,
    String? assignedDriverTripId,
  }) = _Shipment;
}

@freezed
class ShipmentLocation with _$ShipmentLocation {
  const factory ShipmentLocation({
    required String city,
    required String fullAddress,
    required double lat,
    required double lng,
  }) = _ShipmentLocation;
}

@freezed
class GoodsDetail with _$GoodsDetail {
  const factory GoodsDetail({
    required String type,               // Electronics, FMCG, etc.
    required double weightKg,
    required bool isFragile,
    String? specialInstructions,
  }) = _GoodsDetail;
}

enum ShipmentStatus { pending, interestReceived, assigned, inTransit, delivered, cancelled }

enum VehicleType { mini, pickupTruck, truck, heavyDuty }
```

### DriverTrip (Driver's Posted Route)
```dart
@freezed
class DriverTrip with _$DriverTrip {
  const factory DriverTrip({
    required String id,                  // VB-XXXX
    required String driverId,
    required String fromCity,
    required String toCity,
    required DateTime estimatedStartDate,
    required DateTime estimatedEndDate,
    required VehicleType vehicleCategory,
    required String vehicleNumber,       // MH 02 CC 4156
    required double loadCapacityTons,
    required double estimatedPrice,
    required TripStatus status,
  }) = _DriverTrip;
}

enum TripStatus { active, pendingConfirmation, confirmed, completed, cancelled }
```

---

## 7. State Management — Riverpod Patterns

### Auth Provider
```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserRole?> build() async {
    final token = await ref.read(secureStorageProvider).getToken();
    if (token == null) return null;
    final user = await ref.read(userRepositoryProvider).getCurrentUser();
    return user.role;
  }

  Future<void> sendOtp(String phone) async { ... }
  Future<void> verifyOtp(String otp) async { ... }
  Future<void> signOut() async { ... }
}
```

### Customer Home — Active Shipments Feed
```dart
@riverpod
class CustomerShipmentsNotifier extends _$CustomerShipmentsNotifier {
  @override
  Future<List<Shipment>> build() =>
      ref.read(shipmentRepositoryProvider).getMyShipments();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(shipmentRepositoryProvider).getMyShipments(),
    );
  }
}
```

### Driver Home — Available Shipment Requests (Paginated)
```dart
@riverpod
class DriverShipmentFeedNotifier extends _$DriverShipmentFeedNotifier {
  static const _pageSize = 20;
  
  @override
  Future<PaginatedResult<Shipment>> build() =>
      ref.read(shipmentRepositoryProvider).getAvailableShipments(
        page: 1, limit: _pageSize,
      );

  Future<void> expressInterest(String shipmentId) async {
    await ref.read(shipmentRepositoryProvider).expressInterest(shipmentId);
    ref.invalidateSelf();
  }
}
```

### Filter State (Driver Home)
```dart
@freezed
class ShipmentFilter with _$ShipmentFilter {
  const factory ShipmentFilter({
    String? fromCity,
    String? toCity,
    DateTime? pickupDate,
    VehicleType? vehicleClass,
  }) = _ShipmentFilter;
}

@riverpod
class ShipmentFilterNotifier extends _$ShipmentFilterNotifier {
  @override
  ShipmentFilter build() => const ShipmentFilter();
  
  void setFromCity(String city) => state = state.copyWith(fromCity: city);
  void setPickupDate(DateTime date) => state = state.copyWith(pickupDate: date);
  void setVehicleClass(VehicleType type) => state = state.copyWith(vehicleClass: type);
  void clear() => state = const ShipmentFilter();
}
```

---

## 8. Feature Breakdown

### 8.1 Auth & Onboarding (Shared)

**Screens:**
1. `SplashScreen` — animated progress bar `#9F4200 → #FF6D00`, checks auth state, auto-navigates
2. `RoleSelectionScreen` — Customer vs Driver toggle selection
3. `LanguageScreen` — English / Hindi / Gujarati radio selection, persists to `SharedPreferences`
4. `TermsScreen` — scrollable T&C, "I Agree" CTA unlocks progression
5. `PhoneScreen` — +91 masked input, "Send OTP" → Firebase phone auth
6. `OtpScreen` — 6-digit OTP input with 30s resend timer
7. `CustomerProfileSetupScreen` — Name, Email, Address
8. `DriverProfileSetupScreen` — Name, Email + Business section (Company Name, GST Name, GST Number, Business Email, Business Phone)

**Key technical notes:**
- Language selection drives `Localizations.override` wrapping — store as `Locale` in `HiveBox`
- GST Number: validate with regex `[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}`
- Indian vehicle number: `[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}`

---

### 8.2 Customer Feature Module

#### CustomerHomeScreen
- App bar: "Good Carrier" wordmark + 🔔 (badge) + avatar
- Search bar: "Search by destination or shipment ID"
- Section header: `● N PENDING / ACTIVE BOOKINGS` (orange dot)
- `ListView.builder` of `ShipmentCard` widgets
- FAB: "+" → `/customer/book`
- Pull-to-refresh → `ref.invalidate(customerShipmentsProvider)`

#### BookShipmentScreen (Multi-step form)
Multi-step Stepper or PageView with 3 sections:

**Step 1 — Route**
- Pickup Location (city + address) — maps autocomplete
- Drop Location (city + address)
- Pickup Date/Time (date picker + time picker)

**Step 2 — Goods**
- Goods Type: dropdown (Electronics, FMCG, Textile, Auto Parts, Fragile, etc.)
- Weight (kg)
- Fragile toggle → shows ⚠ banner in detail views

**Step 3 — Vehicle**
- Vehicle Type: chip selector (Mini / Pickup Truck / Truck / Heavy Duty)
- Estimated price autocalculated from route distance + weight + vehicle type
- Review summary card → Submit

**Confirmation:**
- Full-page success state (green ✓, TRK- ID, route summary, price, "Back to Home" CTA)

#### CustomerShipmentDetailScreen
- Shipment ID + status chip (Pending / Assigned / In Transit / Delivered)
- Route timeline (pickup ● — ● drop with addresses + timestamps)
- Goods details card (type, weight, fragile banner)
- Vehicle requirement card
- "Interested Drivers" section (list of drivers who expressed interest — customer selects one)
- ⋮ overflow → "Report Shipment"

#### MyBookingsScreen
- Filter tabs: All / Active / Completed / Cancelled
- Sorted list of `ShipmentCard`

#### CustomerNotificationsScreen
- Grouped by date (Today / Yesterday / Earlier)
- Types: Driver interest received, Driver assigned, Shipment picked up, Delivered, Payment
- Mark all read (✓✓ top-right action)

---

### 8.3 Driver Feature Module

#### DriverHomeScreen
- App bar: "Good Carrier" + 🔔 + avatar
- Search bar: "Search by destination or vehicle" + filter icon
- Section header: `● 12 ACTIVE SHIPMENTS`
- `ListView.builder` of `ShipmentCard` (driver variant — shows Estimated Pay instead of "My booking")
- FAB: "+" → `/driver/add-trip`
- Shipment card actions: "View Details" → `/driver/shipment/:id`

#### DriverShipmentDetailScreen (node `1-916`)
- App bar: "Shipment Details" + ← + ⋮ (→ "Report a shipment?")
- Header card: `#TRK-XXXX` + `₹XXXX Estimated Pay`
- Route timeline: FROM (city, state) → TO (city)
- Date + vehicle requirement row
- GOODS DETAILS card: Type chip + Weight chip + ⚠ Fragile banner (if applicable)
- PICKUP LOCATION: address + datetime
- DROP LOCATION: address + datetime
- VEHICLE REQUIREMENT: icon + type + capacity
- CTA: **"Show Interest"** → `ConfirmRequestBottomSheet`

#### ConfirmRequestBottomSheet
```dart
// Truck icon + "Confirm Request" title
// "Are you sure you want to show interest in this shipment?
//  The customer will be notified."
// [No]  [Yes, Continue]  →  RequestSentSuccessfullyScreen
```

#### AddTripScreen (node `1-3634`)
Three form sections:

**Route Information**
- FROM LOCATION: city text field
- TO LOCATION: city text field

**Schedule**
- EST. START DATE (date picker) + EST. START TIME (time picker)
- EST. END DATE + EST. END TIME

**Vehicle & Capacity**
- VEHICLE CATEGORY: dropdown (Mini / Pickup Truck / Heavy Duty Truck 10-20T)
- VEHICLE NUMBER: Indian format text field with regex validation
- LOAD CAPACITY: numeric + EST. WEIGHT TYPE (TON)
- EST. PRICE: ₹ prefixed input

**Driver Info**
- DRIVER NAME
- DRIVER PHONE (+91)

Submit → `TripPostedSuccessfullyScreen` (green ✓, VB- ID, route summary)

#### FilterSearchBottomSheet
- Route Details: FROM city / TO city inputs
- PICKUP DATE: horizontal day-chip scroll (TODAY, WED, THU, FRI…) + Calendar button
- VEHICLE CLASS: chip multi-select (Mini, Pickup, Truck)
- "Apply Filters" CTA → invalidates driver feed provider

#### DriverNotificationsScreen
Types:
- `trip_request_accepted` — Customer accepted your interest (#VB-XXXX)
- `trip_cancelled` — Trip cancelled, en route to [city]
- `subscription_purchase` — Invoice #INV-XXXX payment successful
- `shipment_drop_success` — Delivery confirmed
- `payment_success` — Funds arriving in 2-3 days
- Date-grouped, unread badge count in bell icon

#### DriverProfileScreen
- Avatar + name + phone
- Edit profile (personal details)
- Business Details section (Company, GST, etc.)
- My Vehicles (registered vehicle numbers)
- Subscription status + invoice history
- Language preference
- Logout

---

## 9. Networking Layer

### Retrofit API Interface (example)
```dart
@RestApi()
abstract class ShipmentApi {
  factory ShipmentApi(Dio dio) = _ShipmentApi;

  @GET('/shipments/my')
  Future<PaginatedResponse<ShipmentDto>> getMyShipments(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/shipments/available')
  Future<PaginatedResponse<ShipmentDto>> getAvailableShipments(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('from') String? fromCity,
    @Query('to') String? toCity,
    @Query('date') String? date,
    @Query('vehicle') String? vehicleType,
  );

  @POST('/shipments')
  Future<ShipmentDto> createShipment(@Body() CreateShipmentRequest request);

  @POST('/shipments/{id}/interest')
  Future<void> expressInterest(@Path('id') String shipmentId);

  @GET('/shipments/{id}')
  Future<ShipmentDto> getShipmentById(@Path('id') String id);
}
```

### Dio Interceptors
```dart
// 1. AuthInterceptor — injects Bearer token, handles 401 refresh
// 2. RetryInterceptor — 3 retries with exponential backoff
// 3. LogInterceptor — debug/dev only, redacts tokens
// 4. ConnectivityInterceptor — throws NoInternetFailure before request
```

---

## 10. Push Notification Handling

```dart
// FCM message types
enum NotificationType {
  driverInterestReceived,  // → customer/shipment/:id
  shipmentAssigned,        // → customer/shipment/:id
  shipmentPickedUp,        // → customer/shipment/:id
  shipmentDelivered,       // → customer/shipment/:id
  tripRequestAccepted,     // → driver/my-trips
  tripCancelled,           // → driver/notifications
  subscriptionPayment,     // → driver/notifications
  paymentSuccess,          // → driver/notifications
}
```

Deep-link routing from FCM payload:
```dart
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  final type = NotificationType.values.byName(message.data['type']);
  final targetId = message.data['id'];
  // route via GoRouter
  router.go('/customer/shipment/$targetId');
});
```

---

## 11. Localisation

```
lib/l10n/
├── app_en.arb
├── app_hi.arb   (Hindi)
└── app_gu.arb   (Gujarati)
```

Key strings to localise: all screen titles, form labels, CTA text, empty state messages, notification templates.

Currency formatting:
```dart
// core/extensions/num_ext.dart
extension CurrencyFormat on num {
  String get inr => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  ).format(this);
}
// Usage: 2100.inr  →  "₹2,100"
```

---

## 12. Development Phases

### Phase 1 — Foundation (Sprint 1-2)
- Project scaffold: flavors (dev/staging/prod), `analysis_options.yaml`, CI pipeline
- Core: theme, colours, typography, shared widgets
- GoRouter shell with placeholder screens
- Hive + SecureStorage setup
- Dio client + interceptors

### Phase 2 — Auth & Onboarding (Sprint 3)
- Splash animation (linear progress `#9F4200 → #FF6D00`)
- Role selection, language selection, T&C
- Firebase phone auth + OTP screen
- Customer profile setup + Driver profile setup (with business fields + GST validation)

### Phase 3 — Customer Flow (Sprint 4-5)
- Customer Home (shipment feed, pull-to-refresh)
- Book Shipment (3-step form, maps integration, price estimation)
- My Bookings (tabs: All / Active / Completed)
- Shipment Detail (timeline, interested drivers list, report)
- Customer Notifications

### Phase 4 — Driver Flow (Sprint 6-7)
- Driver Home (shipment request feed, search + filter)
- Shipment Detail (driver view, show interest flow, confirm bottom sheet)
- Add Trip (full form with vehicle validation)
- Driver Notifications (subscription, payment, trip events)
- Driver Profile + business details edit

### Phase 5 — Platform & Polish (Sprint 8)
- FCM deep-link routing
- Razorpay subscription integration (driver subscription model)
- Localisation (Hindi + Gujarati ARB files)
- Offline handling (Hive cache, stale-while-revalidate)
- Skeleton loaders for all list screens
- Empty states for zero-data screens
- Error handling (no internet, server error, timeout)

### Phase 6 — QA & Release (Sprint 9-10)
- Unit tests: use cases, repository implementations
- Widget tests: form validation, card rendering
- Integration tests: full onboarding → booking flow
- Golden tests: key screens (home, shipment detail, confirmation)
- Performance profiling (60fps on mid-range Android)
- Play Store + App Store release build setup

---

## 13. Key Architecture Decisions — Rationale

| Decision | Choice | Why |
|----------|--------|-----|
| State management | Riverpod + code gen | Type-safe, testable, no BuildContext leakage, scales well across dual-role complexity |
| Navigation | GoRouter | Handles role-based redirect logic cleanly; deep link support critical for FCM |
| Feature-first layout | vs layer-first | Each feature is independently navigable; reduces cross-feature coupling |
| Freezed for models | vs plain classes | Free `copyWith`, `==`, `hashCode`, JSON serialisation, sealed classes for failures |
| No GetX / BLoC | — | Riverpod + GoRouter covers all needs without BLoC boilerplate or GetX magic strings |
| Indian phone auth | Firebase Auth | OTP via SMS, handles carrier routing in India automatically |
| Razorpay | vs Stripe | Razorpay is the Indian standard; supports UPI, net banking, INR natively |
| Hive cache | vs SQLite | Schema-free, Flutter-native, fast reads for shipment feed cache |

---

---

## 14. Cross-Platform Responsiveness — Android & iOS

Flutter uses a single logical pixel system but the underlying hardware differs significantly between Android and iOS devices. Handling this correctly means addressing five distinct concerns: screen density, safe area insets, font scaling, platform-specific chrome, and keyboard behaviour.

---

### 14.1 The Core Problem — Android vs iOS Physical Differences

| Concern | Android | iOS |
|---------|---------|-----|
| Screen densities | mdpi / hdpi / xhdpi / xxhdpi / xxxhdpi | @2x / @3x |
| Status bar height | 24dp (varies — Samsung OneUI adds extra) | 44–59pt (notch), 20pt (older), 54pt (Dynamic Island) |
| Bottom safe area | Gesture nav = 0dp, 3-button nav = 48dp, 2-button = 32dp | Home indicator = 34pt (notched), 0pt (iPhone SE) |
| Camera cutout | Punch-hole (centre or corner, varies by OEM) | Notch / Dynamic Island (always top-centre) |
| Font scaling | Accessibility up to 2.0× (user-set) | Dynamic Type — can go very large |
| Haptics | `HapticFeedback` API — not all devices support | Taptic Engine — consistent |
| Keyboard insets | Adds to `viewInsets.bottom` | Adds to `viewInsets.bottom` + raises scaffold |
| Shadow rendering | Elevation shadows (Material) | No direct equivalent — use `BoxShadow` |

Flutter's `SafeArea` widget handles most of this — but you need to understand **when to use it and when not to**, and how to get the raw inset values for custom layouts.

---

### 14.2 ScreenUtil Setup — Design Baseline

Design baseline from Figma: **390 × 844** (iPhone 14 logical resolution). This is also identical to Samsung Galaxy A54 logical width — the most common mid-range Android in India. Perfect single baseline.

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Extend content behind status bar and nav bar on Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,      // Android status bar icons
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Make the app truly edge-to-edge on Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 844),  // Figma baseline = iPhone 14 = Galaxy A54
      minTextAdapt: true,                // prevents font from going below design size
      splitScreenMode: true,             // handles Android split-screen / foldables
      builder: (_, __) => const ProviderScope(child: GoodsCarrierApp()),
    ),
  );
}
```

---

### 14.3 Size Extension Methods

```dart
// core/extensions/size_ext.dart

extension SizeExt on num {
  /// Scales proportionally to screen WIDTH — use for horizontal sizes,
  /// left/right padding, icon widths, card widths.
  double get w => ScreenUtil().setWidth(this);

  /// Scales proportionally to screen HEIGHT — use for vertical spacing,
  /// button heights, vertical padding.
  double get h => ScreenUtil().setHeight(this);

  /// Font size — scales with screen AND respects OS accessibility text scale,
  /// but clamped (see 14.5 below).
  double get sp => ScreenUtil().setSp(this);

  /// Radius — uses the smaller of width/height scale to avoid distortion
  /// on unusual aspect ratios (budget Android devices, foldables).
  double get r => ScreenUtil().radius(this);
}
```

Usage rule of thumb:
- Padding, margin, icon size → `.w` (horizontal) / `.h` (vertical)
- `BorderRadius`, corner radii → `.r`
- All `fontSize` → `.sp`
- Never hardcode raw `double` pixel values in UI code

---

### 14.4 Safe Area & Inset Handling

**The golden rule:** Always wrap screens in `SafeArea`. But for custom UI like the splash screen, map overlays, or bottom sheets that need to paint behind the system chrome, use `MediaQuery` insets directly.

```dart
// core/utils/platform_utils.dart

class PlatformUtils {
  /// Status bar height — varies between Android OEMs and iOS models.
  /// Use this instead of hardcoding 24 or 44.
  static double statusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  /// Bottom safe area:
  /// - iOS notched: 34pt (home indicator)
  /// - iOS SE / older: 0pt
  /// - Android gesture nav: 0dp
  /// - Android 3-button nav: ~48dp
  /// - Android 2-button nav: ~32dp
  static double bottomInset(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  /// Keyboard height when visible — use for scrollable forms to avoid
  /// the keyboard covering input fields.
  static double keyboardHeight(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;

  /// True when keyboard is up.
  static bool isKeyboardVisible(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 50;

  /// Safe content height — screen height minus status bar minus bottom inset.
  /// Useful for full-screen layouts like the splash screen progress bar.
  static double safeContentHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.size.height - mq.padding.top - mq.padding.bottom;
  }

  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
}
```

**`padding` vs `viewPadding` vs `viewInsets` — the difference:**

```
MediaQuery.of(context).padding        → safe area insets EXCLUDING keyboard
MediaQuery.of(context).viewPadding    → safe area insets ALWAYS (ignores keyboard)
MediaQuery.of(context).viewInsets     → space consumed by keyboard (0 when hidden)
```

Use `viewPadding.bottom` (not `padding.bottom`) for bottom navigation bars — when the keyboard opens, `padding.bottom` collapses to 0 on Android, which shifts the nav bar. `viewPadding` stays constant.

```dart
// BottomNavigationBar wrapper — uses viewPadding to stay stable during keyboard
class AppBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      color: context.colors.surface,
      child: const _NavBarContent(),
    );
  }
}
```

---

### 14.5 Font Scaling — Clamping for Indian Market

Indian Android users frequently set font scale to maximum (1.5×–2×) in accessibility settings for readability. Without clamping, UI breaks badly — text overflows cards, wraps inside buttons, truncates shipment IDs.

**Clamp `textScaleFactor` at the app level:**

```dart
// app.dart — inside MaterialApp.router builder
MaterialApp.router(
  builder: (context, child) {
    // Clamp text scale: allow up to 1.2× (accessible) but prevent beyond that
    // This prevents UI breakage while still respecting mild accessibility needs.
    final mq = MediaQuery.of(context);
    final clampedScale = mq.textScaleFactor.clamp(0.85, 1.2);

    return MediaQuery(
      data: mq.copyWith(textScaleFactor: clampedScale),
      child: child!,
    );
  },
  // ...
)
```

**Note:** Do not clamp to 1.0 — that removes accessibility entirely. 1.2 gives enough room for users who need slightly larger text without breaking the layout.

---

### 14.6 Platform-Specific Chrome Behaviour

**Status bar icon colours:**

On Android, icon colour (dark/light) is controlled via `SystemUiOverlayStyle`.
On iOS, it follows `Brightness` set on `AppBar` or `CupertinoNavigationBar`.

```dart
// core/utils/platform_utils.dart

static void setStatusBarStyle({required bool isDark}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Android: dark icons on light background, light icons on dark background
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      // iOS: opposite naming convention to Android
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      // Android navigation bar
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ),
  );
}
```

Call this in `ThemeNotifier` whenever theme changes:
```dart
void _save(ThemeMode mode, String key) {
  state = mode;
  Hive.box('settings').put(_themeKey, key);
  PlatformUtils.setStatusBarStyle(isDark: mode == ThemeMode.dark);
}
```

**Haptic feedback — platform-aware:**

```dart
// core/utils/platform_utils.dart

static Future<void> lightImpact() async {
  if (Platform.isIOS) {
    await HapticFeedback.lightImpact();    // Taptic Engine — reliable
  } else {
    // Android — check if the device supports it before calling
    await HapticFeedback.selectionClick(); // lighter than lightImpact on Android
  }
}

static Future<void> successImpact() async {
  await HapticFeedback.mediumImpact();
}
```

Use `successImpact()` on: OTP verified, Shipment submitted, Request Sent Successfully, Trip Posted Successfully.

---

### 14.7 Keyboard Avoidance — iOS vs Android Behaviour

Flutter's `Scaffold` with `resizeToAvoidBottomInset: true` (default) handles most cases, but bottom sheets and custom modal routes need manual handling.

```dart
// Pattern for forms inside bottom sheets (Add Trip, Filter Search, Book Shipment)

class _FormBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom = keyboard height
    // padding.bottom = home indicator / nav bar
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafe    = MediaQuery.of(context).padding.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboardPadding > 0
            ? keyboardPadding           // keyboard is up — pad by keyboard height
            : bottomSafe,               // keyboard hidden — pad by safe area only
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: const _FormContent(),
      ),
    );
  }
}
```

**Android-specific: `WindowInsets` edge-to-edge mode**

Since we set `SystemUiMode.edgeToEdge` in `main.dart`, the Scaffold paints behind the navigation bar on Android. This is the correct modern approach — but every screen's bottom content must be padded by `MediaQuery.of(context).padding.bottom`. `SafeArea` does this automatically, so always wrap screen bodies in `SafeArea`.

---

### 14.8 Platform-Adaptive Widget Choices

Some widgets should look native on each platform. For this logistics app, the key ones are:

```dart
// Date/time pickers — use platform-native feel
Future<DateTime?> pickDate(BuildContext context) async {
  if (Platform.isIOS) {
    // CupertinoDatePicker inside a showModalBottomSheet
    return _showCupertinoDatePicker(context);
  } else {
    // Material DatePicker
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColorScheme.light.primary,
          ),
        ),
        child: child!,
      ),
    );
  }
}

// Loading indicator — match platform convention
Widget platformLoader() {
  return Platform.isIOS
      ? const CupertinoActivityIndicator()
      : CircularProgressIndicator(
          color: AppColorScheme.light.primary,
          strokeWidth: 2.5,
        );
}

// Alert dialogs — platform-native
Future<bool?> showConfirmDialog(BuildContext context, String message) {
  if (Platform.isIOS) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
          CupertinoDialogAction(isDefaultAction: true, child: const Text('Confirm'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );
  } else {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );
  }
}
```

---

### 14.9 Common Indian Android Device Gotchas

These are real issues seen on devices dominant in the Indian market:

| Device / Issue | Problem | Fix |
|---------------|---------|-----|
| Samsung Galaxy A-series (OneUI) | Status bar height is 28dp not 24dp | Always use `MediaQuery.padding.top`, never hardcode |
| Redmi / MIUI devices | `viewInsets.bottom` fires late on keyboard open | Use `AnimatedPadding` with a 200ms curve (see 14.7) |
| Realme / ColorOS | Gesture nav bar shows partially even in edge-to-edge | `SystemUiMode.edgeToEdge` + `padding.bottom` SafeArea fixes it |
| Budget Android (<4GB RAM) | `ScreenUtil().setSp()` can be slow on first render | Call inside a `Builder` after first frame using `addPostFrameCallback` |
| OnePlus OxygenOS | Different font rendering — Manrope renders slightly heavier | Acceptable, no fix needed |
| iPhone SE (2nd/3rd gen) | No home indicator — `padding.bottom` = 0 | SafeArea handles it; never hardcode 34pt |
| iPhone 14 Pro / 15 Pro | Dynamic Island reduces usable top area | `padding.top` = 59pt — SafeArea handles it |
| Older iPhones (XR, 11) | Regular notch — `padding.top` = 44pt | SafeArea handles it |

---

## 15. Theme Architecture — Light & Dark Mode

---

### 15.1 ThemeExtension — Custom Design Tokens

Material 3's `ColorScheme` doesn't cover app-specific tokens like `orangeText`, `fragileBannerBackground`, `cardShadow`, or `routeTimelineDot`. Use `ThemeExtension<T>` to register your own token set alongside `ThemeData`.

```dart
// core/theme/app_color_scheme.dart

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.success,
    required this.warningBackground,   // Fragile handling banner fill
    required this.error,
    required this.orangeText,          // price, shipment IDs
    required this.brownText,           // #594136 secondary labels
    required this.notificationUnread,  // unread notification row background
    required this.routeTimelineDot,    // ● on route timeline widget
    required this.statusBarOverlay,    // colour of status bar overlay layer
  });

  final Color primary;
  final Color primaryDark;
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color inputFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color success;
  final Color warningBackground;
  final Color error;
  final Color orangeText;
  final Color brownText;
  final Color notificationUnread;
  final Color routeTimelineDot;
  final Color statusBarOverlay;

  // ─── LIGHT ───────────────────────────────────────────────
  static const light = AppColorScheme(
    primary:             Color(0xFFFF6D00),
    primaryDark:         Color(0xFF9F4200),
    background:          Color(0xFFF5FAFF),
    surface:             Color(0xFFFFFFFF),
    cardBackground:      Color(0xFFFFFFFF),
    inputFill:           Color(0xFFF5F5F5),
    textPrimary:         Color(0xFF1A1A1A),
    textSecondary:       Color(0xFF6B6B6B),
    textHint:            Color(0xFFAAAAAA),
    divider:             Color(0xFFE8E8E8),
    success:             Color(0xFF4CAF50),
    warningBackground:   Color(0xFFFFF3E0),
    error:               Color(0xFFD32F2F),
    orangeText:          Color(0xFFFF6D00),
    brownText:           Color(0xFF594136),
    notificationUnread:  Color(0xFFFFF8F3),
    routeTimelineDot:    Color(0xFFFF6D00),
    statusBarOverlay:    Colors.transparent,
  );

  // ─── DARK ────────────────────────────────────────────────
  static const dark = AppColorScheme(
    primary:             Color(0xFFFF6D00),
    primaryDark:         Color(0xFFFF8C3A),
    background:          Color(0xFF0F1117),
    surface:             Color(0xFF1C1E26),
    cardBackground:      Color(0xFF242630),
    inputFill:           Color(0xFF2A2C38),
    textPrimary:         Color(0xFFF2F2F2),
    textSecondary:       Color(0xFFB0B0B0),
    textHint:            Color(0xFF6B6B6B),
    divider:             Color(0xFF2E2E2E),
    success:             Color(0xFF66BB6A),
    warningBackground:   Color(0xFF3D2800),
    error:               Color(0xFFEF5350),
    orangeText:          Color(0xFFFF8C3A),
    brownText:           Color(0xFFD4A899),
    notificationUnread:  Color(0xFF2D1E00),
    routeTimelineDot:    Color(0xFFFF8C3A),
    statusBarOverlay:    Colors.transparent,
  );

  @override
  AppColorScheme copyWith({Color? primary, Color? background, /* ... */}) => AppColorScheme(
    primary:            primary           ?? this.primary,
    primaryDark:        primaryDark       ?? this.primaryDark,
    background:         background        ?? this.background,
    surface:            surface           ?? this.surface,
    cardBackground:     cardBackground    ?? this.cardBackground,
    inputFill:          inputFill         ?? this.inputFill,
    textPrimary:        textPrimary       ?? this.textPrimary,
    textSecondary:      textSecondary     ?? this.textSecondary,
    textHint:           textHint          ?? this.textHint,
    divider:            divider           ?? this.divider,
    success:            success           ?? this.success,
    warningBackground:  warningBackground ?? this.warningBackground,
    error:              error             ?? this.error,
    orangeText:         orangeText        ?? this.orangeText,
    brownText:          brownText         ?? this.brownText,
    notificationUnread: notificationUnread ?? this.notificationUnread,
    routeTimelineDot:   routeTimelineDot  ?? this.routeTimelineDot,
    statusBarOverlay:   statusBarOverlay  ?? this.statusBarOverlay,
  );

  // Used by Flutter for animated theme transitions
  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      primary:            Color.lerp(primary, other.primary, t)!,
      primaryDark:        Color.lerp(primaryDark, other.primaryDark, t)!,
      background:         Color.lerp(background, other.background, t)!,
      surface:            Color.lerp(surface, other.surface, t)!,
      cardBackground:     Color.lerp(cardBackground, other.cardBackground, t)!,
      inputFill:          Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary:        Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary:      Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint:           Color.lerp(textHint, other.textHint, t)!,
      divider:            Color.lerp(divider, other.divider, t)!,
      success:            Color.lerp(success, other.success, t)!,
      warningBackground:  Color.lerp(warningBackground, other.warningBackground, t)!,
      error:              Color.lerp(error, other.error, t)!,
      orangeText:         Color.lerp(orangeText, other.orangeText, t)!,
      brownText:          Color.lerp(brownText, other.brownText, t)!,
      notificationUnread: Color.lerp(notificationUnread, other.notificationUnread, t)!,
      routeTimelineDot:   Color.lerp(routeTimelineDot, other.routeTimelineDot, t)!,
      statusBarOverlay:   Color.lerp(statusBarOverlay, other.statusBarOverlay, t)!,
    );
  }
}
```

---

### 15.2 BuildContext Extension — Zero-boilerplate Access

```dart
// core/extensions/theme_ext.dart

extension AppThemeExt on BuildContext {
  // Access custom tokens — context.colors.primary, context.colors.cardBackground
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Platform-aware shadow — iOS uses BoxShadow, Android uses elevation
  List<BoxShadow> get cardShadow => isDark
      ? [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12.r, offset: Offset(0, 4.h))]
      : [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8.r, offset: Offset(0, 2.h))];
}
```

---

### 15.3 AppTheme — Building Both ThemeData Objects

```dart
// core/theme/app_theme.dart

class AppTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    appColors: AppColorScheme.light,
    seedColor: const Color(0xFFFF6D00),
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    appColors: AppColorScheme.dark,
    seedColor: const Color(0xFFFF6D00),
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColorScheme appColors,
    required Color seedColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Manrope',

      // Register custom tokens — accessible as Theme.of(ctx).extension<AppColorScheme>()
      extensions: [appColors],

      scaffoldBackgroundColor: appColors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: appColors.surface,
        foregroundColor: appColors.textPrimary,
        surfaceTintColor: Colors.transparent,   // disables Material 3 tint on scroll
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
          color: appColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: appColors.textPrimary, size: 24.r),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: appColors.cardBackground,
        elevation: Platform.isIOS ? 0 : 2,    // iOS uses shadow, Android uses elevation
        shadowColor: Colors.black12,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: appColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: appColors.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: appColors.textHint, fontSize: 14.sp),
        labelStyle: TextStyle(color: appColors.textSecondary, fontSize: 12.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: appColors.primary.withOpacity(0.4),
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
          textStyle: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appColors.primary,
          side: BorderSide(color: appColors.primary, width: 1.5),
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: appColors.divider,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        showDragHandle: true,
        dragHandleColor: appColors.divider,
        dragHandleSize: Size(40.w, 4.h),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: appColors.inputFill,
        selectedColor: appColors.primary,
        labelStyle: TextStyle(fontSize: 13.sp, fontFamily: 'Manrope'),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
```

---

### 15.4 Riverpod ThemeNotifier — Persisted with Hive

```dart
// features/settings/presentation/providers/theme_provider.dart

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _box = 'settings';
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final stored = Hive.box(_box).get(_key, defaultValue: 'system') as String;
    return _fromString(stored);
  }

  void setLight()  => _persist(ThemeMode.light,  'light');
  void setDark()   => _persist(ThemeMode.dark,   'dark');
  void setSystem() => _persist(ThemeMode.system, 'system');

  void toggle() => state == ThemeMode.dark
      ? _persist(ThemeMode.light, 'light')
      : _persist(ThemeMode.dark,  'dark');

  void _persist(ThemeMode mode, String value) {
    state = mode;
    Hive.box(_box).put(_key, value);
    // Keep status bar icons in sync with theme on Android
    PlatformUtils.setStatusBarStyle(isDark: mode == ThemeMode.dark);
  }

  ThemeMode _fromString(String value) => switch (value) {
    'light'  => ThemeMode.light,
    'dark'   => ThemeMode.dark,
    _        => ThemeMode.system,
  };
}
```

---

### 15.5 Wiring Everything in app.dart

```dart
// app.dart

class GoodsCarrierApp extends ConsumerWidget {
  const GoodsCarrierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final router    = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Good Carrier',
      debugShowCheckedModeBanner: false,
      theme:      AppTheme.light(),
      darkTheme:  AppTheme.dark(),
      themeMode:  themeMode,
      routerConfig: router,

      // Clamp font scale — critical for Indian market (see Section 14.5)
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaleFactor: mq.textScaleFactor.clamp(0.85, 1.2),
          ),
          child: child!,
        );
      },

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

---

### 15.6 Quick Reference — What Goes Where

| Concern | Tool |
|---------|------|
| Size, padding, icon size | `.w` / `.h` / `.r` from `ScreenUtil` |
| Font size | `.sp` from `ScreenUtil` |
| Safe area (status bar, home indicator, nav bar) | `SafeArea` widget or `MediaQuery.padding` |
| Keyboard height | `MediaQuery.viewInsets.bottom` |
| Bottom nav bar inset (stable during keyboard) | `MediaQuery.viewPadding.bottom` |
| Status bar icon colour | `PlatformUtils.setStatusBarStyle()` |
| Any colour / design token | `context.colors.xxx` |
| Light/dark toggle | `ref.read(themeNotifierProvider.notifier).toggle()` |
| Adding a new colour token | Add field to `AppColorScheme` — both `light` and `dark` const objects |
| Platform-native dialog | `PlatformUtils.showConfirmDialog()` |
| Card shadow | `context.cardShadow` (extension) |
| Text scale control | Clamped globally in `app.dart` builder |

---

*Architecture plan version 1.1 — Goods Carrier logistics app*  
*Sections 14 & 15 added: Android/iOS responsiveness + Light/Dark theme architecture*  
*Based on Figma prototype walkthrough: Customer Flow (node 1:2100) + Driver Flow (node 1:899)*  
*File: `YxnNResvDQnbkcPhGejtxa` — Mobile App UI (Developer)*
