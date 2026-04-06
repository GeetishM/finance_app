import 'package:finance_app/models/goal.dart';
import 'package:finance_app/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  static const String transactionsBox = 'transactions';
  static const String goalsBox = 'goals';
  static const String settingsBox = 'settings';

  static const String reminderHourKey = 'reminderHour';
  static const String reminderMinuteKey = 'reminderMinute';

  static const String themeKey = 'isDarkMode'; // 🛠️ ADDED: Key for our theme setting
  static const String languageKey = 'appLanguage'; // 🛠️ ADDED: Key for language setting

  static Future<void> saveReminderTime(int hour, int minute) async {
    final box = Hive.box(settingsBox);
    await box.put(reminderHourKey, hour);
    await box.put(reminderMinuteKey, minute);
  }

  static Map<String, int> getReminderTime() {
    final box = Hive.box(settingsBox);
    return {
      'hour': box.get(reminderHourKey, defaultValue: 20), // 8 PM default
      'minute': box.get(reminderMinuteKey, defaultValue: 0),
    };
  }

  static Future<void> initializeDatabase() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SavingsGoalAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TransactionCategoryAdapter());
    }

    // Open boxes
    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<SavingsGoal>(goalsBox);
    await Hive.openBox(settingsBox); // Settings box is ready to use!
  }

  // --- Theme Settings Operations 🛠️ ADDED THIS SECTION ---
  static Future<void> saveTheme(bool isDark) async {
    final box = Hive.box(settingsBox);
    await box.put(themeKey, isDark);
  }

  static bool? getTheme() {
    final box = Hive.box(settingsBox);
    return box.get(
      themeKey,
    ); // Returns null if the user hasn't opened the app before
  }

  // --- Language Settings Operations 🛠️ ADDED ---
  static Future<void> saveLanguage(String language) async {
    final box = Hive.box(settingsBox);
    await box.put(languageKey, language);
  }

  static String? getLanguage() {
    final box = Hive.box(settingsBox);
    return box.get(languageKey); 
  }
  // ------------------------------------------------------

  // Transaction Operations
  static Future<void> addTransaction(Transaction transaction) async {
    final box = Hive.box<Transaction>(transactionsBox);
    await box.put(transaction.id, transaction);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final box = Hive.box<Transaction>(transactionsBox);
    await box.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    final box = Hive.box<Transaction>(transactionsBox);
    await box.delete(id);
  }

  static List<Transaction> getAllTransactions() {
    final box = Hive.box<Transaction>(transactionsBox);
    final transactions = box.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  static List<Transaction> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final transactions = getAllTransactions();
    return transactions.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      final sDate = DateTime(start.year, start.month, start.day);
      final eDate = DateTime(end.year, end.month, end.day);
      return (tDate.isAtSameMomentAs(sDate) || tDate.isAfter(sDate)) &&
          (tDate.isAtSameMomentAs(eDate) || tDate.isBefore(eDate));
    }).toList();
  }

  // Goal Operations
  static Future<void> addGoal(SavingsGoal goal) async {
    final box = Hive.box<SavingsGoal>(goalsBox);
    await box.put(goal.id, goal);
  }

  static Future<void> updateGoal(SavingsGoal goal) async {
    final box = Hive.box<SavingsGoal>(goalsBox);
    await box.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    final box = Hive.box<SavingsGoal>(goalsBox);
    await box.delete(id);
  }

  static List<SavingsGoal> getAllGoals() {
    final box = Hive.box<SavingsGoal>(goalsBox);
    return box.values.toList();
  }

  // Helper Methods
  static double getTotalIncome([DateTime? fromDate, DateTime? toDate]) {
    final transactions = fromDate != null && toDate != null
        ? getTransactionsByDateRange(fromDate, toDate)
        : getAllTransactions();

    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getTotalExpenses([DateTime? fromDate, DateTime? toDate]) {
    final transactions = fromDate != null && toDate != null
        ? getTransactionsByDateRange(fromDate, toDate)
        : getAllTransactions();

    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getCurrentBalance() {
    final allTransactions = getAllTransactions();
    double balance = 0;

    for (var transaction in allTransactions) {
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }

    return balance;
  }

  static Map<TransactionCategory, double> getExpensesByCategory([
    DateTime? fromDate,
    DateTime? toDate,
  ]) {
    final transactions = fromDate != null && toDate != null
        ? getTransactionsByDateRange(fromDate, toDate)
        : getAllTransactions();

    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final categoryMap = <TransactionCategory, double>{};

    for (var expense in expenses) {
      final current = categoryMap[expense.category] ?? 0;
      categoryMap[expense.category] = current + expense.amount;
    }

    return categoryMap;
  }
}
