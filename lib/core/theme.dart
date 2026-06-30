import 'package:flutter/material.dart';

const appPrimaryColor = Color(0xFF3B82F6);
const appBgColor = Color(0xFF121212);
const appSidebarColor = Color(0xFF181818);
const appCardColor = Color(0xFF1E1E1E);
const appBorderColor = Color(0xFF2A2A2A);
const appSuccessColor = Color(0xFF22C55E);
const appErrorColor = Color(0xFFEF4444);
const appWarningColor = Color(0xFFF59E0B);
const appPrimaryText = Colors.white;
const appSecondaryText = Color(0xFFB3B3B3);

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: appBgColor,
    cardColor: appCardColor,
    dividerColor: appBorderColor,
    colorScheme: const ColorScheme.dark(
      primary: appPrimaryColor,
      secondary: appPrimaryColor,
      surface: appCardColor,
      error: appErrorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: appSidebarColor,
      foregroundColor: appPrimaryText,
      elevation: 0,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: appSidebarColor,
      indicatorColor: appPrimaryColor.withValues(alpha: 0.2),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: appSidebarColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: appPrimaryText),
      bodyMedium: TextStyle(color: appSecondaryText),
      titleLarge: TextStyle(color: appPrimaryText),
      titleMedium: TextStyle(color: appPrimaryText),
    ),
  );
}
