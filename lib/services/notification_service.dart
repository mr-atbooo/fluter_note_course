import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import '../services/sound_service.dart';

class NotificationService {
  static Future<void> showNotification(Map<String, dynamic> note) async {
    await notifications.show(
      id: note['id'] as int,
      title: note['title']?.toString(),
      body: note['content']?.toString(),
      notificationDetails: NotificationDetails(
        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.critical,
        ),
        windows: WindowsNotificationDetails(),
        android: AndroidNotificationDetails(
          'notes_channel',
          'Notes',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

// await SoundService.playLinux('ding.wav');
 SoundService.startRepeating('ding.wav');

  }
}
