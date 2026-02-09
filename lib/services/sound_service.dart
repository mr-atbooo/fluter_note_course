import 'dart:io';
import 'package:process_run/process_run.dart';

class SoundService {
  static Future<void> playLinux(String fileName) async {
    if (!Platform.isLinux) return;

    final shell = Shell();

    try {
      await shell.run(
        'paplay assets/sounds/$fileName',
      );
    } catch (e) {
      print('Sound error: $e');
    }
  }
}
