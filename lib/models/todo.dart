class Todo {
  String title;
  bool isDone;
  DateTime date;

  Todo({required this.title, this.isDone = false, DateTime? date})
    : date = date ?? DateTime.now(); // nếu không truyền thì lấy ngày hiện tại

  Map<String, dynamic> toJson() => {
    'title': title,
    'isDone': isDone,
    'date': date.toIso8601String(),
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    title: json['title'],
    isDone: json['isDone'] ?? false,
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
  );
}
