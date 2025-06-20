import 'chi_tiet_chi_tieu.dart';
import 'danh_muc.dart';

class ChiTietChiTieuDanhMuc {
  final ChiTietChiTieu chiTietChiTieu;
  final DanhMuc danhMuc;

  ChiTietChiTieuDanhMuc({required this.chiTietChiTieu, required this.danhMuc});

  Map<String, dynamic> toMap() {
    return {
      'chiTietChiTieu': chiTietChiTieu.toMap(),
      'danhMuc': danhMuc.toMap(),
    };
  }

  factory ChiTietChiTieuDanhMuc.fromMap(Map<String, dynamic> map) {
    // map là phẳng, gồm các trường của cả ChiTietChiTieu và DanhMuc
    return ChiTietChiTieuDanhMuc(
      chiTietChiTieu: ChiTietChiTieu.fromMap(map),
      danhMuc: DanhMuc.fromMap(map),
    );
  }
}
