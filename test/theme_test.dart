import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_book_tracker/core/theme/app_colors.dart';
import 'package:shelf_book_tracker/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light theme preserves Phase 2 core colors', () {
    final theme = AppTheme.light;

    expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
    expect(theme.colorScheme.surface, AppColors.lightSurface);
    expect(theme.colorScheme.primary, AppColors.lightPrimary);
  });

  test('dark theme preserves Phase 2 core colors', () {
    final theme = AppTheme.dark;

    expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
    expect(theme.colorScheme.surface, AppColors.darkSurface);
    expect(
      theme.navigationBarTheme.indicatorColor,
      AppColors.darkNavigationIndicator,
    );
  });

  test('theme exposes Inter body text styles', () {
    final style = AppTheme.light.textTheme.bodyMedium;

    expect(style?.fontFamily, isNotNull);
  });
}
