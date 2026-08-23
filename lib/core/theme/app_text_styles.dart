import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextTheme textTheme(Brightness brightness, Color onSurface) {
    final base = ThemeData(brightness: brightness).textTheme;
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return base.apply(
        fontFamily: 'Inter',
        bodyColor: onSurface,
        displayColor: onSurface,
      );
    }

    return GoogleFonts.interTextTheme(base).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );
  }

  static TextStyle editorial(
    BuildContext context,
    double size, {
    double height = 1.2,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return TextStyle(
        fontFamily: 'Merriweather',
        fontSize: size,
        height: height,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      );
    }

    return GoogleFonts.merriweather(
      fontSize: size,
      height: height,
      fontWeight: fontWeight,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle eyebrow(BuildContext context, {Color? color}) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return TextStyle(
        fontFamily: 'Inter',
        color: color ?? Theme.of(context).colorScheme.primary,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: 1.4,
      );
    }

    return GoogleFonts.inter(
      color: color ?? Theme.of(context).colorScheme.primary,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: 1.4,
    );
  }
}
