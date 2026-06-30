import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_prueba/core/theme.dart';

void main() {
  group('AppTheme', () {
    test('buildDarkTheme returns dark theme', () {
      final theme = buildDarkTheme();

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(theme.cardColor, const Color(0xFF1E1E1E));
      expect(theme.dividerColor, const Color(0xFF2A2A2A));
    });

    test('colorScheme has correct primary color', () {
      final theme = buildDarkTheme();

      expect(theme.colorScheme.primary, const Color(0xFF3B82F6));
      expect(theme.colorScheme.error, const Color(0xFFEF4444));
    });

    test('appBar has correct background', () {
      final theme = buildDarkTheme();

      expect(theme.appBarTheme.backgroundColor, const Color(0xFF181818));
      expect(theme.appBarTheme.foregroundColor, Colors.white);
    });

    test('drawer has correct background', () {
      final theme = buildDarkTheme();

      expect(theme.drawerTheme.backgroundColor, const Color(0xFF181818));
    });
  });
}
