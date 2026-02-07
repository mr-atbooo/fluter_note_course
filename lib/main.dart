import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/notes_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 مهم للـ Desktop
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }


  
  // 🔥 هذا يغير عنوان النافذة حتماً
  await windowManager.ensureInitialized();
  await windowManager.setTitle('Notes');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      home: NotesScreen(),
    );
  }
}
