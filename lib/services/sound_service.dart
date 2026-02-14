import 'dart:io';
import 'package:process_run/process_run.dart';
import 'dart:async';


class SoundService {
  // static Future<void> playLinux(String fileName) async {
  //   if (!Platform.isLinux) return;

  //   final shell = Shell();

  //   try {
  //     await shell.run(
  //       'paplay assets/sounds/$fileName',
  //     );
  //   } catch (e) {
  //     print('Sound error: $e');
  //   }
  // }

 static Timer? _timer;

  static void startRepeating(String fileName,
      {Duration interval = const Duration(seconds: 3)}) {
    if (!Platform.isLinux) return;

    _timer ??= Timer.periodic(interval, (_) async {
      final shell = Shell();
      await shell.run(
        'paplay assets/sounds/$fileName',
      );
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

}
