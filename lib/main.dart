import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/notification_scheduler.dart';
import 'screens/notes_screen.dart';

/// 🔔 Notifications instance
final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

/// 🧠 Helper
bool get isDesktop =>
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;

/// 🔔 Android channel (مهم يكون عالمي)
const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
  'notes_channel_v2', // غيره لو القناة القديمة موجودة
  'Notes',
  description: 'Notes notifications',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('ding'),
);

/// 🔔 Init notifications (Desktop + Mobile)
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

  await notifications.initialize(settings: initializationSettings);

  /// 🔥 Android notification channel بالصوت
  if (Platform.isAndroid) {
    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🖥️ Desktop-only setup
  if (isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await windowManager.ensureInitialized();
    await windowManager.setTitle('Notes');
  }

  /// 🔔 Notifications (كل المنصات)
  await initNotifications();

  runApp(MyApp());

  /// ⏰ Scheduler (Desktop + Mobile)
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
