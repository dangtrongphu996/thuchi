import 'package:sqflite/sqflite.dart';
import '../models/muc_tieu_thang.dart';
import 'database_helper.dart';

class MucTieuThangDao {
  Future<int> insert(MucTieuThang mucTieu) async {
    final db = await DatabaseHelper().database;
    return await db.insert('MucTieuThang', mucTieu.toMap());
  }

  Future<int> update(MucTieuThang mucTieu) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'MucTieuThang',
      mucTieu.toMap(),
      where: 'id = ?',
      whereArgs: [mucTieu.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('MucTieuThang', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MucTieuThang>> getAll() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('MucTieuThang');
    return maps.map((map) => MucTieuThang.fromMap(map)).toList();
  }

  Future<MucTieuThang?> getByMonthAndType(int thang, int nam, int loai) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query(
      'MucTieuThang',
      where: 'thang = ? AND nam = ? AND loai = ?',
      whereArgs: [thang, nam, loai],
    );
    if (maps.isNotEmpty) {
      return MucTieuThang.fromMap(maps.first);
    }
    return null;
  }
}
