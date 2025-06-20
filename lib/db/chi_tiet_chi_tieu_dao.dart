import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/chi_tiet_chi_tieu.dart';
import '../models/chi_tiet_chi_tieu_danh_muc.dart';
import '../models/ngan_sach.dart';

class ChiTietChiTieuDao {
  final dbProvider = DatabaseHelper();

  Future<bool> insert(ChiTietChiTieu ct) async {
    final db = await DatabaseHelper().database;

    // Lấy ngân sách nếu có
    final thang = ct.ngay.substring(5, 7);
    final nam = ct.ngay.substring(0, 4);

    final nganSachList = await db.query(
      'NganSach',
      where: 'danhMucId = ? AND thang = ? AND nam = ?',
      whereArgs: [ct.danhMucId, thang, nam],
    );

    if (nganSachList.isNotEmpty) {
      final nganSach = NganSach.fromMap(nganSachList.first);

      final tongChi =
          Sqflite.firstIntValue(
            await db.rawQuery(
              '''
      SELECT SUM(so_tien) FROM ChiTietChiTieu
      WHERE danh_muc_id = ? AND strftime('%m', ngay) = ? AND strftime('%Y', ngay) = ?
    ''',
              [ct.danhMucId, thang.toString().padLeft(2, '0'), nam.toString()],
            ),
          ) ??
          0;

      final daChi = tongChi + ct.soTien;
      if (daChi > nganSach.soTien) {
        return false; // Trả về false nếu vượt ngân sách
      }
    }

    await db.insert('ChiTietChiTieu', ct.toMap());
    return true;
  }

  Future<List<ChiTietChiTieuDanhMuc>> getByMonth(int month, int year) async {
    final db = await dbProvider.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        ChiTietChiTieu.id AS ct_id, 
        ChiTietChiTieu.danh_muc_id, 
        ChiTietChiTieu.so_tien, 
        ChiTietChiTieu.mo_ta, 
        ChiTietChiTieu.ngay, 
        DanhMuc.id AS dm_id, 
        DanhMuc.ten, 
        DanhMuc.icon, 
        DanhMuc.loai 
      FROM ChiTietChiTieu 
      JOIN DanhMuc ON ChiTietChiTieu.danh_muc_id = DanhMuc.id 
      WHERE strftime('%m', ngay) = ? AND strftime('%Y', ngay) = ?
      ''',
      [month.toString().padLeft(2, '0'), year.toString()],
    );

    if (result == null || result.isEmpty) {
      return [];
    } else {
      return result.map((e) => ChiTietChiTieuDanhMuc.fromMap(e)).toList();
    }
  }

  Future<int> delete(int id) async {
    final db = await dbProvider.database;
    return await db.delete('ChiTietChiTieu', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(ChiTietChiTieu ct) async {
    final db = await dbProvider.database;
    return await db.update(
      'ChiTietChiTieu',
      ct.toMap(),
      where: 'id = ?',
      whereArgs: [ct.id],
    );
  }

  Future<double> getTongChiTieuTheoDanhMuc(
    int danhMucId,
    int thang,
    int nam,
  ) async {
    final db = await dbProvider.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(so_tien) as tong FROM ChiTietChiTieu
      WHERE danh_muc_id = ? AND strftime('%m', ngay) = ? AND strftime('%Y', ngay) = ?
      ''',
      [danhMucId, thang.toString().padLeft(2, '0'), nam.toString()],
    );
    if (result.isNotEmpty && result.first['tong'] != null) {
      return (result.first['tong'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getTongTienTheoDanhMuc(int danhMucId) async {
    final db = await dbProvider.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(so_tien) as tong FROM ChiTietChiTieu
      WHERE danh_muc_id = ?
      ''',
      [danhMucId],
    );
    if (result.isNotEmpty && result.first['tong'] != null) {
      return (result.first['tong'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<ChiTietChiTieuDanhMuc>> getAll() async {
    final db = await dbProvider.database;
    final result = await db.rawQuery('''
      SELECT 
        ChiTietChiTieu.id AS ct_id, 
        ChiTietChiTieu.danh_muc_id, 
        ChiTietChiTieu.so_tien, 
        ChiTietChiTieu.mo_ta, 
        ChiTietChiTieu.ngay, 
        DanhMuc.id AS dm_id, 
        DanhMuc.ten, 
        DanhMuc.icon, 
        DanhMuc.loai 
      FROM ChiTietChiTieu 
      JOIN DanhMuc ON ChiTietChiTieu.danh_muc_id = DanhMuc.id 
      ''');

    if (result == null || result.isEmpty) {
      return [];
    } else {
      return result.map((e) => ChiTietChiTieuDanhMuc.fromMap(e)).toList();
    }
  }

  Future<List<ChiTietChiTieuDanhMuc>> getByYear(int year) async {
    final db = await dbProvider.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        ChiTietChiTieu.id AS ct_id, 
        ChiTietChiTieu.danh_muc_id, 
        ChiTietChiTieu.so_tien, 
        ChiTietChiTieu.mo_ta, 
        ChiTietChiTieu.ngay, 
        DanhMuc.id AS dm_id, 
        DanhMuc.ten, 
        DanhMuc.icon, 
        DanhMuc.loai 
      FROM ChiTietChiTieu 
      JOIN DanhMuc ON ChiTietChiTieu.danh_muc_id = DanhMuc.id 
      WHERE strftime('%Y', ngay) = ?
      ''',
      [year.toString()],
    );
    if (result == null || result.isEmpty) {
      return [];
    } else {
      return result.map((e) => ChiTietChiTieuDanhMuc.fromMap(e)).toList();
    }
  }
}
