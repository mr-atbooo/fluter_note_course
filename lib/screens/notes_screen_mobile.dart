import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_edit_note_screen.dart';
import 'notes_screen_base.dart';

class NotesScreenMobile extends StatefulWidget {
  final VoidCallback toggleTheme;

  const NotesScreenMobile({required this.toggleTheme});

  @override
  State<NotesScreenMobile> createState() => _NotesScreenMobileState();
}

class _NotesScreenMobileState extends NotesScreenBase<NotesScreenMobile> {
  bool showSearchBox = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
          ),
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

      //  backgroundColor: const Color(0xFF3B82F6), // أزرق حديث
      //                           foregroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
          );
          loadNotes();
        },
        child: const Icon(Icons.add, color: Colors.white),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFilterChip("All Notes", loadNotes),
            const SizedBox(width: 8),
            _buildFilterChip("Today", filterToday),
            const SizedBox(width: 8),
            _buildFilterChip("This Week", filterThisWeek),
            const SizedBox(width: 8),
            _buildFilterChip("This Month", filterThisMonth),
            const SizedBox(width: 8),
            _buildFilterChip("Important", filterImportant),
            const SizedBox(width: 8),
            _buildFilterChip("Recurring", filterRecurring),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null, // null = يستخدم لون الزر الافتراضي
        foregroundColor: isDark ? Theme.of(context).primaryColor : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).primaryColor),
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
