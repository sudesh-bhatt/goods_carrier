# FCM Push Notifications — Backend Setup Guide

Guide for the Goods Carrier backend team: how the mobile app sends device/FCM headers, how to store tokens, and how to send push notifications with Firebase Cloud Messaging (FCM).

---

## 1. Overview

The Flutter app already:

1. Initializes Firebase Messaging and obtains an FCM registration token
2. Attaches that token on **every API request** together with device metadata
3. Displays notifications in foreground / background / terminated states

Your job on the backend:

1. **Capture** `X-FCM-Token`, `X-Device-Id`, and `X-Device-Type` from authenticated requests
2. **Persist** them against the logged-in user (one user → many devices)
3. **Send** FCM messages when business events happen (shipment assigned, trip request, etc.)

Firebase project used by the mobile app: **`goods-carrier-46fa1`**

---

## 2. Headers the mobile app sends

Every Dio request includes:

| Header | Example | Required | Description |
|--------|---------|----------|-------------|
| `Authorization` | `Bearer 23\|…` | Yes (authed APIs) | Sanctum / API token |
| `Accept` | `application/json` | Yes | |
| `Content-Type` | `application/json` | Yes (non-multipart) | |
| `Accept-Language` | `en` / `hi` / `gu` | Yes | App locale |
| `X-Device-Id` | `eBTq_x19DKgziwHeQpyqkQ` | Yes | Stable per-install device id |
| `X-Device-Type` | `ios` or `android` | Yes | Platform |
| `X-FCM-Token` | `dXy9…:APA91b…` | When available | FCM registration token |

### Notes

- `X-FCM-Token` may be **missing** on the first few requests after install (before notification permission / FCM init). Treat it as optional; upsert when present.
- Token **rotates** (app reinstall, token refresh). Always upsert by `device_id` + `user_id`.
- When the user disables push in Settings, the app deletes the local FCM token and stops sending `X-FCM-Token`. You should mark that device inactive on the next authenticated request that arrives **without** the header (or add a dedicated unregister endpoint later).

### Example (logged request)

```http
GET /api/driver/dashboard HTTP/1.1
Host: goodscarrier.ajonetech.com
Authorization: Bearer 23|…
Accept: application/json
Accept-Language: en
X-Device-Id: eBTq_x19DKgziwHeQpyqkQ
X-Device-Type: ios
X-FCM-Token: dXy9abc…:APA91bH…
```

---

## 3. Recommended database schema

```sql
CREATE TABLE user_devices (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id         BIGINT UNSIGNED NOT NULL,
  device_id       VARCHAR(191) NOT NULL,
  device_type     ENUM('ios', 'android') NOT NULL,
  fcm_token       TEXT NULL,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  last_seen_at    TIMESTAMP NULL,
  created_at      TIMESTAMP NULL,
  updated_at      TIMESTAMP NULL,

  UNIQUE KEY user_devices_user_device_unique (user_id, device_id),
  KEY user_devices_user_active_index (user_id, is_active),
  CONSTRAINT user_devices_user_fk
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Upsert rules

On each authenticated request (middleware):

```text
IF X-FCM-Token present:
  upsert user_devices by (user_id, device_id)
    SET fcm_token, device_type, is_active = 1, last_seen_at = now()

ELSE IF authenticated:
  optionally: set is_active = 0 for that (user_id, device_id)
  OR leave token as-is until an explicit unregister API exists
```

---

## 4. Laravel middleware example

```php
<?php

namespace App\Http\Middleware;

use App\Models\UserDevice;
use Closure;
use Illuminate\Http\Request;

class CaptureDevicePushHeaders
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        if ($user === null) {
            return $next($request);
        }

        $deviceId = trim((string) $request->header('X-Device-Id', ''));
        $deviceType = strtolower(trim((string) $request->header('X-Device-Type', '')));
        $fcmToken = trim((string) $request->header('X-FCM-Token', ''));

        if ($deviceId === '' || ! in_array($deviceType, ['ios', 'android'], true)) {
            return $next($request);
        }

        if ($fcmToken !== '') {
            UserDevice::query()->updateOrCreate(
                [
                    'user_id' => $user->id,
                    'device_id' => $deviceId,
                ],
                [
                    'device_type' => $deviceType,
                    'fcm_token' => $fcmToken,
                    'is_active' => true,
                    'last_seen_at' => now(),
                ]
            );
        }

        return $next($request);
    }
}
```

Register globally for the `api` group (after `auth:sanctum`):

```php
// bootstrap/app.php or Kernel.php
$middleware->appendToGroup('api', [
    \App\Http\Middleware\CaptureDevicePushHeaders::class,
]);
```

---

## 5. Firebase Admin setup (server)

### 5.1 Create a service account

1. Open [Firebase Console](https://console.firebase.google.com/) → project **`goods-carrier-46fa1`**
2. **Project settings** → **Service accounts**
3. **Generate new private key** → download JSON
4. Store securely on the server (never commit to git)

Example path: `storage/app/firebase/service-account.json`

### 5.2 Environment variables

```env
FIREBASE_CREDENTIALS=/absolute/path/to/service-account.json
# or relative to storage:
# FIREBASE_CREDENTIALS=firebase/service-account.json
```

### 5.3 PHP package (recommended)

```bash
composer require kreait/firebase-php
```

```php
// config/services.php
'firebase' => [
    'credentials' => env('FIREBASE_CREDENTIALS'),
],
```

```php
<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FcmPushService
{
    public function sendToToken(
        string $fcmToken,
        string $title,
        string $body,
        array $data = [],
    ): void {
        $messaging = (new Factory)
            ->withServiceAccount(config('services.firebase.credentials'))
            ->createMessaging();

        $message = CloudMessage::withTarget('token', $fcmToken)
            ->withNotification(Notification::create($title, $body))
            ->withData($this->stringifyData($data));

        $messaging->send($message);
    }

    public function sendToUser(int $userId, string $title, string $body, array $data = []): void
    {
        $tokens = \App\Models\UserDevice::query()
            ->where('user_id', $userId)
            ->where('is_active', true)
            ->whereNotNull('fcm_token')
            ->pluck('fcm_token')
            ->filter()
            ->unique()
            ->values();

        foreach ($tokens as $token) {
            try {
                $this->sendToToken($token, $title, $body, $data);
            } catch (\Throwable $e) {
                // Invalid / expired token → deactivate device row
                report($e);
                \App\Models\UserDevice::query()
                    ->where('fcm_token', $token)
                    ->update(['is_active' => false]);
            }
        }
    }

    /** FCM data payload values must be strings. */
    private function stringifyData(array $data): array
    {
        $out = [];
        foreach ($data as $key => $value) {
            $out[(string) $key] = is_scalar($value) || $value === null
                ? (string) $value
                : json_encode($value);
        }
        return $out;
    }
}
```

---

## 6. When to send pushes (product events)

Wire `FcmPushService` into existing domain events / notifications. Examples:

| Event | Suggested title | Suggested `data` keys |
|-------|-----------------|------------------------|
| Customer posts shipment nearby | New shipment available | `type=shipment_available`, `shipment_id` |
| Driver requests a trip | New trip request | `type=trip_request_created`, `trip_id`, `request_id` |
| Customer accepts driver request | Shipment assigned | `type=shipment_request_accepted`, `shipment_id` |
| Driver updates trip status | Trip update | `type=trip_status_updated`, `trip_id`, `status` |
| Generic in-app notification created | (same as DB notification title) | `type=<notification.type>`, `notification_id` |

### Payload shape the app expects

Prefer **both** `notification` (title/body for system tray) and `data` (for deep links):

```json
{
  "notification": {
    "title": "New Trip Request",
    "body": "Jaydip has requested your trip #VB-YIPP."
  },
  "data": {
    "type": "trip_request_created",
    "trip_id": "42",
    "notification_id": "9"
  }
}
```

Keep `data` values as **strings**.

---

## 7. Optional dedicated register endpoint

Header capture on every request is enough for v1. If you prefer an explicit API later:

```http
POST /api/devices/fcm
Authorization: Bearer …
Content-Type: application/json

{
  "device_id": "eBTq_x19DKgziwHeQpyqkQ",
  "device_type": "ios",
  "fcm_token": "dXy9…:APA91b…"
}
```

```http
DELETE /api/devices/fcm
Authorization: Bearer …

{
  "device_id": "eBTq_x19DKgziwHeQpyqkQ"
}
```

The mobile app can be updated later to call these; today it relies on headers.

---

## 8. Testing checklist

### Backend

- [ ] Middleware stores token when `X-FCM-Token` is present
- [ ] Second login on same device updates `fcm_token` (no duplicate rows)
- [ ] Two devices for same user both receive pushes
- [ ] Invalid token is deactivated and does not block other devices
- [ ] Service account JSON is not in git / not world-readable

### End-to-end

1. Install app → allow notifications → log in as driver/customer
2. Confirm API logs show `X-Device-Id`, `X-Device-Type`, `X-FCM-Token`
3. Confirm `user_devices` row exists
4. Trigger a business event (or call `FcmPushService` from tinker)
5. Verify notification on:
   - Foreground
   - Background
   - App killed

### Quick Laravel tinker test

```php
app(\App\Services\FcmPushService::class)->sendToUser(
    userId: 17,
    title: 'Test push',
    body: 'Hello from Goods Carrier backend',
    data: ['type' => 'test', 'notification_id' => '0'],
);
```

---

## 9. Security & ops

- Treat FCM tokens like credentials (don’t log full tokens in production)
- Scope pushes to the correct user / role; never broadcast to all tokens
- Prefer queue jobs for sending (don’t block HTTP requests)
- Monitor FCM error codes (`UNREGISTERED`, `INVALID_ARGUMENT`) and deactivate devices
- Rotate service account keys if leaked

---

## 10. Mobile ↔ backend contract summary

| Responsibility | Owner |
|----------------|--------|
| Request notification permission | Mobile |
| Obtain / refresh FCM token | Mobile (Firebase SDK) |
| Send `X-Device-Id`, `X-Device-Type`, `X-FCM-Token` | Mobile (Dio `HeadersInterceptor`) |
| Persist tokens per user+device | Backend |
| Decide *when* to notify | Backend (domain events) |
| Send FCM HTTP v1 via Admin SDK | Backend |
| Display notification / deep link | Mobile |

---

## 11. Related mobile files

| File | Role |
|------|------|
| `lib/core/network/interceptors/headers_interceptor.dart` | Adds device + FCM headers |
| `lib/core/services/fcm_service.dart` | Token + foreground display |
| `lib/core/widgets/firebase_messaging_bootstrap.dart` | Starts FCM with app lifecycle |
| `lib/firebase_options.dart` | Firebase project options (`goods-carrier-46fa1`) |

---

## 12. Contact / next step

Once middleware + `user_devices` + one sample send path are live, tell the mobile team which notification `data.type` values are canonical so deep links can be finalized in the app.
