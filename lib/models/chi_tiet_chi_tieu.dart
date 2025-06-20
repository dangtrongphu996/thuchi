class ChiTietChiTieu {
  final int? id;
  final int danhMucId;
  final double soTien;
  final String ghiChu;
  final String ngay;

  ChiTietChiTieu({
    this.id,
    required this.danhMucId,
    required this.soTien,
    required this.ghiChu,
    required this.ngay,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'danh_muc_id': danhMucId,
      'so_tien': soTien,
      'mo_ta': ghiChu,
      'ngay': ngay,
    };
  }

  factory ChiTietChiTieu.fromMap(Map<String, dynamic> map) {
    if (map == null || map.isEmpty) {
      return ChiTietChiTieu(
        id: null,
        danhMucId: 0,
        soTien: 0,
        ghiChu: '',
        ngay: DateTime.now().toString().substring(0, 10),
      );
    }
    return ChiTietChiTieu(
      id: map['ct_id'] ?? map['id'],
      danhMucId: map['danh_muc_id'],
      soTien:
          map['so_tien'] is int
              ? (map['so_tien'] as int).toDouble()
              : map['so_tien'],
      ghiChu: map['mo_ta'] ?? '',
      ngay: map['ngay'],
    );
  }
}
