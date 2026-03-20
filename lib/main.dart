import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reef_mobile_app/components/page_layout_anukul.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:reef_mobile_app/pages/splash_screen.dart';
import 'package:reef_mobile_app/service/AppLifecycleManager.dart';
import 'package:reef_mobile_app/service/LocalNotificationService.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  AppLifecycleManager();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          navigatorKey: navigatorKey, // ✅ very important

          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          home: SplashApp(
            key: const Key('reef_splash_app'),
            displayOnInit: () {
              return const BottomNav();
            },
          ),
        );
      },
    );
  }
}
