class NganSach {
  final int? id;
  final int danhMucId;
  final int thang;
  final int nam;
  final double soTien;

  NganSach({
    this.id,
    required this.danhMucId,
    required this.thang,
    required this.nam,
    required this.soTien,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'danhMucId': danhMucId,
      'thang': thang,
      'nam': nam,
      'soTien': soTien,
    };
  }

  factory NganSach.fromMap(Map<String, dynamic> map) {
    return NganSach(
      id: map['id'],
      danhMucId: map['danhMucId'],
      thang: map['thang'],
      nam: map['nam'],
      soTien: map['soTien'],
    );
  }
}
