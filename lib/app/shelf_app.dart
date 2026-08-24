import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_providers.dart';
import 'shelf_shell.dart';

class ShelfApp extends ConsumerWidget {
  const ShelfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shelf',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: ShelfShell(
        onToggleTheme: ref.read(themeModeProvider.notifier).toggle,
      ),
    );
  }
}

