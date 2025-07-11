import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'chi_tieu.db');

    return await openDatabase(
      path,
      version: 2, // tăng version
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE MucTieuThang (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              thang INTEGER,
              nam INTEGER,
              loai INTEGER,
              soTien REAL
            );
          ''');
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE DanhMuc (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten TEXT NOT NULL,
        icon TEXT,
        loai INTEGER NOT NULL -- 1: thu nhập, 2: chi phí
      );
    ''');

    await db.execute('''
      CREATE TABLE ChiTietChiTieu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        so_tien REAL NOT NULL,
        mo_ta TEXT,
        ngay TEXT NOT NULL,
        danh_muc_id INTEGER NOT NULL,
        FOREIGN KEY (danh_muc_id) REFERENCES DanhMuc(id)
      );
    ''');

    await db.execute('''
    CREATE TABLE NganSach (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      danhMucId INTEGER,
      thang INTEGER,
      nam INTEGER,
      soTien REAL
    );
    ''');

    await db.execute('''
    CREATE TABLE MucTieuThang (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      thang INTEGER,
      nam INTEGER,
      loai INTEGER,
      soTien REAL
    );
    ''');
  }

  Future<void> deleteDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'chi_tieu.db');
    await deleteDatabase(path);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('ChiTietChiTieu');
    await db.delete('NganSach');
    await db.delete('DanhMuc');
  }

  static String convertDate(String date) {
    return date.substring(0, 4) +
        '-' +
        date.substring(5, 7) +
        '-' +
        date.substring(8, 10);
  }
}
