import 'package:flutter/material.dart';

/// Guards [setState] with a [mounted] check — use instead of raw [setState].
///
/// Apply with `extends State<T> with SafeSetStateMixin` (or on [ConsumerState]).
mixin SafeSetStateMixin<T extends StatefulWidget> on State<T> {
  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }
}
