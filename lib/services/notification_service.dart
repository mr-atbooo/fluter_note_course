import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import '../main.dart';
import '../services/sound_service.dart';

class NotificationService {
  static Future<void> showNotification(Map<String, dynamic> note) async {

    await notifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: note['title'],
      body: note['content'],
      notificationDetails: NotificationDetails(
           //old code
        // android: AndroidNotificationDetails(
        //   androidChannel.id,
        //   androidChannel.name,
        //   channelDescription: androidChannel.description,
        //   importance: Importance.max,
        //   priority: Priority.high,
        //   playSound: true,
        //   fullScreenIntent: true, // 🔥 دي المفتاح
        //   category: AndroidNotificationCategory.alarm,
        // ),
        
        android: Platform.isAndroid
    ? const AndroidNotificationDetails(
        'notes_channel_mobile_v3',
        'Notes',
        // channelDescription: 'Mobile notifications',
        // importance: Importance.max,
        // priority: Priority.high,
        // playSound: true,
        // enableVibration: true,
channelDescription: 'Alarm style notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,

      )
    : null,


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
