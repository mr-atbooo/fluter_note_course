import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_edit_note_screen.dart';
import 'notes_screen_base.dart';

class NotesScreenMobile extends StatefulWidget {
  @override
  State<NotesScreenMobile> createState() => _NotesScreenMobileState();
}

class _NotesScreenMobileState extends NotesScreenBase<NotesScreenMobile> {
  bool showSearchBox = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملاحظات'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showSearchBox = !showSearchBox;
              });
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
          );
          loadNotes();
        },
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    return Column(
      children: [
        _buildQuickFilters(),
        if (showSearchBox) _buildSearchBox(),
        Expanded(child: buildNotesList()),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(onPressed: filterToday, child: Text('اليوم')),
          ElevatedButton(onPressed: filterThisWeek, child: Text('هذا الأسبوع')),
          ElevatedButton(onPressed: filterThisMonth, child: Text('هذا الشهر')),
          ElevatedButton(onPressed: loadNotes, child: Text('الكل')),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                fromDate = await _pickDate();
                setState(() {});
              },
              child: Text(
                fromDate == null
                    ? 'من تاريخ'
                    : DateFormat('yyyy/MM/dd').format(fromDate!),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                toDate = await _pickDate();
                setState(() {});
              },
              child: Text(
                toDate == null
                    ? 'إلى تاريخ'
                    : DateFormat('yyyy/MM/dd').format(toDate!),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _applyDateFilter,
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  void _applyDateFilter() {
    if (fromDate == null || toDate == null) return;

    filteredNotes = notes.where((note) {
      if (note.publishedAt == null) return false;

      final date = note.publishedAt!;
      return date.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
          date.isBefore(toDate!.add(const Duration(days: 1)));
    }).toList();

    setState(() {});
  }
}
