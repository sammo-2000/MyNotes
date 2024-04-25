class Note {
  String? email;
  int? id;
  final String title;
  final String note;
  final String? filePath;
  final DateTime? reminderDateTime;
  final DateTime? createAt;
  final DateTime? editAt;

  Note({
    this.email,
    this.id,
    required this.title,
    required this.note,
    this.filePath,
    this.reminderDateTime,
    this.createAt,
    this.editAt,
  });

  factory Note.fromMap(Map<String, dynamic> myMap) {
    return Note(
      email: myMap['email'],
      id: myMap['id'],
      title: myMap['title'],
      note: myMap['note'],
      filePath: myMap['filePath'],
      reminderDateTime: myMap['reminderDateTime'] != null
          ? DateTime.parse(myMap['reminderDateTime'])
          : null,
      createAt:
      myMap['createAt'] != null ? DateTime.parse(myMap['createAt']) : null,
      editAt: myMap['editAt'] != null ? DateTime.parse(myMap['editAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'id': id,
      'title': title,
      'note': note,
      'filePath': filePath,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'createAt': createAt?.toIso8601String(),
      'editAt': editAt?.toIso8601String(),
    };
  }
}
