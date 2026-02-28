// import '../../services/filter_service.dart';
import '../services/filter_service.dart';
import 'package:flutter/material.dart';
// import 'package:window_manager/window_manager.dart'; // إضافة هذا الـ import

import '../main.dart'; // إضافة هذا الـ import للوصول إلى windowTitleController

import 'add_edit_note_screen.dart';
import 'notes_screen_base.dart';

class NotesScreenDesktop extends StatefulWidget {
  final VoidCallback toggleTheme;

  const NotesScreenDesktop({required this.toggleTheme});
  @override
  State<NotesScreenDesktop> createState() => _NotesScreenDesktopState();
}

class _NotesScreenDesktopState extends NotesScreenBase<NotesScreenDesktop> {
  String selectedSidebarItem = 'All Notes';

  @override
  void initState() {
    super.initState();
    // تحديث عنوان النافذة عند البداية
    _updateWindowTitle(selectedSidebarItem);
  }

  // دالة لتحديث عنوان النافذة
  void _updateWindowTitle(String title) {
    if (isDesktop && windowTitleController != null) {
      // ✅ استخدام ?. لتجنب الخطأ
      windowTitleController?.add(title);
    }

    // if (isDesktop) {
    //   // الترجمة حسب اللغة
    //   // String englishTitle = _getEnglishTitle(title);
    //   windowTitleController.add(title);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [_buildSidebar(), _buildMainContent()]),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Theme.of(
        context,
      ).colorScheme.primary, // لون خلفية حديث يتغير مع الوضع الداكن/الفاتح
      // color: const Color(0xFFEDEBEB),
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
                  onTap: () async {
                    setState(() => selectedSidebarItem = 'All Notes');
                    _updateWindowTitle('All Notes'); // تحديث العنوان
                    await FilterService.saveLastFilter('all');
                    print('All Notes tapped, loading all notes...');
                    final filter = await FilterService.getLastFilter();
                    print(filter);
                    loadNotes();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.today,
                  title: "Today",
                  count: todayCount,
                  onTap: () async {
                    setState(() => selectedSidebarItem = 'Today');
                    _updateWindowTitle('Today'); // تحديث العنوان
                    await FilterService.saveLastFilter('today');
                    print('Today tapped, loading today notes...');
                    final filter = await FilterService.getLastFilter();
                    print(filter);
                    filterToday();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.calendar_view_week,
                  title: "This Week",
                  count: thisWeekCount,
                  onTap: () async {
                    setState(() => selectedSidebarItem = 'This Week');
                    _updateWindowTitle('This Week'); // تحديث العنوان
                    await FilterService.saveLastFilter('this_week');
                    print('This Week tapped, loading this week notes...');
                    final filter = await FilterService.getLastFilter();
                    print(filter);

                    filterThisWeek();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.calendar_month,
                  title: "This Month",
                  count: thisMonthCount,
                  onTap: () async {
                    setState(() => selectedSidebarItem = 'This Month');
                    _updateWindowTitle('This Month'); // تحديث العنوان
                    await FilterService.saveLastFilter('this_month');
                    filterThisMonth();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.star,
                  title: "Important",
                  count: importantCount,
                  onTap: () async {
                    setState(() => selectedSidebarItem = 'Important');
                    _updateWindowTitle('Important'); // تحديث العنوان
                    await FilterService.saveLastFilter('important');
                    filterImportant();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.lock_clock,
                  title: "Recurring",
                  count: recurringCount,
                  onTap: () async {
                    setState(() => selectedSidebarItem = 'Recurring');
                    _updateWindowTitle('Recurring'); // تحديث العنوان
                    await FilterService.saveLastFilter('recurring');
                    filterRecurring();
                  },
                ),
                _buildSidebarItem(
                  icon: Icons.delete,
                  title: "Trash",
                  count: trashCount,
                  onTap: () async {
                    setState(() => selectedSidebarItem = 'Trash');
                    _updateWindowTitle('Trash'); // تحديث العنوان
                    await FilterService.saveLastFilter('trash');
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
        color: isSelected
            ? Theme.of(context).colorScheme.secondaryFixedDim
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Colors.blue
              : Theme.of(context).colorScheme.secondaryFixed,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            // color: isSelected ? Colors.blue : Colors.grey[800],
            // color: Colors.grey[800],
            color: Theme.of(context).colorScheme.secondaryFixed,
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
                  color: isSelected
                      ? null
                      : Theme.of(context).colorScheme.secondaryContainer,
                  // color: isSelected ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondaryFixed,
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
                Row(
                  children: [
                    Material(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      // color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: widget.toggleTheme,
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: Center(
                            child: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.wb_sunny
                                  : Icons.nightlight_round,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6), // أزرق حديث
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditNoteScreen(),
                            ),
                          );
                          // ✅ لو رجعنا من الشاشة (أيًا كان السبب)
                          if (result != null || result == null) {
                            loadFilteredNotes(); // استخدم الدالة الجديدة
                            await loadAllCounts(); // حدث الأعداد كمان
                          }
                          // loadFilteredNot
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          'New Note',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
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
