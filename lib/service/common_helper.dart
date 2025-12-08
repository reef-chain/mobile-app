import 'dart:async';
import 'package:flutter/foundation.dart';

// helpers/listen_with_retry.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Dynamic-friendly listener with onError/onDone and exponential backoff re-subscribe.
/// Works with any Stream (avoids generic mismatches).
StreamSubscription listenWithRetryDynamic({
  required Stream stream,
  required String name,
  required void Function(dynamic data) onData,
  Duration initialDelay = const Duration(milliseconds: 500),
  Duration maxDelay = const Duration(seconds: 8),
}) {
  int attempt = 0;
  late StreamSubscription sub;

  Duration _nextDelay() {
    attempt++;
    final ms = initialDelay.inMilliseconds * (1 << (attempt - 1));
    final clamped = ms > maxDelay.inMilliseconds ? maxDelay.inMilliseconds : ms;
    return Duration(milliseconds: clamped);
  }

  void _subscribe() {
    sub = stream.listen(
          (data) {
        attempt = 0; // reset on success
        try {
          onData(data);
        } catch (e, st) {
          debugPrint('[$name] onData EXCEPTION: $e\n$st');
        }
      },
      onError: (e, st) {
        debugPrint('[$name] ERROR: $e\n$st');
        final delay = _nextDelay();
        debugPrint('[$name] Retrying in ${delay.inMilliseconds} ms');
        Future.delayed(delay, _subscribe);
      },
      onDone: () {
        debugPrint('[$name] DONE. Re-subscribing…');
        Future.delayed(_nextDelay(), _subscribe);
      },
      cancelOnError: true,
    );
  }

  _subscribe();
  return sub;
}
