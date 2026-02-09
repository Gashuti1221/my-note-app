class Note {
  String id; 
  String title;
  String content;
  int color;
  List<String> tags;
  bool pinned;
  DateTime createdDate;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.color = 0xFFFFFFFF,
    this.tags = const [],
    this.pinned = false,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'color': color,
      'tags': tags,
      'pinned': pinned,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      color: map['color'] ?? 0xFFFFFFFF,
      tags: List<String>.from(map['tags'] ?? []),
      pinned: map['pinned'] ?? false,
      createdDate: map['createdDate'] != null 
          ? DateTime.parse(map['createdDate']) 
          : DateTime.now(),
    );
  }
}
