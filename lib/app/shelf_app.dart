import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
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
}

