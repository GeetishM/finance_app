import 'package:finance_app/models/goal.dart';
import 'package:finance_app/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';


class DatabaseService {
  static const String transactionsBox = 'transactions';
  static const String goalsBox = 'goals';
  static const String settingsBox = 'settings';

  static Future<void> initializeDatabase() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SavingsGoalAdapter());
    }
    
    // --- ADD THESE TWO NEW ADAPTERS ---
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TransactionCategoryAdapter());
    }
    // ----------------------------------

    // Open boxes
    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<SavingsGoal>(goalsBox);
    await Hive.openBox(settingsBox);
  }

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
    return box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<Transaction> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final transactions = getAllTransactions();
    return transactions.where((t) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  static List<Transaction> getTransactionsByCategory(
    TransactionCategory category,
  ) {
    final transactions = getAllTransactions();
    return transactions.where((t) => t.category == category).toList();
  }

  static List<Transaction> searchTransactions(String query) {
    final transactions = getAllTransactions();
    return transactions
        .where((t) =>
            t.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
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
    return box.values.toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  static List<SavingsGoal> getActiveGoals() {
    return getAllGoals().where((g) => !g.isCompleted).toList();
  }

  // Analytics
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

  static Map<TransactionCategory, double> getExpensesByCategory(
      [DateTime? fromDate, DateTime? toDate]) {
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

  static void clearAllData() {
    Hive.box<Transaction>(transactionsBox).clear();
    Hive.box<SavingsGoal>(goalsBox).clear();
  }
}