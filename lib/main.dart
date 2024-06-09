import 'package:flutter/material.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/components/page_layout.dart';
import 'package:reef_mobile_app/service/LocalNotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  runApp(
    SplashApp(
      key: UniqueKey(), 
      displayOnInit: () {
        return const BottomNav();
      },
    ),
  );
}
