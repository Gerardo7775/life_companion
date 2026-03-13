abstract class AppConstants {
  // App info
  static const String appName = 'Life Companion';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'life_companion.db';
  static const int dbVersion = 4;



  // Shared Preferences Keys
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefOnboardingDone = 'pref_onboarding_done';

  // XP & Coins rewards
  static const int xpForCompletedTask = 20;
  static const int xpForCompletedHabit = 50;
  static const int xpForBudgetRespected = 30;
  static const int coinsForCompletedTask = 5;
  static const int coinsForCompletedHabit = 15;
  static const int coinsForBudgetRespected = 10;

  // Levels thresholds (XP needed to reach each level)
  static const List<int> levelThresholds = [
    0, 100, 250, 500, 900, 1500, 2200, 3100, 4200, 5500, 7000
  ];

  // Default currency
  static const String defaultCurrency = 'MXN';
  static const String defaultCurrencySymbol = '\$';
}
