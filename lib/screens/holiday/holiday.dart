class Holiday {
  String name;
  DateTime date;
  String? imagePath; // Đường dẫn hình ảnh (tùy chọn)

  Holiday({required this.name, required this.date, this.imagePath});

  @override
  String toString() => '$name|${date.toIso8601String()}|${imagePath ?? ''}';

  static Holiday fromString(String data) {
    final parts = data.split('|');
    return Holiday(
      name: parts[0],
      date: DateTime.parse(parts[1]),
      imagePath: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
    );
  }
}
