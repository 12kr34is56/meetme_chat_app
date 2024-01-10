import 'dart:developer';

import 'package:Meet_me/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'firebase_options.dart';
import 'screen/login_screen/email_login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);

    var result = await FlutterNotificationChannel.registerNotificationChannel(
  description: 'For showing message notification',
  id: 'chats',
  importance: NotificationImportance.IMPORTANCE_HIGH,
  name: 'Chats',);
  log("Notification : $result");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(
        iconTheme: IconThemeData(weight: 25),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w500),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        )
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }

}
