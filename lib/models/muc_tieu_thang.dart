class MucTieuThang {
  final int? id;
  final int thang;
  final int nam;
  final int loai; // 1: thu nhập, 2: chi phí
  final double soTien;

  MucTieuThang({
    this.id,
    required this.thang,
    required this.nam,
    required this.loai,
    required this.soTien,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'thang': thang,
      'nam': nam,
      'loai': loai,
      'soTien': soTien,
    };
  }

  factory MucTieuThang.fromMap(Map<String, dynamic> map) {
    return MucTieuThang(
      id: map['id'],
      thang: map['thang'],
      nam: map['nam'],
      loai: map['loai'],
      soTien: map['soTien'],
    );
  }
}
