import 'package:flutter/material.dart';

/// Screen type enumeration for different device categories
enum ScreenType { mobile, tablet, desktop }

/// Utility class for responsive design helpers
class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  /// Check if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  /// Check if the screen is considered small (mobile)
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < mobileBreakpoint;
  }

  /// Check if the screen is tablet size
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= mobileBreakpoint && size.width < tabletBreakpoint;
  }

  /// Check if the screen is desktop size
  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= tabletBreakpoint;
  }

  /// Get screen type enum
  static ScreenType getScreenType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < mobileBreakpoint) return ScreenType.mobile;
    if (size.width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  /// Get responsive spacing based on orientation and screen size
  static double getResponsiveSpacing(
    BuildContext context, {
    double portraitSpacing = 0.03,
    double landscapeSpacing = 0.02,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
  }) {
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final screenType = getScreenType(context);

    // Use specific values if provided
    if (screenType == ScreenType.mobile) {
      if (isLandscape && mobileLandscape != null) {
        return size.height * mobileLandscape;
      } else if (!isLandscape && mobilePortrait != null) {
        return size.height * mobilePortrait;
      }
    } else if (screenType == ScreenType.tablet) {
      if (isLandscape && tabletLandscape != null) {
        return size.height * tabletLandscape;
      } else if (!isLandscape && tabletPortrait != null) {
        return size.height * tabletPortrait;
      }
    }

    // Fallback to default values
    return size.height * (isLandscape ? landscapeSpacing : portraitSpacing);
  }

  /// Get responsive height based on orientation and screen size
  static double getResponsiveHeight(
    BuildContext context, {
    double portraitHeight = 0.3,
    double landscapeHeight = 0.25,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) {
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final screenType = getScreenType(context);

    // Use specific values based on screen type and orientation
    switch (screenType) {
      case ScreenType.mobile:
        if (isLandscape && mobileLandscape != null) {
          return size.height * mobileLandscape;
        } else if (!isLandscape && mobilePortrait != null) {
          return size.height * mobilePortrait;
        }
        break;
      case ScreenType.tablet:
        if (isLandscape && tabletLandscape != null) {
          return size.height * tabletLandscape;
        } else if (!isLandscape && tabletPortrait != null) {
          return size.height * tabletPortrait;
        }
        break;
      case ScreenType.desktop:
        if (isLandscape && desktopLandscape != null) {
          return size.height * desktopLandscape;
        } else if (!isLandscape && desktopPortrait != null) {
          return size.height * desktopPortrait;
        }
        break;
    }

    // Fallback to default values
    return size.height * (isLandscape ? landscapeHeight : portraitHeight);
  }

  /// Get responsive font size based on screen type and orientation
  static double getResponsiveFontSize(
    BuildContext context, {
    double smallScreenSize = 0.04,
    double largeScreenSize = 0.03,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) {
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final screenType = getScreenType(context);

    // Use specific values based on screen type and orientation
    switch (screenType) {
      case ScreenType.mobile:
        if (isLandscape && mobileLandscape != null) {
          return size.width * mobileLandscape;
        } else if (!isLandscape && mobilePortrait != null) {
          return size.width * mobilePortrait;
        }
        break;
      case ScreenType.tablet:
        if (isLandscape && tabletLandscape != null) {
          return size.width * tabletLandscape;
        } else if (!isLandscape && tabletPortrait != null) {
          return size.width * tabletPortrait;
        }
        break;
      case ScreenType.desktop:
        if (isLandscape && desktopLandscape != null) {
          return size.width * desktopLandscape;
        } else if (!isLandscape && desktopPortrait != null) {
          return size.width * desktopPortrait;
        }
        break;
    }

    // Fallback to default values
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    return size.width * (isSmallScreen ? smallScreenSize : largeScreenSize);
  }

  /// Get responsive width based on orientation and screen size
  static double getResponsiveWidth(
    BuildContext context, {
    double portraitWidth = 0.8,
    double landscapeWidth = 0.6,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) {
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final screenType = getScreenType(context);

    // Use specific values based on screen type and orientation
    switch (screenType) {
      case ScreenType.mobile:
        if (isLandscape && mobileLandscape != null) {
          return size.width * mobileLandscape;
        } else if (!isLandscape && mobilePortrait != null) {
          return size.width * mobilePortrait;
        }
        break;
      case ScreenType.tablet:
        if (isLandscape && tabletLandscape != null) {
          return size.width * tabletLandscape;
        } else if (!isLandscape && tabletPortrait != null) {
          return size.width * tabletPortrait;
        }
        break;
      case ScreenType.desktop:
        if (isLandscape && desktopLandscape != null) {
          return size.width * desktopLandscape;
        } else if (!isLandscape && desktopPortrait != null) {
          return size.width * desktopPortrait;
        }
        break;
    }

    // Fallback to default values
    return size.width * (isLandscape ? landscapeWidth : portraitWidth);
  }

  /// Create a responsive SizedBox for spacing
  static Widget responsiveSpacing(
    BuildContext context, {
    double portraitSpacing = 0.03,
    double landscapeSpacing = 0.02,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
  }) {
    return SizedBox(
      height: getResponsiveSpacing(
        context,
        portraitSpacing: portraitSpacing,
        landscapeSpacing: landscapeSpacing,
        mobilePortrait: mobilePortrait,
        mobileLandscape: mobileLandscape,
        tabletPortrait: tabletPortrait,
        tabletLandscape: tabletLandscape,
      ),
    );
  }

  /// Wrap content in a responsive scrollable container
  static Widget responsiveScrollableColumn({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  /// Create a responsive container that adapts to orientation and screen size
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    double? portraitHeight,
    double? landscapeHeight,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
    EdgeInsetsGeometry? padding,
    Decoration? decoration,
    double? width,
  }) {
    final size = MediaQuery.of(context).size;

    double? height;
    if (portraitHeight != null ||
        landscapeHeight != null ||
        mobilePortrait != null ||
        mobileLandscape != null ||
        tabletPortrait != null ||
        tabletLandscape != null ||
        desktopPortrait != null ||
        desktopLandscape != null) {
      height = getResponsiveHeight(
        context,
        portraitHeight: portraitHeight ?? 0.3,
        landscapeHeight: landscapeHeight ?? 0.25,
        mobilePortrait: mobilePortrait,
        mobileLandscape: mobileLandscape,
        tabletPortrait: tabletPortrait,
        tabletLandscape: tabletLandscape,
        desktopPortrait: desktopPortrait,
        desktopLandscape: desktopLandscape,
      );
    }

    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }

  /// Get responsive padding based on screen size and orientation
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double defaultPadding = 0.05,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) {
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final screenType = getScreenType(context);

    double paddingValue = defaultPadding;

    switch (screenType) {
      case ScreenType.mobile:
        if (isLandscape && mobileLandscape != null) {
          paddingValue = mobileLandscape;
        } else if (!isLandscape && mobilePortrait != null) {
          paddingValue = mobilePortrait;
        }
        break;
      case ScreenType.tablet:
        if (isLandscape && tabletLandscape != null) {
          paddingValue = tabletLandscape;
        } else if (!isLandscape && tabletPortrait != null) {
          paddingValue = tabletPortrait;
        }
        break;
      case ScreenType.desktop:
        if (isLandscape && desktopLandscape != null) {
          paddingValue = desktopLandscape;
        } else if (!isLandscape && desktopPortrait != null) {
          paddingValue = desktopPortrait;
        }
        break;
    }

    final padding = size.width * paddingValue;
    return EdgeInsets.all(padding);
  }

  /// Get responsive margin based on screen size and orientation
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double defaultMargin = 0.02,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) {
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final screenType = getScreenType(context);

    double marginValue = defaultMargin;

    switch (screenType) {
      case ScreenType.mobile:
        if (isLandscape && mobileLandscape != null) {
          marginValue = mobileLandscape;
        } else if (!isLandscape && mobilePortrait != null) {
          marginValue = mobilePortrait;
        }
        break;
      case ScreenType.tablet:
        if (isLandscape && tabletLandscape != null) {
          marginValue = tabletLandscape;
        } else if (!isLandscape && tabletPortrait != null) {
          marginValue = tabletPortrait;
        }
        break;
      case ScreenType.desktop:
        if (isLandscape && desktopLandscape != null) {
          marginValue = desktopLandscape;
        } else if (!isLandscape && desktopPortrait != null) {
          marginValue = desktopPortrait;
        }
        break;
    }

    final margin = size.width * marginValue;
    return EdgeInsets.all(margin);
  }
}

/// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  ScreenType get screenType => ResponsiveUtils.getScreenType(this);

  double responsiveSpacing({
    double portraitSpacing = 0.03,
    double landscapeSpacing = 0.02,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
  }) =>
      ResponsiveUtils.getResponsiveSpacing(
        this,
        portraitSpacing: portraitSpacing,
        landscapeSpacing: landscapeSpacing,
        mobilePortrait: mobilePortrait,
        mobileLandscape: mobileLandscape,
        tabletPortrait: tabletPortrait,
        tabletLandscape: tabletLandscape,
      );

  double responsiveHeight({
    double portraitHeight = 0.3,
    double landscapeHeight = 0.25,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) =>
      ResponsiveUtils.getResponsiveHeight(
        this,
        portraitHeight: portraitHeight,
        landscapeHeight: landscapeHeight,
        mobilePortrait: mobilePortrait,
        mobileLandscape: mobileLandscape,
        tabletPortrait: tabletPortrait,
        tabletLandscape: tabletLandscape,
        desktopPortrait: desktopPortrait,
        desktopLandscape: desktopLandscape,
      );

  double responsiveWidth({
    double portraitWidth = 0.8,
    double landscapeWidth = 0.6,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) =>
      ResponsiveUtils.getResponsiveWidth(
        this,
        portraitWidth: portraitWidth,
        landscapeWidth: landscapeWidth,
        mobilePortrait: mobilePortrait,
        mobileLandscape: mobileLandscape,
        tabletPortrait: tabletPortrait,
        tabletLandscape: tabletLandscape,
        desktopPortrait: desktopPortrait,
        desktopLandscape: desktopLandscape,
      );

  double responsiveFontSize({
    double smallScreenSize = 0.04,
    double largeScreenSize = 0.03,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) =>
      ResponsiveUtils.getResponsiveFontSize(
        this,
        smallScreenSize: smallScreenSize,
        largeScreenSize: largeScreenSize,
        mobilePortrait: mobilePortrait,
        mobileLandscape: mobileLandscape,
        tabletPortrait: tabletPortrait,
        tabletLandscape: tabletLandscape,
        desktopPortrait: desktopPortrait,
        desktopLandscape: desktopLandscape,
      );

  EdgeInsets responsivePadding({
    double defaultPadding = 0.05,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) =>
      ResponsiveUtils.getResponsivePadding(
        this,
        defaultPadding: defaultPadding,
        mobilePortrait: mobilePortrait,
        mobileLandscape: mobileLandscape,
        tabletPortrait: tabletPortrait,
        tabletLandscape: tabletLandscape,
        desktopPortrait: desktopPortrait,
        desktopLandscape: desktopLandscape,
      );

  EdgeInsets responsiveMargin({
    double defaultMargin = 0.02,
    double? mobilePortrait,
    double? mobileLandscape,
    double? tabletPortrait,
    double? tabletLandscape,
    double? desktopPortrait,
    double? desktopLandscape,
  }) =>
      ResponsiveUtils.getResponsiveMargin(
        this,
        defaultMargin: defaultMargin,
        mobilePortrait: mobilePortrait,
        mobileLandscape: mobileLandscape,
        tabletPortrait: tabletPortrait,
        tabletLandscape: tabletLandscape,
        desktopPortrait: desktopPortrait,
        desktopLandscape: desktopLandscape,
      );
}
