import 'package:flutter/material.dart';
import 'advanced_scrollable_screenshot_wrapper.dart';
import 'full_page_screenshot_wrapper.dart';
import 'app_wrapper.dart';

/// A comprehensive wrapper that can wrap the entire screen including AppBar
class ScreenWrapper extends StatelessWidget {
  final String? screenName;
  final AppBar? appBar;
  final Widget body;
  final Color? backgroundColor;
  final FloatingActionButton? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool resizeToAvoidBottomInset;

  // Screenshot options
  final bool enableScreenshot;
  final bool useAdvancedScrollable;
  final bool useFullPage;
  final bool includeAppBar;
  final bool useSimpleScreenshot;
  final bool useEnhanced;
  final bool useScrollable;
  final bool useSimpleGallery;
  final bool useSafe;
  final bool useHeroFree;

  const ScreenWrapper({
    super.key,
    this.screenName,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset = true,
    this.enableScreenshot = true,
    this.useAdvancedScrollable = false,
    this.useFullPage = false,
    this.includeAppBar = true,
    this.useSimpleScreenshot = false,
    this.useEnhanced = false,
    this.useScrollable = false,
    this.useSimpleGallery = false,
    this.useSafe = false,
    this.useHeroFree = false,
  });

  @override
  Widget build(BuildContext context) {
    // If screenshot is disabled, return scaffold directly
    if (!enableScreenshot) {
      return Scaffold(
        appBar: appBar,
        body: body,
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        drawer: drawer,
        endDrawer: endDrawer,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      );
    }

    // Create wrapper widgets for accessing methods
    Widget wrappedContent;
    GlobalKey wrapperKey = GlobalKey();

    if (useAdvancedScrollable) {
      wrappedContent = AdvancedScrollableScreenshotWrapper(
        key: wrapperKey,
        screenName: screenName,
        includeAppBar: includeAppBar,
        backgroundColor: backgroundColor,
        child: body,
      );
    } else if (useFullPage) {
      wrappedContent = FullPageScreenshotWrapper(
        key: wrapperKey,
        screenName: screenName,
        includeAppBar: includeAppBar,
        backgroundColor: backgroundColor,
        child: body,
      );
    } else {
      // Use AppWrapper for body only (backward compatibility)
      return Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        drawer: drawer,
        endDrawer: endDrawer,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: AppWrapper(
          screenName: screenName,
          enableScreenshot: enableScreenshot,
          useSimpleScreenshot: useSimpleScreenshot,
          useEnhanced: useEnhanced,
          useScrollable: useScrollable,
          useSimpleGallery: useSimpleGallery,
          useSafe: useSafe,
          useHeroFree: useHeroFree,
          child: body,
        ),
      );
    }

    // Create AppBar with screenshot actions
    AppBar? enhancedAppBar;
    if (appBar != null) {
      final originalActions = appBar!.actions ?? [];
      enhancedAppBar = AppBar(
        key: appBar!.key,
        leading: appBar!.leading,
        automaticallyImplyLeading: appBar!.automaticallyImplyLeading,
        title: appBar!.title,
        actions: [
          ...originalActions,
          PopupMenuButton<String>(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Chụp ảnh màn hình',
            onSelected: (value) async {
              final state = wrapperKey.currentState;
              if (state != null) {
                switch (value) {
                  case 'screenshot':
                    if (useAdvancedScrollable) {
                      // Call method directly using dynamic
                      await (state as dynamic).showScreenshotDialog();
                    } else if (useFullPage) {
                      await (state as dynamic).captureScreenshot();
                    }
                    break;
                  case 'gallery':
                    if (useAdvancedScrollable || useFullPage) {
                      (state as dynamic).openGallery();
                    }
                    break;
                }
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'screenshot',
                    child: Row(
                      children: [
                        Icon(
                          useAdvancedScrollable
                              ? Icons.chrome_reader_mode
                              : Icons.fullscreen,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          useAdvancedScrollable
                              ? 'Chụp ảnh (tùy chọn)'
                              : 'Chụp toàn màn hình',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Xem thư viện ảnh'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        flexibleSpace: appBar!.flexibleSpace,
        bottom: appBar!.bottom,
        elevation: appBar!.elevation,
        scrolledUnderElevation: appBar!.scrolledUnderElevation,
        notificationPredicate: appBar!.notificationPredicate,
        shadowColor: appBar!.shadowColor,
        surfaceTintColor: appBar!.surfaceTintColor,
        shape: appBar!.shape,
        backgroundColor: appBar!.backgroundColor,
        foregroundColor: appBar!.foregroundColor,
        iconTheme: appBar!.iconTheme,
        actionsIconTheme: appBar!.actionsIconTheme,
        primary: appBar!.primary,
        centerTitle: appBar!.centerTitle,
        excludeHeaderSemantics: appBar!.excludeHeaderSemantics,
        titleSpacing: appBar!.titleSpacing,
        toolbarOpacity: appBar!.toolbarOpacity,
        bottomOpacity: appBar!.bottomOpacity,
        toolbarHeight: appBar!.toolbarHeight,
        leadingWidth: appBar!.leadingWidth,
        toolbarTextStyle: appBar!.toolbarTextStyle,
        titleTextStyle: appBar!.titleTextStyle,
        systemOverlayStyle: appBar!.systemOverlayStyle,
        forceMaterialTransparency: appBar!.forceMaterialTransparency,
        clipBehavior: appBar!.clipBehavior,
      );
    }

    // Create the scaffold with wrapped content
    final scaffold = Scaffold(
      appBar: enhancedAppBar ?? appBar,
      body: wrappedContent,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );

    return scaffold;
  }
}
