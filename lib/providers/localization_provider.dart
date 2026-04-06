import 'package:flutter/material.dart';
import 'package:finance_app/services/database_service.dart';

class LocalizationProvider extends ChangeNotifier {
  String _currentLanguage = 'English';
  String get currentLanguage => _currentLanguage;

  // The 22 recognized Indian Languages + English
  final List<String> supportedLanguages = [
    'English', 'Assamese', 'Bengali', 'Bodo', 'Dogri', 'Gujarati',
    'Hindi', 'Kannada', 'Kashmiri', 'Konkani', 'Maithili', 'Malayalam',
    'Manipuri', 'Marathi', 'Nepali', 'Odia', 'Punjabi', 'Sanskrit',
    'Santali', 'Sindhi', 'Tamil', 'Telugu', 'Urdu'
  ];

  LocalizationProvider() {
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() {
    _currentLanguage = DatabaseService.getLanguage() ?? 'English';
    notifyListeners();
  }

  void setLanguage(String language) {
    if (supportedLanguages.contains(language)) {
      _currentLanguage = language;
      DatabaseService.saveLanguage(language);
      notifyListeners();
    }
  }

  // 100% OFFLINE DICTIONARY
  // Add your keys here and their translations in different languages
  final Map<String, Map<String, String>> _dictionary = {
    'Finance Companion': {
      'English': 'Finance Companion',
      'Hindi': 'वित्तीय साथी',
      'Bengali': 'ফাইন্যান্স সঙ্গী',
      'Tamil': 'நிதி সঙ্গী',
      // Add other 19 languages here...
    },
    'Total Balance': {
      'English': 'Total Balance',
      'Hindi': 'कुल शेष',
      'Bengali': 'মোট ব্যালেন্স',
      'Tamil': 'மொத்த இருப்பு',
    },
    'Income': {
      'English': 'Income',
      'Hindi': 'आय',
      'Bengali': 'আয়',
      'Tamil': 'வருமானம்',
    },
    'Expenses': {
      'English': 'Expenses',
      'Hindi': 'खर्च',
      'Bengali': 'খরচ',
      'Tamil': 'செலவுகள்',
    },
    'Savings Goals': {
      'English': 'Savings Goals',
      'Hindi': 'बचत लक्ष्य',
      'Bengali': 'সঞ্চয়ের লক্ষ্য',
      'Tamil': 'சேமிப்பு இலக்குகள்',
    },
    'Recent Transactions': {
      'English': 'Recent Transactions',
      'Hindi': 'हाल के लेन-देन',
      'Bengali': 'সাম্প্রতিক লেনদেন',
      'Tamil': 'சமீபத்திய பரிவர்த்தனைகள்',
    },
  };

  // Helper function to translate text based on current language
  String translate(String text) {
    if (_currentLanguage == 'English') return text; // Default
    
    // Look up the word in our offline dictionary
    if (_dictionary.containsKey(text)) {
      return _dictionary[text]![_currentLanguage] ?? text; // Fallback to English if translation is missing
    }
    
    return text; // Fallback if key doesn't exist
  }
}