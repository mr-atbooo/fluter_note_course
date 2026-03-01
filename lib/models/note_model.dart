class Note {
  int? id;
  String title;
  String? content;
  int priority; // 1, 2, 3
  DateTime? publishedAt;
  bool isPublished; // 0 or 1
  DateTime? createdAt;
  DateTime? updatedAt;
  // ✅ حقول جديدة للتكرار والاهتزاز
  String? repeatType; // 'none', 'daily', 'weekly', 'custom', 'hourly'
  String? repeatDays; // مثلاً "1,2,3,4,5" للأيام (1=الإثنين)
  int? repeatInterval; // للتكرار المخصص بالساعات
  int? vibrate; // 0 or 1 (هل يهتز)
  String? sound; // اسم الصوت
  DateTime? lastNotified;

  Note({
    this.id,
    required this.title,
    this.content,
    this.priority = 1,
    this.publishedAt,
    this.isPublished = false,
    this.createdAt,
    this.updatedAt,
    this.repeatType = 'none',
    this.repeatDays,
    this.repeatInterval,
    this.vibrate = 1,
    this.sound,
    this.lastNotified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'published_at': publishedAt?.toIso8601String(),
      'is_published': isPublished ? 1 : 0,
      'repeat_type': repeatType,
      'repeat_days': repeatDays,
      'repeat_interval': repeatInterval,
      'vibrate': vibrate,
      'sound': sound,
      'last_notified': lastNotified?.toIso8601String(),
      // ⚠️ لا ندرج created_at و updated_at هنا - سيُضافان تلقائياً في الـ DB
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'] ?? 1,
      publishedAt: map['published_at'] != null
          ? DateTime.parse(map['published_at'])
          : null,
      isPublished: map['is_published'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(), // افتراضي آمن
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      repeatType: map['repeat_type'] ?? 'none',
      repeatDays: map['repeat_days'],
      repeatInterval: map['repeat_interval'],
      vibrate: map['vibrate'] ?? 1,
      sound: map['sound'],
      lastNotified: map['last_notified'] != null
          ? DateTime.parse(map['last_notified'])
          : null,
    );
  }
}
