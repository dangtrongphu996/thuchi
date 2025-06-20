import 'package:sqflite/sqflite.dart';
import '../models/danh_muc.dart';
import 'database_helper.dart';

class DanhMucDao {
  final dbProvider = DatabaseHelper();

  Future<int> insertDanhMuc(DanhMuc danhMuc) async {
    final db = await dbProvider.database;
    return await db.insert('DanhMuc', danhMuc.toMap());
  }

  Future<List<DanhMuc>> getDanhMucByLoai(int loai) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DanhMuc',
      where: 'loai = ?',
      whereArgs: [loai],
    );

    return maps.map((e) => DanhMuc.fromMap(e)).toList();
  }

  Future<int> updateDanhMuc(DanhMuc danhMuc) async {
    final db = await dbProvider.database;
    return await db.update(
      'DanhMuc',
      danhMuc.toMap(),
      where: 'id = ?',
      whereArgs: [danhMuc.id],
    );
  }

  Future<int> deleteDanhMuc(int id) async {
    final db = await dbProvider.database;
    return await db.delete('DanhMuc', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DanhMuc>> getAllDanhMuc() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('DanhMuc');
    return maps.map((e) => DanhMuc.fromMap(e)).toList();
  }

  Future<List<DanhMuc>> getAllDanhMucChiPhi() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DanhMuc',
      where: 'loai = ?',
      whereArgs: [2],
    );
    return maps.map((e) => DanhMuc.fromMap(e)).toList();
  }
}
