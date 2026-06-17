import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incremented when the API returns 401 and tokens are cleared.
/// [AuthNotifier] listens and logs the user out.
final sessionExpiredSignalProvider = StateProvider<int>((ref) => 0);

void signalSessionExpired(WidgetRef ref) {
  ref.read(sessionExpiredSignalProvider.notifier).state++;
}

void signalSessionExpiredFromRef(Ref ref) {
  ref.read(sessionExpiredSignalProvider.notifier).state++;
}
