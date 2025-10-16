import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_storage_service.dart';
import '../config/app_config.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale(AppConfig.defaultLanguage)) {
    _load();
  }

  void _load() {
    try {
      final code = LocalStorageService.getLanguage();
      state = Locale(code);
    } catch (_) {
      state = const Locale(AppConfig.defaultLanguage);
    }
  }

  Future<void> setLocale(String code) async {
    await LocalStorageService.setLanguage(code);
    state = Locale(code);
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());
