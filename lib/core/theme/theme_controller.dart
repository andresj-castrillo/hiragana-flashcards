import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's chosen [ThemeMode] and persists it locally
/// 
/// the user can pin light or dark
///
/// Extends [ValueNotifier] so [MaterialApp] can rebuild via [ValueListenableBuilder] whenever the mode changes
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._(this._prefs, super.initialMode);

  static const _kKey = 'theme_mode_v1';
  final SharedPreferences _prefs;

  static Future<ThemeController> create() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = _parse(prefs.getString(_kKey));
    return ThemeController._(prefs, mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (value == mode) return;
    value = mode;
    await _prefs.setString(_kKey, mode.name);
  }

  static ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
