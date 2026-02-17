import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async'; // لإدارة StreamController

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

/// Stream لتغيير عنوان النافذة
final windowTitleController = StreamController<String>.broadcast();

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
          AndroidFlutterLocalNotificationsPlugin
        >()
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

    // ✅ الطريقة الصحيحة: استخدام WindowOptions
    WindowOptions windowOptions = WindowOptions(
      size: const Size(1200, 800),
      minimumSize: const Size(900, 600),
      maximumSize: const Size(1920, 1080), // اختياري
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Notes - All Notes',
      // resizable: true, // مهم: يسمح بتغيير الحجم لكن ضمن الحدود
      // minimizable: true,
      // maximizable: true,
      alwaysOnTop: false,
    );

    // await windowManager.setTitle('Notes');
    // تعيين العنوان الافتراضي
    await windowManager.setTitle('Notes - All Notes');

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // ✅ تأكيد إضافي للحد الأدنى (لأن بعض أنظمة لينكس بتتجاهل الإعدادات)
    await windowManager.setMinimumSize(const Size(900, 600));

    // ✅ للينكس تحديداً: إعادة تعيين الحدود
    if (Platform.isLinux) {
      // بعض مديري النوافذ في لينكس محتاجين تأكيد إضافي
      await Future.delayed(const Duration(milliseconds: 500));
      await windowManager.setMinimumSize(const Size(900, 600));
    }

    // الاستماع لتغييرات العنوان
    windowTitleController.stream.listen((title) {
      windowManager.setTitle('Notes - $title');
    });
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
