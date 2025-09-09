import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'screenshot_viewer_screen.dart';

class ScreenshotGalleryScreen extends StatefulWidget {
  const ScreenshotGalleryScreen({super.key});

  @override
  State<ScreenshotGalleryScreen> createState() =>
      _ScreenshotGalleryScreenState();
}

class _ScreenshotGalleryScreenState extends State<ScreenshotGalleryScreen> {
  List<File> _screenshots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreenshots();
  }

  Future<void> _loadScreenshots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final screenshotsDir = Directory('${documentsDir.path}/screenshots');

      if (await screenshotsDir.exists()) {
        final files = await screenshotsDir.list().toList();
        _screenshots =
            files
                .where((file) => file is File && file.path.endsWith('.png'))
                .cast<File>()
                .toList();

        // Sort by modification date (newest first)
        _screenshots.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );
      }
    } catch (e) {
      _showMessage('Lỗi khi tải danh sách ảnh: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            message.contains('thành công') ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getFileName(File file) {
    String fullName = file.path.split('/').last.split('\\').last;

    // Nếu tên quá dài, rút gọn lại
    if (fullName.length > 25) {
      // Tách name và extension
      final parts = fullName.split('.');
      if (parts.length > 1) {
        final extension = parts.last;
        final nameWithoutExt = parts.sublist(0, parts.length - 1).join('.');

        // Rút gọn phần name, giữ extension
        if (nameWithoutExt.length > 20) {
          return '${nameWithoutExt.substring(0, 17)}...$extension';
        }
      } else {
        // Không có extension, rút gọn toàn bộ
        return '${fullName.substring(0, 22)}...';
      }
    }

    return fullName;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thư viện ảnh chụp màn hình',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScreenshots,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _screenshots.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có ảnh chụp màn hình nào',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hãy chụp ảnh màn hình từ các màn hình khác',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _loadScreenshots,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          0.7, // Điều chỉnh tỷ lệ để có đủ không gian cho text
                    ),
                    itemCount: _screenshots.length,
                    itemBuilder: (context, index) {
                      try {
                        final file = _screenshots[index];
                        final fileName = _getFileName(file);
                        final fileSize = _formatFileSize(file.lengthSync());
                        final lastModified = DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(file.lastModifiedSync());

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ScreenshotViewerScreen(
                                        screenshots: _screenshots,
                                        initialIndex: index,
                                        onDelete: (deletedFile) {
                                          setState(() {
                                            _screenshots.remove(deletedFile);
                                          });
                                        },
                                      ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      image: DecorationImage(
                                        image: FileImage(file),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.7,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              fileSize,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  constraints: const BoxConstraints(
                                    minHeight: 50,
                                    maxHeight: 65,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Text(
                                          fileName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Flexible(
                                        flex: 1,
                                        child: Text(
                                          lastModified,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        // Return error card nếu có vấn đề với file
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Lỗi hiển thị ảnh',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "gallery_refresh_fab",
        onPressed: _loadScreenshots,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
