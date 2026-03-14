import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  Timer? _timer;
  static const String _themePrefKey = 'theme_preference';

  String _currentPreference = 'auto';

  ThemeCubit() : super(ThemeMode.system) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _currentPreference = prefs.getString(_themePrefKey) ?? 'auto';
    _applyTheme();
    _startTimeChecker();
  }

  Future<void> changeTheme(String newPreference) async {
    _currentPreference = newPreference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, newPreference);
    _applyTheme();
  }

  void _applyTheme() {
    if (_currentPreference == 'light') {
      emit(ThemeMode.light);
    } else if (_currentPreference == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(_calculateTimeBasedTheme());
    }
  }

  static ThemeMode _calculateTimeBasedTheme() {
    final hour = DateTime.now().hour;
    return (hour >= 6 && hour < 18) ? ThemeMode.light : ThemeMode.dark;
  }

  void _startTimeChecker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_currentPreference == 'auto') {
        final newMode = _calculateTimeBasedTheme();
        if (state != newMode) emit(newMode);
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  String get currentPreference => _currentPreference;
}
