import 'package:flutter/material.dart';
import '../screens/screenshot_gallery_screen.dart';

class SimpleGalleryWrapper extends StatelessWidget {
  final Widget child;

  const SimpleGalleryWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Gallery button only
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: "simple_gallery_fab",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenshotGalleryScreen(),
                ),
              );
            },
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
