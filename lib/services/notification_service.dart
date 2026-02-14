import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import '../main.dart';
import '../services/sound_service.dart';

class NotificationService {
  static Future<void> showNotification(Map<String, dynamic> note) async {
    // await notifications.show(
    //   id: note['id'] as int,
    //   title: note['title']?.toString(),
    //   body: note['content']?.toString(),
    //   notificationDetails: NotificationDetails(
    //     linux: LinuxNotificationDetails(
    //       urgency: LinuxNotificationUrgency.critical,
    //     ),
    //     windows: WindowsNotificationDetails(),
    //     android: AndroidNotificationDetails(
    //       'notes_channel',
    //       'Notes',
    //       importance: Importance.max,
    //       priority: Priority.high,
    //     ),
    //   ),
    // );
    await notifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: note['title'],
      body: note['content'],
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          fullScreenIntent: true, // 🔥 دي المفتاح
          category: AndroidNotificationCategory.alarm,
        ),

        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.critical,
        ),
      ),
    );

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // await SoundService.playLinux('ding.wav');
      SoundService.startRepeating('ding.wav');
    }
  }
}
