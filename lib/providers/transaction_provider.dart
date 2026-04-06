import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/services/database_service.dart';
import 'package:flutter/foundation.dart';


class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  String _searchQuery = '';
  TransactionType? _selectedType;
  TransactionCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<Transaction> get transactions => _filteredTransactions.isEmpty
      ? _transactions
      : _filteredTransactions;

  List<Transaction> get allTransactions => _transactions;

  String get searchQuery => _searchQuery;
  TransactionType? get selectedType => _selectedType;
  TransactionCategory? get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  double get totalIncome =>
      _transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses =>
      _transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  Map<TransactionCategory, double> get expensesByCategory {
    final expenses = _transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final categoryMap = <TransactionCategory, double>{};
    for (var expense in expenses) {
      final current = categoryMap[expense.category] ?? 0;
      categoryMap[expense.category] = current + expense.amount;
    }

    return categoryMap;
  }

  TransactionProvider() {
    loadTransactions();
  }

  void loadTransactions() {
    _transactions = DatabaseService.getAllTransactions();
    applyFilters();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseService.addTransaction(transaction);
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    applyFilters();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseService.updateTransaction(transaction);
    final index =
        _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }
    applyFilters();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseService.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    applyFilters();
    notifyListeners();
  }

  void searchTransactions(String query) {
    _searchQuery = query;
    applyFilters();
    notifyListeners();
  }

  void filterByType(TransactionType? type) {
    _selectedType = type;
    applyFilters();
    notifyListeners();
  }

  void filterByCategory(TransactionCategory? category) {
    _selectedCategory = category;
    applyFilters();
    notifyListeners();
  }

  void filterByDateRange(DateTime startDate, DateTime endDate) {
    _startDate = startDate;
    _endDate = endDate;
    applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedCategory = null;
    _startDate = null;
    _endDate = null;
    applyFilters();
    notifyListeners();
  }

  void applyFilters() {
    _filteredTransactions = _transactions.where((transaction) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = transaction.description
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;
        if (!matchesSearch) return false;
      }

      // Type filter
      if (_selectedType != null && transaction.type != _selectedType) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null &&
          transaction.category != _selectedCategory) {
        return false;
      }

      // Date range filter
      if (_startDate != null && _endDate != null) {
        final transactionDate =
            DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
        final start =
            DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final end =
            DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

        if (transactionDate.isBefore(start) || transactionDate.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<Transaction> getWeeklyTransactions() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));

    return _transactions
        .where((t) =>
            !t.date.isBefore(weekAgo) && !t.date.isAfter(now))
        .toList();
  }

  List<Transaction> getMonthlyTransactions() {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    return _transactions
        .where((t) =>
            !t.date.isBefore(monthAgo) && !t.date.isAfter(now))
        .toList();
  }
}