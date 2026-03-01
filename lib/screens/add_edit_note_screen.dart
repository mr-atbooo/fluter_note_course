import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ أضف هذا للـ DateFormat
import '../db/notes_db.dart';
import '../models/note_model.dart';
import '../services/sound_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  AddEditNoteScreen({this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final db = NotesDB();

  // ✅ فصل التاريخ والوقت
  DateTime? publishDate;
  DateTime? publishTime;

  int selectedPriority = 1;

  // ✅ متغيرات التكرار والاهتزاز
  String repeatType = 'none';
  String? repeatDays;
  int repeatInterval = 1;
  bool vibrate = true;
  String? sound = 'ding';
  List<int> selectedDays = [];

  bool get requiresDate => repeatType == 'none'; // فقط بدون تكرار يحتاج تاريخ

  @override
  void initState() {
    super.initState();
    SoundService.stop();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content ?? '';
      selectedPriority = widget.note!.priority;

      // ✅ فصل publishedAt إلى date و time
      if (widget.note!.publishedAt != null) {
        publishDate = widget.note!.publishedAt;
        publishTime = widget.note!.publishedAt;
      }

      // ✅ تحميل القيم الجديدة
      repeatType = widget.note!.repeatType ?? 'none';
      repeatDays = widget.note!.repeatDays;
      repeatInterval = widget.note!.repeatInterval ?? 1;
      vibrate = widget.note!.vibrate == 1;
      sound = widget.note!.sound ?? 'ding';

      // ✅ تحويل repeatDays لقائمة أرقام
      if (repeatDays != null && repeatDays!.isNotEmpty) {
        selectedDays = repeatDays!.split(',').map(int.parse).toList();
      }
    }
  }

  // ✅ دمج التاريخ والوقت في publishedAt للحفظ
  DateTime? getCombinedDateTime() {
    if (requiresDate) {
      // مع التاريخ: نحتاج اليوم
      if (publishDate != null && publishTime != null) {
        return DateTime(
          publishDate!.year,
          publishDate!.month,
          publishDate!.day,
          publishTime!.hour,
          publishTime!.minute,
        );
      }
    } else {
      // بدون تاريخ: نستخدم وقت ثابت مع يوم عشوائي (1 يناير 2000)
      if (publishTime != null) {
        return DateTime(2000, 1, 1, publishTime!.hour, publishTime!.minute);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // العنوان
            // TextField(
            //   controller: titleController,
            //   decoration: InputDecoration(
            //     labelText: 'Title',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 15),

            // المحتوى
            TextField(
              controller: contentController,
              maxLines: 4,
              // decoration: InputDecoration(
              //   labelText: 'Content',
              //   border: OutlineInputBorder(),
              // ),
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 15),

            // الأولوية
            DropdownButtonFormField<int>(
              value: selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Normal')),
                DropdownMenuItem(value: 2, child: Text('Medium')),
                DropdownMenuItem(value: 3, child: Text('High')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
            ),
            SizedBox(height: 15),

            // ✅ التاريخ (يظهر فقط لو requiresDate = true)
            if (requiresDate) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      publishDate == null
                          ? 'No date selected'
                          : 'Date: ${DateFormat('yyyy/MM/dd').format(publishDate!)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: publishDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: pickPublishDate,
                    child: Text(
                      'Choose Date',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],

            // ✅ الوقت (يظهر دايماً)
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    publishTime == null
                        ? 'No time selected'
                        : 'Time: ${DateFormat('hh:mm a').format(publishTime!)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: publishTime == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: pickPublishTime,
                  child: Text(
                    'Choose Time',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // ✅ عرض الـ publishedAt الكامل للتوضيح (اختياري)
            if (getCombinedDateTime() != null) ...[
              Divider(height: 20),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        requiresDate
                            ? 'Scheduled: ${DateFormat('yyyy/MM/dd hh:mm:ss a').format(getCombinedDateTime()!)}'
                            : 'Repeats ${_getRepeatText()} at ${DateFormat('hh:mm a').format(publishTime!)}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20),

            // ✅ إعدادات التكرار
            _buildRepeatSettings(),

            SizedBox(height: 20),

            // زر الحفظ
            ElevatedButton(
              onPressed: () async {
                // ✅ التحقق من صحة البيانات
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                if (requiresDate && publishDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a date')),
                  );
                  return;
                }

                if (publishTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a time')),
                  );
                  return;
                }

                Note note = Note(
                  id: widget.note?.id,
                  title: titleController.text,
                  content: contentController.text,
                  priority: selectedPriority,
                  publishedAt:
                      getCombinedDateTime(), // ✅ استخدام الدالة الجديدة
                  repeatType: repeatType,
                  repeatDays: repeatDays,
                  repeatInterval: repeatInterval,
                  vibrate: vibrate ? 1 : 0,
                  sound: sound,
                );

                if (widget.note == null) {
                  await db.insertNote(note);
                } else {
                  await db.updateNote(note);
                }

                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة لوصف التكرار
  String _getRepeatText() {
    switch (repeatType) {
      case 'daily':
        return 'daily';
      case 'weekly':
        return 'weekly';
      case 'hourly':
        return 'every $repeatInterval hours';
      case 'custom':
        final days = selectedDays
            .map((d) {
              switch (d) {
                case 1:
                  return 'Mon';
                case 2:
                  return 'Tue';
                case 3:
                  return 'Wed';
                case 4:
                  return 'Thu';
                case 5:
                  return 'Fri';
                case 6:
                  return 'Sat';
                case 7:
                  return 'Sun';
                default:
                  return '';
              }
            })
            .join(', ');
        return 'on $days';
      default:
        return '';
    }
  }

  // ✅ دالة إعدادات الترار
  Widget _buildRepeatSettings() {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات التكرار',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // نوع التكرار
            DropdownButtonFormField<String>(
              value: repeatType,

              decoration: InputDecoration(
                labelText: 'نوع التكرار',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('بدون تكرار')),
                DropdownMenuItem(value: 'daily', child: Text('يومي')),
                DropdownMenuItem(value: 'weekly', child: Text('أسبوعي')),
                DropdownMenuItem(value: 'hourly', child: Text('كل ساعة')),
                DropdownMenuItem(value: 'custom', child: Text('أيام مخصصة')),
              ],
              onChanged: (value) {
                setState(() {
                  repeatType = value!;
                  // إذا غيرنا نوع التكرار، نعيد تعيين publishedAt حسب الحاجة
                });
              },
            ),

            const SizedBox(height: 16),

            // للتكرار المخصص بالساعات
            if (repeatType == 'hourly') ...[
              TextFormField(
                initialValue: repeatInterval.toString(),
                decoration: const InputDecoration(
                  labelText: 'التكرار كل (ساعة)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  repeatInterval = int.tryParse(value) ?? 1;
                },
              ),
            ],

            // لأيام التكرار المخصصة
            if (repeatType == 'custom') ...[
              const Text('اختر أيام التكرار:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildDayChip('الإثنين', 1),
                  _buildDayChip('الثلاثاء', 2),
                  _buildDayChip('الأربعاء', 3),
                  _buildDayChip('الخميس', 4),
                  _buildDayChip('الجمعة', 5),
                  _buildDayChip('السبت', 6),
                  _buildDayChip('الأحد', 7),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // إعدادات الاهتزاز والصوت
            SwitchListTile(
              title: const Text('اهتزاز عند الرنين'),
              value: vibrate,
              onChanged: (value) {
                setState(() {
                  vibrate = value;
                });
              },
            ),

            const SizedBox(height: 8),

            // اختيار الصوت
            DropdownButtonFormField<String>(
              value: sound,

              decoration: InputDecoration(
                labelText: 'اختر الصوت',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
              items: const [
                DropdownMenuItem(value: 'ding', child: Text('دينج')),
                DropdownMenuItem(value: 'bell', child: Text('جرس')),
                DropdownMenuItem(value: 'alarm', child: Text('منبه')),
                DropdownMenuItem(value: 'notification', child: Text('إشعار')),
              ],
              onChanged: (value) {
                setState(() {
                  sound = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة الأيام المخصصة
  Widget _buildDayChip(String label, int day) {
    final isSelected = selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedDays.add(day);
          } else {
            selectedDays.remove(day);
          }
          selectedDays.sort();
          repeatDays = selectedDays.join(',');
        });
      },
    );
  }

  // ✅ دالة اختيار التاريخ
  // Future<void> pickPublishDate() async {
  //   final date = await showDatePicker(
  //     context: context,
  //     initialDate: publishDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );
  //   if (date != null) {
  //     setState(() {
  //       publishDate = date;
  //     });
  //   }
  // }

  Future<void> pickPublishDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final date = await showDatePicker(
      context: context,
      initialDate: publishDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF3B82F6), // أزرق للأزرار
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                    surface: Color(0xFF1E1E1E), // خلفية غامقة
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF3B82F6), // أزرق للأزرار
                    onPrimary: Colors.white,
                    onSurface: Colors.black87,
                    surface: Colors.white,
                  ),
            dialogBackgroundColor: isDark
                ? const Color(0xFF2C2C2C)
                : Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6), // لون النص في الأزرار
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        publishDate = date;
      });
    }
  }

  // ✅ دالة اختيار الوقت
  // Future<void> pickPublishTime() async {
  //   final time = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.fromDateTime(publishTime ?? DateTime.now()),
  //   );
  //   if (time != null) {
  //     setState(() {
  //       publishTime = DateTime(2000, 1, 1, time.hour, time.minute);
  //     });
  //   }
  // }
  Future<void> pickPublishTime() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(publishTime ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: const Color(0xFF3B82F6), // اللون الأساسي (للأزرار)
              onPrimary: Colors.white, // لون النص على الزر
              secondary: const Color(0xFF3B82F6), // لون ثانوي
              onSecondary: Colors.white,
              surface: isDark
                  ? const Color(0xFF2C2C2C)
                  : Colors.white, // خلفية الـ TimePicker
              onSurface: isDark ? Colors.white : Colors.black87, // لون النص
              error: Colors.red,
              onError: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(
                  0xFF3B82F6,
                ), // لون نص الزر (OK/CANCEL)
              ),
            ),
            // dialogTheme: DialogTheme(
            //   backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            // ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        publishTime = DateTime(2000, 1, 1, time.hour, time.minute);
      });
    }
  }
}
