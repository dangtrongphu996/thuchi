import 'package:sqflite/sqflite.dart';
import '../models/ngan_sach.dart';
import 'database_helper.dart';

class NganSachDao {
  Future<int> insert(NganSach nganSach) async {
    final db = await DatabaseHelper().database;
    return await db.insert('NganSach', nganSach.toMap());
  }

  Future<int> update(NganSach nganSach) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'NganSach',
      nganSach.toMap(),
      where: 'id = ?',
      whereArgs: [nganSach.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('NganSach', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<NganSach>> getAll() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('NganSach');
    return maps.map((map) => NganSach.fromMap(map)).toList();
  }

  Future<List<NganSach>> getByMonth(int thang, int nam) async {
    final db = await DatabaseHelper().database;
    final maps = await db.rawQuery(
      '''
      SELECT NganSach.* 
      FROM NganSach
      INNER JOIN DanhMuc ON NganSach.danhMucId = DanhMuc.id
      WHERE NganSach.thang = ? AND NganSach.nam = ? AND DanhMuc.loai = 2
    ''',
      [thang, nam],
    );
    return maps.map((map) => NganSach.fromMap(map)).toList();
  }

  Future<NganSach?> getByDanhMucAndMonth(
    int danhMucId,
    int thang,
    int nam,
  ) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query(
      'NganSach',
      where: 'danhMucId = ? AND thang = ? AND nam = ?',
      whereArgs: [danhMucId, thang, nam],
    );
    if (maps.isNotEmpty) {
      return NganSach.fromMap(maps.first);
    }
    return null;
  }
}
