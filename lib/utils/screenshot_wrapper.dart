import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class ScreenshotWrapper extends StatefulWidget {
  final Widget child;
  final String? screenName;

  const ScreenshotWrapper({super.key, required this.child, this.screenName});

  @override
  State<ScreenshotWrapper> createState() => _ScreenshotWrapperState();
}

class _ScreenshotWrapperState extends State<ScreenshotWrapper> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  Future<void> _captureScreenshot() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Check permission
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
        if (!await Gal.hasAccess()) {
          _showMessage('Cần quyền truy cập thư viện ảnh để lưu ảnh');
          return;
        }
      }

      // Capture screenshot
      final Uint8List? image = await _screenshotController.capture();

      if (image != null) {
        try {
          // Decode image to ensure it's valid
          final decodedImage = img.decodeImage(image);
          if (decodedImage == null) {
            _showMessage('Không thể xử lý ảnh');
            return;
          }

          // Save to documents directory
          final documentsDir = await getApplicationDocumentsDirectory();
          final fileName =
              '${widget.screenName ?? 'screenshot_${DateTime.now().millisecondsSinceEpoch}'}.png';
          final file = File('${documentsDir.path}/$fileName');

          // Encode as PNG and write to file
          final pngBytes = img.encodePng(decodedImage);
          await file.writeAsBytes(pngBytes);

          // Verify file exists and has content
          if (await file.exists() && await file.length() > 0) {
            // Save to gallery
            await Gal.putImage(file.path);
            _showMessage('Đã lưu ảnh chụp màn hình thành công!');

            // Clean up temporary file
            try {
              await file.delete();
            } catch (e) {
              // Ignore cleanup errors
            }
          } else {
            _showMessage('Không thể tạo file ảnh');
          }
        } catch (e) {
          _showMessage('Lỗi xử lý ảnh: $e');
        }
      } else {
        _showMessage('Không thể chụp ảnh màn hình');
      }
    } catch (e) {
      _showMessage('Lỗi khi chụp ảnh: $e');
    } finally {
      setState(() {
        _isCapturing = false;
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Screenshot(controller: _screenshotController, child: widget.child),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: "basic_screenshot_fab",
            onPressed: _isCapturing ? null : _captureScreenshot,
            backgroundColor: Colors.blue.withOpacity(0.8),
            child:
                _isCapturing
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
          ),
        ),
      ],
    );
  }
}
