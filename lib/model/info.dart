class Info {
  int? id;
  String userId;
  String judul;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  Info({
    this.id,
    required this.userId,
    required this.judul,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Info.fromMap(Map<String, dynamic> map) {
    return Info(
      id: map['id'],
      userId: map['user_id'],
      judul: map['judul'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'judul': judul,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
