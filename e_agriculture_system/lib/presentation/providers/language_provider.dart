import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en', 'US');
  
  Locale get currentLocale => _currentLocale;
  
  String get currentLanguageCode => _currentLocale.languageCode;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }
  
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await _saveLanguage(languageCode);
    notifyListeners();
  }
  
  Future<void> setEnglish() async {
    await setLanguage('en');
  }
  
  Future<void> setSinhala() async {
    await setLanguage('si');
  }
  
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isSinhala => _currentLocale.languageCode == 'si';
  
  String get languageName {
    switch (_currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'si':
        return 'සිංහල';
      default:
        return 'English';
    }
  }
}
