import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../screens/screenshot_gallery_screen.dart';

class AdvancedScrollableScreenshotWrapper extends StatefulWidget {
  final Widget child;
  final String? screenName;
  final bool includeAppBar;
  final Color? backgroundColor;

  const AdvancedScrollableScreenshotWrapper({
    super.key,
    required this.child,
    this.screenName,
    this.includeAppBar = true,
    this.backgroundColor,
  });

  @override
  State<AdvancedScrollableScreenshotWrapper> createState() =>
      _AdvancedScrollableScreenshotWrapperState();
}

class _AdvancedScrollableScreenshotWrapperState
    extends State<AdvancedScrollableScreenshotWrapper> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isCapturing = false;

  Future<void> _showScreenshotOptionsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tùy chọn chụp ảnh'),
          content: const Text('Bạn muốn chụp ảnh như thế nào?'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.fullscreen, color: Colors.blue),
              label: const Text('Toàn màn hình\n(bao gồm AppBar)'),
              onPressed: () {
                Navigator.of(context).pop();
                _captureAdvancedScrollableScreenshot(includeAppBar: true);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.crop_free, color: Colors.green),
              label: const Text('Chỉ nội dung\n(không có AppBar)'),
              onPressed: () {
                Navigator.of(context).pop();
                _captureAdvancedScrollableScreenshot(includeAppBar: false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureAdvancedScrollableScreenshot({
    bool? includeAppBar,
  }) async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Wait for UI to settle
      await Future.delayed(const Duration(milliseconds: 500));

      // Determine which content to capture
      final bool shouldIncludeAppBar = includeAppBar ?? widget.includeAppBar;

      // Find any ScrollController in the widget tree
      final ScrollController? scrollController = _findScrollController(context);
      double? originalOffset;

      if (scrollController != null && scrollController.hasClients) {
        // Save current scroll position
        originalOffset = scrollController.offset;

        // Scroll to top first
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        // Wait for scroll animation to complete
        await Future.delayed(const Duration(milliseconds: 400));
      }

      ui.Image? image;

      if (shouldIncludeAppBar) {
        // Try to find the parent Scaffold to capture everything including AppBar
        RenderRepaintBoundary? scaffoldBoundary = _findScaffoldRepaintBoundary(
          context,
        );

        if (scaffoldBoundary != null) {
          // Found scaffold boundary, capture it
          image = await scaffoldBoundary.toImage(pixelRatio: 3.0);
        } else {
          // Fallback to current boundary
          RenderRepaintBoundary? boundary =
              _repaintBoundaryKey.currentContext?.findRenderObject()
                  as RenderRepaintBoundary?;

          if (boundary == null) {
            _showMessage('Không thể tìm thấy boundary để chụp ảnh');
            return;
          }

          image = await boundary.toImage(pixelRatio: 3.0);
        }
      } else {
        // For body-only capture, capture the current boundary which should be body-only
        RenderRepaintBoundary? boundary =
            _repaintBoundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;

        if (boundary == null) {
          _showMessage('Không thể tìm thấy boundary để chụp ảnh');
          return;
        }

        // Since the RepaintBoundary is around the body content only,
        // this should capture just the body without AppBar
        print(
          'Capturing body-only image from boundary: ${boundary.runtimeType}',
        );
        print('Boundary size: ${boundary.size}');
        image = await boundary.toImage(pixelRatio: 3.0);
        print('Captured image size: ${image.width}x${image.height}');
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

        final String appBarSuffix = shouldIncludeAppBar ? 'full' : 'body';
        final fileName =
            '${widget.screenName ?? 'advanced_scroll'}_${appBarSuffix}_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${screenshotsDir.path}/$fileName');

        // Write image data to file
        await file.writeAsBytes(imageBytes);

        // Verify file exists and has content
        if (await file.exists() && await file.length() > 0) {
          final String message =
              shouldIncludeAppBar
                  ? 'Đã lưu ảnh toàn màn hình (bao gồm AppBar) thành công!'
                  : 'Đã lưu ảnh nội dung (chỉ body, không có AppBar) thành công!';
          _showMessage(message);
        } else {
          _showMessage('Không thể tạo file ảnh');
        }
      } else {
        _showMessage('Không thể chuyển đổi ảnh');
      }

      // Restore original scroll position if possible
      if (scrollController != null &&
          scrollController.hasClients &&
          originalOffset != null) {
        await Future.delayed(const Duration(milliseconds: 200));
        scrollController.animateTo(
          originalOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      _showMessage('Lỗi khi chụ scroll ảnh: $e');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  // Helper method to find ScrollController in widget tree
  ScrollController? _findScrollController(BuildContext context) {
    try {
      // Try to find a scrollable widget
      final RenderObject? renderObject = context.findRenderObject();
      if (renderObject != null) {
        // Look for RenderViewport or similar scrollable render objects
        RenderObject? current = renderObject;
        while (current != null) {
          if (current is RenderViewport) {
            // Try to get the associated ScrollController
            return Scrollable.of(context).widget.controller;
          }
          current = current.parent;
        }
      }
    } catch (e) {
      // If we can't find a scroll controller, that's okay
      print('Could not find scroll controller: $e');
    }
    return null;
  }

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
  Future<void> showScreenshotDialog() async {
    if (!_isCapturing) {
      await _showScreenshotOptionsDialog();
    }
  }

  void openGallery() {
    _openGallery();
  }

  bool get isCapturing => _isCapturing;
}
