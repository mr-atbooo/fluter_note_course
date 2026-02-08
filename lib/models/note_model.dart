class Note {
  int? id;
  String title;
  String? content;
  int priority;
  DateTime? publishedAt;
  bool isPublished;

  Note({
    this.id,
    required this.title,
    this.content,
    this.priority = 1,
    this.publishedAt,
    this.isPublished = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'published_at': publishedAt?.toIso8601String(),
      'is_published': isPublished ? 1 : 0,
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
      // ⚠️ لا نقرأ created_at و updated_at إلى الـ Model (لا نحتاجهما في الواجهة)
    );
  }
}

// class Note {
//   int? id;
//   String title;
//   String? content;
//   int priority;
//   DateTime? publishedAt; // 👈 الحقل الجديد
//   bool isPublished;
//   DateTime createdAt;
//   DateTime? updatedAt;

//   Note({
//     this.id,
//     required this.title,
//     this.content,
//     this.priority = 1,
//     this.publishedAt,
//     this.isPublished = false,
//     required this.createdAt,
//     this.updatedAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'content': content,
//       'priority': priority,
//       // 'published_at': publishedAt,
//       'published_at': publishedAt?.toIso8601String(),
//       'is_published': isPublished ? 1 : 0,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }

//   factory Note.fromMap(Map<String, dynamic> map) {
//     return Note(
//       id: map['id'],
//       title: map['title'],
//       content: map['content'],
//       priority: map['priority'] ?? 1,
//       publishedAt: map['published_at'] != null
//           ? DateTime.parse(map['published_at'])
//           : null,
//       isPublished: map['is_published'] == 1,
//       createdAt: map['created_at'] ?? '',
//       updatedAt: map['updated_at'],
//     );
//   }
// }
