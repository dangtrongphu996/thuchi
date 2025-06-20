import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Tên file database của bạn (cập nhật nếu khác)
const String localDbFileName = 'chi_tieu.db';

/// Tên file khi lưu trên Google Drive
const String driveDbFileName = 'thu_chi_backup.db';

/// Tên file holidays.txt trong thiết bị
const String localHolidayFileName = 'holidays.txt';

/// Tên file khi lưu trên Google Drive
const String driveHolidayFileName = 'holidays_backup.txt';

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['https://www.googleapis.com/auth/drive.file'],
);

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class BackupRestoreHelper {
  /// Đăng nhập Google
  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await googleSignIn.signIn();
      return account;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  /// Lấy đường dẫn database trong thiết bị
  static Future<String> _getDbPath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, localDbFileName);
    return path;
  }

  /// Lấy đường dẫn file holidays.txt trong thiết bị
  static Future<String> _getHolidayFilePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, localHolidayFileName);
  }

  /// Sao lưu database lên Google Drive
  static Future<bool> backupToGoogleDrive(GoogleSignInAccount account) async {
    try {
      final headers = await account.authHeaders;
      final client = GoogleAuthClient(headers);
      final driveApi = drive.DriveApi(client);

      final dbPath = await _getDbPath();
      final dbFile = File(dbPath);

      final file = drive.File();
      file.name = driveDbFileName;

      await driveApi.files.create(
        file,
        uploadMedia: drive.Media(dbFile.openRead(), dbFile.lengthSync()),
      );

      // Backup holidays.txt
      final holidayPath = await _getHolidayFilePath();
      final holidayFile = File(holidayPath);
      if (await holidayFile.exists()) {
        final holidayDriveFile = drive.File();
        holidayDriveFile.name = driveHolidayFileName;
        await driveApi.files.create(
          holidayDriveFile,
          uploadMedia: drive.Media(
            holidayFile.openRead(),
            holidayFile.lengthSync(),
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Backup failed: $e');
      return false;
    }
  }

  /// Khôi phục database từ Google Drive
  static Future<bool> restoreFromGoogleDrive(
    GoogleSignInAccount account,
  ) async {
    try {
      final headers = await account.authHeaders;
      final client = GoogleAuthClient(headers);
      final driveApi = drive.DriveApi(client);

      final files = await driveApi.files.list(
        q: "name='$driveDbFileName'",
        spaces: 'drive',
      );

      if (files.files == null || files.files!.isEmpty) return false;

      final fileId = files.files!.first.id;
      final media =
          await driveApi.files.get(
                fileId!,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final dbPath = await _getDbPath();
      final fileStream = File(dbPath).openWrite();

      await media.stream.pipe(fileStream);

      // Restore holidays.txt
      final holidayFiles = await driveApi.files.list(
        q: "name='$driveHolidayFileName'",
        spaces: 'drive',
      );
      if (holidayFiles.files != null && holidayFiles.files!.isNotEmpty) {
        final holidayFileId = holidayFiles.files!.first.id;
        final holidayMedia =
            await driveApi.files.get(
                  holidayFileId!,
                  downloadOptions: drive.DownloadOptions.fullMedia,
                )
                as drive.Media;
        final holidayPath = await _getHolidayFilePath();
        final holidayStream = File(holidayPath).openWrite();
        await holidayMedia.stream.pipe(holidayStream);
      }
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }
}
