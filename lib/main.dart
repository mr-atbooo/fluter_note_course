import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/notification_scheduler.dart';

import 'screens/notes_screen.dart';


final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const initializationSettings = InitializationSettings(
    linux: LinuxInitializationSettings(defaultActionName: 'Open'),
     windows: WindowsInitializationSettings(
      appName: 'Flutter Notes',
      appUserModelId: 'com.atbooo.flutter.notes',
      guid: '123e4567-e89b-12d3-a456-426614174000',
    ),
    macOS: DarwinInitializationSettings(),
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  await notifications.initialize(
  settings: initializationSettings,
);

}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 مهم للـ Desktop
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 🔥 هذا يغير عنوان النافذة حتماً
  await windowManager.ensureInitialized();
  await windowManager.setTitle('Notes');

   // 🔔 Notifications
  await initNotifications();

  runApp(MyApp());

  // 🔥 هنا بقى
  NotificationScheduler.start();
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Cairo"),
      home: NotesScreen(),
    );
  }
}
