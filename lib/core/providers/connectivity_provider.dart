import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Raw stream ───────────────────────────────────────────────────────────────

/// Emits a new [List<ConnectivityResult>] whenever the device's network
/// connectivity changes.
///
/// The stream is sourced from [Connectivity.onConnectivityChanged] which fires
/// immediately on subscription and then on every subsequent state change.
///
/// Treat the list as a set — the device can be simultaneously connected via
/// Wi-Fi and cellular:
///   - empty / [ConnectivityResult.none] only → offline
///   - any other result present              → online
final connectivityProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// ─── Convenience bool ─────────────────────────────────────────────────────────

/// `true` when at least one active connectivity type is present
/// (wifi, mobile, ethernet, vpn, bluetooth …).
///
/// Returns `true` optimistically while the stream has not yet emitted
/// (i.e., during the very first frame after cold start).
final isOnlineProvider = Provider<bool>((ref) {
  final result = ref.watch(connectivityProvider).valueOrNull;
  if (result == null) return true; // optimistic before first emission
  return result.any((r) => r != ConnectivityResult.none);
});
