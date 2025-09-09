import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;

/// A special wrapper that only captures the body content (no AppBar)
class BodyScreenshotWrapper extends StatefulWidget {
  final Widget child;
  final String? screenName;

  const BodyScreenshotWrapper({
    super.key,
    required this.child,
    this.screenName,
  });

  @override
  State<BodyScreenshotWrapper> createState() => _BodyScreenshotWrapperState();
}

class _BodyScreenshotWrapperState extends State<BodyScreenshotWrapper> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<void> _captureBodyOnly() async {
    try {
      // Wait for UI to settle
      await Future.delayed(const Duration(milliseconds: 300));

      // Find the RenderRepaintBoundary for body content
      RenderRepaintBoundary? boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        _showMessage('Không thể tìm thấy boundary để chụp ảnh');
        return;
      }

      // Capture only the body content
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

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
            '${widget.screenName ?? 'body'}_body_only_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${screenshotsDir.path}/$fileName');

        // Write image data to file
        await file.writeAsBytes(imageBytes);

        // Verify file exists and has content
        if (await file.exists() && await file.length() > 0) {
          _showMessage('Đã lưu ảnh nội dung (không có AppBar) thành công!');
        } else {
          _showMessage('Không thể tạo file ảnh');
        }
      } else {
        _showMessage('Không thể chuyển đổi ảnh');
      }
    } catch (e) {
      _showMessage('Lỗi khi chụp ảnh nội dung: $e');
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

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: _repaintBoundaryKey, child: widget.child);
  }

  // Method to trigger screenshot from parent
  Future<void> captureScreenshot() async {
    await _captureBodyOnly();
  }
}
