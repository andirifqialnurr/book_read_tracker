import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const lightBackground = Color(0xfff8f6f1);
  static const darkBackground = Color(0xff151416);

  static const lightSurface = Color(0xfffffdf8);
  static const darkSurface = Color(0xff211f21);

  static const lightPrimary = Color(0xff5b5fa8);
  static const darkPrimary = Color(0xffb9b9f1);

  static const lightOnSurface = Color(0xff272426);
  static const darkOnSurface = Colors.white;

  static const lightInputFill = Colors.white;
  static const darkInputFill = Color(0xff29272a);

  static const lightInputBorder = Color(0xffebe7df);
  static const darkInputBorder = Color(0xff3a373b);

  static const lightNavigationBackground = Colors.white;
  static const darkNavigationBackground = darkSurface;
  static const lightNavigationIndicator = Color(0xffe8e7fa);
  static const darkNavigationIndicator = Color(0xff3a3867);

  static const star = Color(0xffd89547);

  static const wantToReadLight = Color(0xff7c6a55);
  static const wantToReadDark = Color(0xffd7b995);
  static const readingLight = lightPrimary;
  static const readingDark = darkPrimary;
  static const finishedLight = Color(0xff487b66);
  static const finishedDark = Color(0xffa4d1b7);
  static const droppedLight = Color(0xffa05c56);
  static const droppedDark = Color(0xffe0aba4);

  static const defaultCover = Color(0xff6b6d9e);
  static const defaultCoverAccent = Color(0xffd9d6f0);

  static const coverIndigo = Color(0xff5b5fa8);
  static const coverIndigoAccent = Color(0xffdedcff);
  static const coverTerracotta = Color(0xffd87555);
  static const coverTerracottaAccent = Color(0xffffd9c4);
  static const coverGreen = Color(0xff477765);
  static const coverGreenAccent = Color(0xffd4eddf);
  static const coverCoral = Color(0xffe07b57);
  static const coverCoralAccent = Color(0xffffdbbe);
  static const coverTeal = Color(0xff426b70);
  static const coverTealAccent = Color(0xffc8ebe2);
  static const coverNightBlue = Color(0xff333b77);
  static const coverNightBlueAccent = Color(0xfff3d99a);
  static const coverDeepBlue = Color(0xff314b65);
  static const coverDeepBlueAccent = Color(0xffb7d2e5);
  static const coverLeaf = Color(0xff54725f);
  static const coverLeafAccent = Color(0xffd2e5c8);

  static Color background(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  static Color surface(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : lightSurface;
  }

  static Color primary(Brightness brightness) {
    return brightness == Brightness.dark ? darkPrimary : lightPrimary;
  }

  static Color onSurface(Brightness brightness) {
    return brightness == Brightness.dark ? darkOnSurface : lightOnSurface;
  }
}
