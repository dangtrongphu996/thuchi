class DanhMuc {
  final int? id;
  final String ten;
  final String? icon;
  final int loai; // 1 = Thu nhập, 2 = Chi phí

  DanhMuc({this.id, required this.ten, this.icon, required this.loai});

  Map<String, dynamic> toMap() {
    return {'id': id, 'ten': ten, 'icon': icon, 'loai': loai};
  }

  factory DanhMuc.fromMap(Map<String, dynamic> map) {
    if (map == null || map.isEmpty) {
      return DanhMuc(id: null, ten: '', icon: '', loai: 0);
    }
    return DanhMuc(
      id: map['dm_id'] ?? map['id'],
      ten: map['ten'] ?? '',
      icon: map['icon'],
      loai: map['loai'],
    );
  }
}
