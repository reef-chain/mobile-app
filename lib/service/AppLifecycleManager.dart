import 'package:flutter/material.dart';

class AppLifecycleManager with WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();

  factory AppLifecycleManager() {
    return _instance;
  }

  AppLifecycleManager._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  bool _isAppForeground = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppForeground = true;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _isAppForeground = false;
        break;
    }
  }

  bool get isAppInForeground => _isAppForeground;

}