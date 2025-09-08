import 'package:flutter/material.dart';
import 'screenshot_wrapper.dart';
import 'simple_screenshot_wrapper.dart';
import 'enhanced_screenshot_wrapper.dart';
import 'scrollable_screenshot_wrapper.dart';
import 'simple_gallery_wrapper.dart';
import 'safe_screenshot_wrapper.dart';
import 'hero_free_screenshot_wrapper.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;
  final String? screenName;
  final bool enableScreenshot;
  final bool useSimpleScreenshot;
  final bool showGalleryButton;
  final bool useEnhanced;
  final bool useScrollable;
  final bool useSimpleGallery;
  final bool useSafe;
  final bool useHeroFree;

  const AppWrapper({
    super.key,
    required this.child,
    this.screenName,
    this.enableScreenshot = true,
    this.useSimpleScreenshot = false,
    this.showGalleryButton = true,
    this.useEnhanced = false,
    this.useScrollable = false,
    this.useSimpleGallery = false,
    this.useSafe = false,
    this.useHeroFree = false,
  });

  @override
  Widget build(BuildContext context) {
    if (enableScreenshot) {
      if (useHeroFree) {
        return HeroFreeScreenshotWrapper(screenName: screenName, child: child);
      } else if (useSafe) {
        return SafeScreenshotWrapper(screenName: screenName, child: child);
      } else if (useSimpleGallery) {
        return SimpleGalleryWrapper(child: child);
      } else if (useScrollable) {
        return ScrollableScreenshotWrapper(
          screenName: screenName,
          child: child,
        );
      } else if (useEnhanced) {
        return EnhancedScreenshotWrapper(screenName: screenName, child: child);
      } else if (useSimpleScreenshot) {
        return SimpleScreenshotWrapper(screenName: screenName, child: child);
      } else {
        return ScreenshotWrapper(screenName: screenName, child: child);
      }
    }
    return child;
  }
}
