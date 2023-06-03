import 'package:flutter/material.dart';

class MySize {
  static MediaQueryData _mediaQueryData = MediaQueryData();
  static double screenWidth =0;
  static double screenHeight =0;
  static double safeWidth =0;
  static double safeHeight =0;
  static double scaleFactorWidth =0;
  static double scaleFactorHeight =0;

  //Custom sizes
  static double size0 =0;
  static double size2 =0;
  static double size3 =0;
  static double size4 =0;
  static double size5 =0;
  static double size6 =0;
  static double size7 =0;
  static double size8 =0;
  static double size10 =0;
  static double size12 =0;
  static double size14 =0;
  static double size16 =0;
  static double size18 =0;
  static double size20 =0;
  static double size22 =0;
  static double size24 =0;
  static double size26 =0;
  static double size28 =0;
  static double size30 =0;
  static double size32 =0;
  static double size34 =0;
  static double size36 =0;
  static double size38 =0;
  static double size40 =0;
  static double size42 =0;
  static double size44 =0;
  static double size48 =0;
  static double size50 =0;
  static double size52 =0;
  static double size54 =0;
  static double size56 =0;
  static double size60 =0;
  static double size64 =0;
  static double size68 =0;
  static double size72 =0;
  static double size76 =0;
  static double size80 =0;
  static double size90 =0;
  static double size96 =0;
  static double size100 =0;
  static double size120 =0;
  static double size140 =0;
  static double size160 =0;
  static double size180 =0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    double _safeAreaWidth =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    double _safeAreaHeight =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeWidth = (screenWidth - _safeAreaWidth);
    safeHeight = (screenHeight - _safeAreaHeight);

    //Scale factor for responsive UI
    scaleFactorHeight = (safeHeight / 820);
    if (scaleFactorHeight < 1) {
      double diff = (1 - scaleFactorHeight) * (1 - scaleFactorHeight);
      scaleFactorHeight += diff;
    }
    scaleFactorWidth = safeWidth / 392;
    if (scaleFactorWidth < 1) {
      double diff = (1 - scaleFactorWidth) * (1 - scaleFactorWidth);
      scaleFactorWidth += diff;
    }

    //Custom sizes
    size0 = 0;
    size2 = scaleFactorHeight * 2;
    size3 = scaleFactorHeight * 3;
    size4 = scaleFactorHeight * 4;
    size5 = scaleFactorHeight * 5;
    size6 = scaleFactorHeight * 6;
    size7 = scaleFactorHeight * 7;
    size8 = scaleFactorHeight * 8;
    size10 = scaleFactorHeight * 10;
    size12 = scaleFactorHeight * 12;
    size14 = scaleFactorHeight * 14;
    size16 = scaleFactorHeight * 16;
    size18 = scaleFactorHeight * 18;
    size20 = scaleFactorHeight * 20;
    size22 = scaleFactorHeight * 22;
    size24 = scaleFactorHeight * 24;
    size26 = scaleFactorHeight * 26;
    size28 = scaleFactorHeight * 28;
    size30 = scaleFactorHeight * 30;
    size32 = scaleFactorHeight * 32;
    size34 = scaleFactorHeight * 34;
    size36 = scaleFactorHeight * 36;
    size38 = scaleFactorHeight * 38;
    size40 = scaleFactorHeight * 40;
    size42 = scaleFactorHeight * 42;
    size44 = scaleFactorHeight * 44;
    size48 = scaleFactorHeight * 48;
    size50 = scaleFactorHeight * 50;
    size52 = scaleFactorHeight * 52;
    size54 = scaleFactorHeight * 54;
    size56 = scaleFactorHeight * 56;
    size60 = scaleFactorHeight * 60;
    size64 = scaleFactorHeight * 64;
    size68 = scaleFactorHeight * 68;
    size72 = scaleFactorHeight * 72;
    size76 = scaleFactorHeight * 76;
    size80 = scaleFactorHeight * 80;
    size90 = scaleFactorHeight * 90;
    size96 = scaleFactorHeight * 96;
    size100 = scaleFactorHeight * 100;
    size120 = scaleFactorHeight * 120;
    size140 = scaleFactorHeight * 140;
    size160 = scaleFactorHeight * 160;
    size180 = scaleFactorHeight * 180;
  }

  static double getScaledSizeWidth(double size) {
    return (size * scaleFactorWidth);
  }

  static double getScaledSizeHeight(double size) {
    return (size * scaleFactorHeight);
  }
}

class Spacing {
  static EdgeInsetsGeometry zero = EdgeInsets.zero;

  static EdgeInsetsGeometry only({double top = 0,
    double right = 0,
    double bottom = 0,
    double left = 0,
    bool withResponsive = true}) {
    if (withResponsive) {
      return EdgeInsets.only(
          left: MySize.getScaledSizeHeight(left),
          right: MySize.getScaledSizeHeight(right),
          top: MySize.getScaledSizeHeight(top),
          bottom: MySize.getScaledSizeHeight(bottom));
    } else {
      return EdgeInsets.only(
          left: left, right: right, top: top, bottom: bottom);
    }
  }

  static EdgeInsetsGeometry fromLTRB(double left, double top, double right,
      double bottom,
      {bool withResponsive = true}) {
    return Spacing.only(
        bottom: bottom,
        top: top,
        right: right,
        left: left,
        withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry all(double spacing, {bool withResponsive = true}) {
    return Spacing.only(
        bottom: spacing,
        top: spacing,
        right: spacing,
        left: spacing,
        withResponsive: withResponsive);
  }


  static EdgeInsetsGeometry left(double spacing, {bool withResponsive = true}) {
    return Spacing.only(left: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry top(double spacing, {bool withResponsive = true}) {
    return Spacing.only(top: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry right(double spacing,
      {bool withResponsive = true}) {
    return Spacing.only(right: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry bottom(double spacing,
      {bool withResponsive = true}) {
    return Spacing.only(bottom: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry horizontal(double spacing,
      {bool withResponsive = true}) {
    return Spacing.only(
        left: spacing, right: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry vertical(double spacing,
      {bool withResponsive = true}) {
    return Spacing.only(
        top: spacing, bottom: spacing, withResponsive: withResponsive);
  }

  static EdgeInsetsGeometry symmetric({double vertical=0, double horizontal=0,
      bool withResponsive = true}) {
    return Spacing.only(top: vertical,
        right: horizontal,
        left: horizontal,
        bottom: vertical,
        withResponsive: withResponsive);
  }


}
