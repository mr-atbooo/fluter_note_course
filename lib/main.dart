import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // ✅ استخدام العادية للموبايل
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // ✅ للـ Desktop
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

// /// Stream لتغيير عنوان النافذة
// final windowTitleController = StreamController<String>.broadcast();
// ✅ استخدام StreamController للـ Desktop فقط
StreamController<String>? windowTitleController;

/// 🔔 Init notifications (Desktop + Mobile)
// Future<void> initNotifications() async {
//   const initializationSettings = InitializationSettings(
//     linux: LinuxInitializationSettings(defaultActionName: 'Open'),
//     windows: WindowsInitializationSettings(
//       appName: 'Flutter Notes',
//       appUserModelId: 'com.atbooo.flutter.notes',
//       guid: '123e4567-e89b-12d3-a456-426614174000',
//     ),
//     macOS: DarwinInitializationSettings(),
//     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//   );

//   await notifications.initialize(settings: initializationSettings);

//   /// 🔥 Android notification channel بالصوت
//   if (Platform.isAndroid) {
//     await notifications
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(androidChannel);
//   }
// }
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

  /// 🔥 Android channel
  if (Platform.isAndroid) {
    final androidImplementation = notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // إنشاء القناة
    await androidImplementation?.createNotificationChannel(androidChannel);

    // 🔔 طلب صلاحية الإشعارات (مهم جداً Android 13+)
    await androidImplementation?.requestNotificationsPermission();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🖥️ Desktop-only setup
  if (isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await windowManager.ensureInitialized();

    windowTitleController = StreamController<String>.broadcast();

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
    windowTitleController!.stream.listen((title) {
      windowManager.setTitle('Notes - $title');
    });
  } else {
    // ✅ للموبايل: نستخدم sqflite العادية
    databaseFactory = databaseFactory; // تأكيد استخدام المكتبة العادية
  }

  /// 🔔 Notifications (كل المنصات)
  await initNotifications();

  runApp(MyApp());

  /// ⏰ Scheduler (Desktop + Mobile)
  NotificationScheduler.start();
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system; // افتراضي يتبع النظام

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // لو عايز، ممكن تحدد الوضع الابتدائي بناءً على الـ system brightness
    final systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (systemBrightness == Brightness.dark) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
  }

  @override
  void didChangePlatformBrightness() {
    final systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    setState(() {
      _themeMode = systemBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }
  // void toggleTheme() {
  //   final currentBrightness =
  //       WidgetsBinding.instance.platformDispatcher.platformBrightness;

  //   final isCurrentlyDark =
  //       _themeMode == ThemeMode.dark ||
  //       (_themeMode == ThemeMode.system &&
  //           currentBrightness == Brightness.dark);

  //   setState(() {
  //     _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "Cairo",
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFEDEBEB),
          surface: Color.fromARGB(255, 255, 253, 253),
          secondaryFixed: Color(0xFF424242),
          secondaryFixedDim: Color(0xFFDDDDE5),
          secondaryContainer: Color(0xFFE0E0E0),
        ),
        primaryColor: Color(0xFF292A31),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "Cairo",
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF292A31),
          surface: Color(0xFF1D1D22),
          secondaryFixed: Color.fromARGB(255, 255, 255, 255),
          secondaryFixedDim: Color.fromARGB(255, 61, 62, 73),
          secondaryContainer: Color.fromARGB(255, 61, 62, 73),
        ),
        primaryColor: Color(0xFFEDEBEB),
      ),
      home: NotesScreen(toggleTheme: toggleTheme),
    );
  }
}
