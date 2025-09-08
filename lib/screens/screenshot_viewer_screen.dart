import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ScreenshotViewerScreen extends StatefulWidget {
  final List<File> screenshots;
  final int initialIndex;
  final Function(File)? onDelete;

  const ScreenshotViewerScreen({
    super.key,
    required this.screenshots,
    this.initialIndex = 0,
    this.onDelete,
  });

  @override
  State<ScreenshotViewerScreen> createState() => _ScreenshotViewerScreenState();
}

class _ScreenshotViewerScreenState extends State<ScreenshotViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _deleteCurrentImage() async {
    if (widget.screenshots.isEmpty) return;

    final currentFile = widget.screenshots[_currentIndex];

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa ảnh này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await currentFile.delete();
        widget.onDelete?.call(currentFile);

        if (mounted) {
          if (widget.screenshots.isEmpty) {
            Navigator.pop(context);
          } else {
            setState(() {
              if (_currentIndex >= widget.screenshots.length) {
                _currentIndex = widget.screenshots.length - 1;
              }
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa ảnh: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getFileName(File file) {
    return file.path.split('/').last.split('\\').last;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.screenshots.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Xem ảnh'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Không có ảnh nào để hiển thị')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${_currentIndex + 1} / ${widget.screenshots.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCurrentImage,
            tooltip: 'Xóa ảnh',
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.screenshots.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        builder: (context, index) {
          final file = widget.screenshots[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(file),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black.withOpacity(0.8),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getFileName(widget.screenshots[_currentIndex]),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, color: Colors.white),
                  onPressed: () {
                    // Zoom out functionality can be added here
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in, color: Colors.white),
                  onPressed: () {
                    // Zoom in functionality can be added here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
