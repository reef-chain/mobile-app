// lib/utils/state_safety.dart
import 'dart:async';
import 'package:flutter/widgets.dart';

mixin AutoCancelSubscriptions<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription<dynamic>> _subs = [];

  S addSub<S extends StreamSubscription>(S sub) {
    _subs.add(sub);
    return sub;
  }

  void setStateSafe(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void dispose() {
    for (final s in _subs) {
      try { s.cancel(); } catch (_) {}
    }
    _subs.clear();
    super.dispose();
  }
}
