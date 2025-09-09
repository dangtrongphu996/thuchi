import 'package:flutter/material.dart';
import 'screen_wrapper.dart';

/// Helper để test chức năng screenshot
class ScreenshotTestScreen extends StatelessWidget {
  const ScreenshotTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screenName: 'test_screenshot_${DateTime.now().millisecondsSinceEpoch}',
      useAdvancedScrollable: true, // Có dialog chọn có/không AppBar
      includeAppBar: true, // Mặc định bao gồm AppBar
      appBar: AppBar(
        title: const Text('Test Screenshot'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 100, color: Colors.purple),
              SizedBox(height: 20),
              Text(
                'Test Screenshot Functionality',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Nhấn nút chụp ảnh để test',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Tính năng:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('• Chụp toàn màn hình (có AppBar)'),
                      Text('• Chụp chỉ nội dung (không AppBar)'),
                      Text('• Crop tự động AppBar'),
                      Text('• Lưu vào thư mục screenshots'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
