import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final StorageService _storageService;

  ThemeCubit({required StorageService storageService})
      : _storageService = storageService,
        super(ThemeState(
          themeMode: storageService.getDarkMode() ? ThemeMode.dark : ThemeMode.light,
        ));

  void toggleTheme() {
    final isDark = state.themeMode == ThemeMode.dark;
    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _storageService.setDarkMode(!isDark);
    emit(ThemeState(themeMode: nextMode));
  }

  void setTheme(ThemeMode mode) {
    _storageService.setDarkMode(mode == ThemeMode.dark);
    emit(ThemeState(themeMode: mode));
  }
}
