class Note {
  int? id;
  String title;
  String? content;
  int priority;
  String createdAt;
  String? updatedAt;

  Note({
    this.id,
    required this.title,
    this.content,
    this.priority = 1,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'] ?? 1,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'],
    );
  }
}
