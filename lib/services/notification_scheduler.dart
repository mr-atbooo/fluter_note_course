import 'dart:async';
import '../db/notes_db.dart';
import '../services/notification_service.dart';

class NotificationScheduler {
  static Timer? _timer;
  static final NotesDB _db = NotesDB();

  static void start() {
    _timer ??= Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();

      // final notes = await _db.rawQuery('''
      //   SELECT * FROM notes
      //   WHERE published_at IS NOT NULL
      //   AND published_at <= ?
      //   AND notified = 0
      // ''', [now.toIso8601String()]);
      final notes = await _db.getDueNotifications(now.toIso8601String());

      for (var note in notes) {
        await NotificationService.showNotification(note);
        await _db.markAsNotified(note['id'] as int);
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
