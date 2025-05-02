import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  static const String _languageKey = 'language';
  static const String _countryKey = 'country';

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    final countryCode = prefs.getString(_countryKey) ?? 'US';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, newLocale.languageCode);
    await prefs.setString(_countryKey, newLocale.countryCode ?? 'US');
    notifyListeners();
  }
}