import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../screens/screenshot_gallery_screen.dart';

class EnhancedScreenshotWrapper extends StatefulWidget {
  final Widget child;
  final String? screenName;

  const EnhancedScreenshotWrapper({
    super.key,
    required this.child,
    this.screenName,
  });

  @override
  State<EnhancedScreenshotWrapper> createState() =>
      _EnhancedScreenshotWrapperState();
}

class _EnhancedScreenshotWrapperState extends State<EnhancedScreenshotWrapper> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  Future<void> _captureScreenshot() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Capture screenshot
      final Uint8List? image = await _screenshotController.capture();

      if (image != null) {
        // Save to documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        final screenshotsDir = Directory('${documentsDir.path}/screenshots');

        // Create screenshots directory if it doesn't exist
        if (!await screenshotsDir.exists()) {
          await screenshotsDir.create(recursive: true);
        }

        final fileName =
            '${widget.screenName ?? 'screenshot_${DateTime.now().millisecondsSinceEpoch}'}.png';
        final file = File('${screenshotsDir.path}/$fileName');

        // Write image data to file
        await file.writeAsBytes(image);

        // Verify file exists and has content
        if (await file.exists() && await file.length() > 0) {
          _showMessage('Đã lưu ảnh chụp màn hình thành công!');
        } else {
          _showMessage('Không thể tạo file ảnh');
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
    return Stack(
      children: [
        Screenshot(controller: _screenshotController, child: widget.child),
        // Screenshot button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: "enhanced_screenshot_fab",
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
        // Gallery button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 80,
          child: FloatingActionButton.small(
            heroTag: "enhanced_gallery_fab",
            onPressed: _openGallery,
            backgroundColor: Colors.purple.withOpacity(0.8),
            child: const Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
