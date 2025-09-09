import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../screens/screenshot_gallery_screen.dart';

class FullPageScreenshotWrapper extends StatefulWidget {
  final Widget child;
  final String? screenName;
  final bool includeAppBar;
  final Color? backgroundColor;

  const FullPageScreenshotWrapper({
    super.key,
    required this.child,
    this.screenName,
    this.includeAppBar = true,
    this.backgroundColor,
  });

  @override
  State<FullPageScreenshotWrapper> createState() =>
      _FullPageScreenshotWrapperState();
}

class _FullPageScreenshotWrapperState extends State<FullPageScreenshotWrapper> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isCapturing = false;

  Future<void> _captureFullPageScreenshot() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Wait for UI to settle
      await Future.delayed(const Duration(milliseconds: 300));

      // Try to find the parent Scaffold to capture everything including AppBar
      RenderRepaintBoundary? scaffoldBoundary = _findScaffoldRepaintBoundary(
        context,
      );
      ui.Image image;

      if (scaffoldBoundary != null && widget.includeAppBar) {
        // Found scaffold boundary and want to include AppBar, capture it
        image = await scaffoldBoundary.toImage(pixelRatio: 3.0);
      } else {
        // Fallback to current boundary or body-only
        RenderRepaintBoundary? boundary =
            _repaintBoundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;

        if (boundary == null) {
          _showMessage('Không thể tìm thấy boundary để chụp ảnh');
          return;
        }

        // Capture the current boundary content
        image = await boundary.toImage(pixelRatio: 3.0);
      }

      // Convert to byte data
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        // Get the image bytes
        Uint8List imageBytes = byteData.buffer.asUint8List();

        // Save to documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        final screenshotsDir = Directory('${documentsDir.path}/screenshots');

        // Create screenshots directory if it doesn't exist
        if (!await screenshotsDir.exists()) {
          await screenshotsDir.create(recursive: true);
        }

        final fileName =
            '${widget.screenName ?? 'full_page_${DateTime.now().millisecondsSinceEpoch}'}.png';
        final file = File('${screenshotsDir.path}/$fileName');

        // Write image data to file
        await file.writeAsBytes(imageBytes);

        // Verify file exists and has content
        if (await file.exists() && await file.length() > 0) {
          _showMessage('Đã lưu ảnh toàn trang (bao gồm AppBar) thành công!');
        } else {
          _showMessage('Không thể tạo file ảnh');
        }
      } else {
        _showMessage('Không thể chuyển đổi ảnh');
      }
    } catch (e) {
      _showMessage('Lỗi khi chụp ảnh toàn trang: $e');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  void _openGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScreenshotGalleryScreen()),
    );
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

  @override
  Widget build(BuildContext context) {
    // Get background color from widget parameter or theme
    final bgColor =
        widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        decoration: BoxDecoration(color: bgColor),
        child: widget.child,
      ),
    );
  }

  // Public methods để gọi từ AppBar actions
  Future<void> captureScreenshot() async {
    if (!_isCapturing) {
      await _captureFullPageScreenshot();
    }
  }

  void openGallery() {
    _openGallery();
  }

  bool get isCapturing => _isCapturing;

  // Helper method to find Scaffold RepaintBoundary
  RenderRepaintBoundary? _findScaffoldRepaintBoundary(BuildContext context) {
    try {
      // Walk up the widget tree to find a RepaintBoundary that contains the Scaffold
      RenderObject? current = context.findRenderObject();

      while (current != null) {
        // Move to parent
        current = current.parent;

        // Check if this render object is a RepaintBoundary
        if (current is RenderRepaintBoundary) {
          // This could be the boundary that wraps the entire screen
          // We assume the first RepaintBoundary going up is what we want
          return current;
        }
      }
    } catch (e) {
      print('Could not find scaffold repaint boundary: $e');
    }
    return null;
  }
}
