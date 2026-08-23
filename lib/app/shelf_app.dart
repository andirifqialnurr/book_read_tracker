import 'package:flutter/material.dart';

import 'shelf_shell.dart';

class ShelfApp extends StatefulWidget {
  const ShelfApp({super.key});

  @override
  State<ShelfApp> createState() => _ShelfAppState();
}

class _ShelfAppState extends State<ShelfApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shelf',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: ShelfShell(
        onToggleTheme: () {
          setState(() {
            _themeMode = _themeMode == ThemeMode.light
                ? ThemeMode.dark
                : ThemeMode.light;
          });
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xff151416) : const Color(0xfff8f6f1),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff5b5fa8),
        brightness: brightness,
        surface: isDark ? const Color(0xff211f21) : const Color(0xfffffdf8),
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: base.scaffoldBackgroundColor,
        foregroundColor: isDark ? Colors.white : const Color(0xff272426),
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: isDark ? const Color(0xff211f21) : Colors.white,
        indicatorColor: isDark
            ? const Color(0xff3a3867)
            : const Color(0xffe8e7fa),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xff29272a) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xff3a373b) : const Color(0xffebe7df),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xff5b5fa8), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: BorderSide.none,
      ),
    );
  }
}

