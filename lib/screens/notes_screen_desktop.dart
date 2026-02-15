import 'package:flutter/material.dart';
import 'add_edit_note_screen.dart';
import 'notes_screen_base.dart';

class NotesScreenDesktop extends StatefulWidget {
  @override
  State<NotesScreenDesktop> createState() => _NotesScreenDesktopState();
}

class _NotesScreenDesktopState extends NotesScreenBase<NotesScreenDesktop> {
  String selectedSidebarItem = 'All Notes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [_buildSidebar(), _buildMainContent()]),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFFEDEBEB),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            "Notes",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(
                  icon: Icons.list,
                  title: "All Notes",
                  count: totalCount,
                  onTap: () {
                    setState(() => selectedSidebarItem = 'All Notes');
                    loadNotes();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.today,
                  title: "Today",
                  count: todayCount,
                  onTap: () {
                    setState(() => selectedSidebarItem = 'Today');
                    filterToday();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.calendar_view_week,
                  title: "This Week",
                  count: thisWeekCount,
                  onTap: () {
                    setState(() => selectedSidebarItem = 'This Week');
                    filterThisWeek();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.calendar_month,
                  title: "This Month",
                  count: thisMonthCount,
                  onTap: () {
                    setState(() => selectedSidebarItem = 'This Month');
                    filterThisMonth();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.star,
                  title: "Important",
                  count: importantCount,
                  onTap: () {
                    setState(() => selectedSidebarItem = 'Important');
                    filterImportant();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.lock_clock,
                  title: "Recurring",
                  count: recurringCount,
                  onTap: () {
                    setState(() => selectedSidebarItem = 'Recurring');
                    filterRecurring();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.delete,
                  title: "Trash",
                  count: trashCount,
                  onTap: () {
                    setState(() => selectedSidebarItem = 'Trash');
                    filterTrash();
                  },
                ),
              ],
            ),
          ),
          // Settings في الأسفل
          const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),

          _buildSidebarItem(
            icon: Icons.settings,
            title: "Settings",
            onTap: () {
              setState(() => selectedSidebarItem = 'Settings');
              // TODO: أضف دالة الإعدادات هنا
            },
          ),

          const SizedBox(height: 8), // مسافة من الأسفل
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    int? count,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedSidebarItem == title;

    return Container(
      // color: isSelected ? const Color(0xFFDDDDE5) : null,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFDDDDE5) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey[700],
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            // color: isSelected ? Colors.blue : Colors.grey[800],
            color: Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        trailing: count != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? null : Colors.grey[300],
                  // color: isSelected ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    // color: isSelected ? Colors.white : Colors.grey[800],
                  ),
                ),
              )
            : null,
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: Colors.blue.withOpacity(0.1),
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedSidebarItem,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FloatingActionButton.extended(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
                    );
                    loadNotes();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة ملاحظة'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(child: buildNotesList()),
        ],
      ),
    );
  }
}
