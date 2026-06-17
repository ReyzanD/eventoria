import 'package:flutter/material.dart';
import 'breakpoints.dart';

enum ScreenType { mobile, tablet, desktop }

extension ScreenContext on BuildContext {
  ScreenType get screenType {
    final width = MediaQuery.of(this).size.width;
    if (width <= kMobileMaxWidth) return ScreenType.mobile;
    if (width <= kTabletMaxWidth) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screen = context.screenType;
    switch (screen) {
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
}
