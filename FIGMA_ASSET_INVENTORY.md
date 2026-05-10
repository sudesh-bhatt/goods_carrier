# Goods Carrier — Figma Asset Export Inventory

Compiled from full Customer flow audit + Driver Home + design-file review.  
Export all assets **before** starting Session 2 widget work.

---

## How to export from Figma

1. Open the **main design file** (not the prototype link)
2. Select the layer in the left panel
3. In the right panel → **Export** → choose format + resolution
4. For SVG icons: Export → **SVG** (no resize needed)
5. For PNG images/illustrations: Export → **PNG** at **1x, 2x, 3x**
6. Drop files into `assets/icons/` or `assets/images/` as noted below

---

## 1 · App Images  (`assets/images/`)

| File | Description | Format | Notes |
|------|-------------|--------|-------|
| `logo.png` | Orange gradient "G" shaped as a location pin with a truck silhouette inside | PNG 1x/2x/3x | Used on Splash, Role Selection header, and app bar on some screens |
| `illustration_empty_shipments.png` | Empty state — no active shipments | PNG 1x/2x/3x | Customer home + history empty state |
| `illustration_empty_trips.png` | Empty state — no posted trips | PNG 1x/2x/3x | Driver "My Trip" empty state |
| `illustration_empty_notifications.png` | Empty state — no notifications | PNG 1x/2x/3x | Both roles |
| `illustration_role_customer.png` | Customer role card artwork (truck + goods) | PNG 1x/2x/3x | Role Selection screen |
| `illustration_role_driver.png` | Driver role card artwork (steering wheel / driver) | PNG 1x/2x/3x | Role Selection screen |
| `illustration_tracking_map.png` | Route map placeholder (shown on Tracking screen) | PNG 1x/2x/3x | Static map placeholder until Google Maps integrated |

> **Tip:** If illustrations are vector in Figma, export as SVG instead and rename extension to `.svg` — place in `assets/images/` still.

---

## 2 · Navigation Bar Icons  (`assets/icons/`)

These appear in the bottom `BottomNavigationBar` for both roles. Each icon needs two states: **default** (grey/inactive) and **active** (orange `#FF6D00`).

| File | Screen | Role |
|------|--------|------|
| `nav_home_default.svg` | Home tab, inactive | Both |
| `nav_home_active.svg` | Home tab, active (orange) | Both |
| `nav_shipments_default.svg` | Shipments tab, inactive | Customer only |
| `nav_shipments_active.svg` | Shipments tab, active | Customer only |
| `nav_my_trip_default.svg` | My Trip tab, inactive | Driver only |
| `nav_my_trip_active.svg` | My Trip tab, active | Driver only |
| `nav_notifications_default.svg` | Notifications tab, inactive | Both |
| `nav_notifications_active.svg` | Notifications tab, active | Both |
| `nav_profile_default.svg` | Profile tab, inactive | Both |
| `nav_profile_active.svg` | Profile tab, active | Both |

> **Alternative:** If Figma uses a single icon with colour override, export one SVG per icon — tint colour applied in Flutter via `ColorFilter` or `color` param on `SvgPicture`.

---

## 3 · App Bar Icons  (`assets/icons/`)

| File | Description | Where used |
|------|-------------|------------|
| `ic_bell.svg` | Notification bell — outlined, orange tint when unread badge | Both roles, top-right app bar |
| `ic_menu.svg` | Hamburger / three-line menu | **Driver only** — left side of app bar on Driver Home |
| `ic_back_chevron.svg` | Left-pointing chevron (back navigation) | All detail screens |
| `ic_share.svg` | Share icon (if present on detail screens) | Optional |

---

## 4 · Search & Filter Icons  (`assets/icons/`)

| File | Description | Where used |
|------|-------------|------------|
| `ic_search.svg` | Magnifying glass | Search bar prefix on both Home screens |
| `ic_filter.svg` | Sliders / filter icon (3 horizontal lines with circles) | Right side of search bar, Driver Home |

---

## 5 · Shipment & Trip Card Icons  (`assets/icons/`)

These appear inside `ShipmentCard` / `DriverTripCard` rows.

| File | Description | Where used |
|------|-------------|------------|
| `ic_location_origin.svg` | Filled orange circle — pickup origin dot | Route timeline top dot |
| `ic_location_dest.svg` | Filled dark/brown circle — destination dot | Route timeline bottom dot |
| `ic_route_line.svg` | Vertical dotted connector line between origin + dest | Route timeline (or draw in code) |
| `ic_calendar.svg` | Calendar / date icon | Card meta row — pickup date |
| `ic_truck_mini.svg` | Small truck silhouette | Card meta row — vehicle type |
| `ic_weight.svg` | Weight / capacity icon | Card meta row — goods weight |
| `ic_fragile.svg` | Warning triangle or fragile symbol | `FragileBanner` component |

---

## 6 · Form & Input Icons  (`assets/icons/`)

| File | Description | Where used |
|------|-------------|------------|
| `ic_phone.svg` | Phone handset | PhoneInputScreen prefix |
| `ic_flag_india.svg` | Indian flag (or `+91` text — check design) | Country code prefix |
| `ic_person.svg` | Person/user silhouette | Name field prefix, Profile screen |
| `ic_email.svg` | Envelope | Email field prefix |
| `ic_business.svg` | Building / briefcase | GST / business name field |
| `ic_vehicle_number.svg` | Number plate / ID card | Driver vehicle number field |
| `ic_eye.svg` | Eye (show/hide toggle — if any password fields exist) | Optional |
| `ic_check_circle.svg` | Filled green/orange check — OTP verified tick | OTP verification success |
| `ic_otp_lock.svg` | Lock or shield — OTP screen hero icon | OTP screen top illustration |

---

## 7 · Vehicle Type Icons  (`assets/icons/`)

Used on DriverProfileSetupScreen, PostTripScreen, and vehicle selector chips.

| File | Vehicle | Capacity label |
|------|---------|---------------|
| `vehicle_mini.svg` | Mini | Up to 1 ton |
| `vehicle_pickup_truck.svg` | Pickup Truck | 1–3 tons |
| `vehicle_truck.svg` | Truck | 3–7 tons |
| `vehicle_heavy_duty.svg` | Heavy Duty | 7+ tons |

---

## 8 · Status & Feedback Icons  (`assets/icons/`)

Used inside `StatusChip` and notification tiles.

| File | Status | Colour |
|------|--------|--------|
| `ic_status_pending.svg` | Pending | Amber `#FFC107` |
| `ic_status_active.svg` | Active / In Progress | Blue `#2196F3` |
| `ic_status_completed.svg` | Completed / Delivered | Green `#4CAF50` |
| `ic_status_cancelled.svg` | Cancelled | Red `#F44336` |
| `ic_status_assigned.svg` | Driver Assigned | Teal `#009688` |

---

## 9 · Misc / Settings Icons  (`assets/icons/`)

| File | Description | Where used |
|------|-------------|------------|
| `ic_language.svg` | Globe or text "A" — language selector | LanguageSelectionScreen, Settings |
| `ic_theme_light.svg` | Sun icon | Theme toggle |
| `ic_theme_dark.svg` | Moon icon | Theme toggle |
| `ic_logout.svg` | Exit/logout arrow | Profile screen |
| `ic_chevron_right.svg` | Right-pointing chevron | Settings list rows |
| `ic_edit.svg` | Pencil icon | Edit profile CTA |
| `ic_verified.svg` | Shield with tick — subscription badge | Driver Profile, subscription tier |
| `ic_quote.svg` | Price tag / INR symbol | Express Interest quote input |
| `ic_plus.svg` | Plus / "+" icon | FAB button |

---

## 10 · Correction: OTP is 4-digit  ⚠️

The Figma design shows **4 OTP boxes**, not 6.  
`lib/core/utils/validators.dart` currently validates 6 digits — **must be changed to 4**.

---

## Known Unknowns (Driver screens not fully captured)

The following Driver screens were not fully captured due to Figma canvas rendering (WebGL).  
Based on Customer-flow symmetry, these screens will follow the same design patterns:

| Screen | Expected Content |
|--------|-----------------|
| **Driver My Trip** | List of VB-XXXX trip cards (same card structure as DriverTripCard in domain entity). Empty state with `illustration_empty_trips.png`. FAB to post new trip. |
| **Driver Notifications** | Same `NotificationTile` component as Customer — different notification copy (interest received, shipment matched). |
| **Driver Profile** | Name, phone, vehicle type, vehicle number, capacity. Subscription tier badge (`ic_verified.svg`). Theme + language toggles. |
| **Express Interest Sheet** | Bottom sheet: shipment summary mini-card at top, INR quote text field (`ic_quote.svg` prefix), "Submit Quote" CTA (orange `AppButton`). |
| **Post Trip Screen** | Multi-step or single form: From city, To city, Date picker, Vehicle type selector (4 chips), Capacity input. "Post Trip" orange CTA. |

---

## pubspec.yaml additions needed

```yaml
dependencies:
  flutter_svg: ^2.0.10+1   # add this — all icons are custom SVGs

assets:
  - assets/images/
  - assets/icons/
  # assets/ folders already declared; just add flutter_svg dep
```

Run after adding:
```bash
flutter pub get
```

---

## Quick export checklist

- [ ] Logo (PNG 1x/2x/3x)
- [ ] 7 illustrations (PNG 1x/2x/3x each)
- [ ] 10 nav bar icons × 2 states = 20 SVGs
- [ ] 4 app bar icons
- [ ] 2 search icons
- [ ] 7 card icons
- [ ] 9 form icons
- [ ] 4 vehicle icons
- [ ] 5 status icons
- [ ] 9 misc/settings icons
- [ ] Place all in `assets/icons/` or `assets/images/` as listed above
- [ ] Run `flutter pub get` after adding `flutter_svg` to pubspec

**Total: ~60 SVGs + ~24 PNG exports (8 images × 3 resolutions)**
