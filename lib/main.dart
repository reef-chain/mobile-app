import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/components/page_layout.dart';

/*void main() async {
  runApp(
    SplashApp(
      key: UniqueKey(), 
      displayOnInit: () {
        return const BottomNav();
      },
    ),
  );
}*/


Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment("SENTRY_DSN", defaultValue: "");
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      SplashApp(
        key: UniqueKey(),
        displayOnInit: () {
          return const BottomNav();
        },
      ),
    ),
  );
}