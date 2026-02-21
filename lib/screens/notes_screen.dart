import 'package:flutter/material.dart';

import 'notes_screen_desktop.dart';
import 'notes_screen_mobile.dart';

class NotesScreen extends StatefulWidget {
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // فصل كامل بين التصميمين
    if (width >= 900) {
      return NotesScreenDesktop();
    } else {
      return NotesScreenMobile();
    }
  }
}