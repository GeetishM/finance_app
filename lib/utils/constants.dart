import 'package:finance_app/models/transaction.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // Category Icons
  static Map<TransactionCategory, IconData> categoryIcons = {
    TransactionCategory.food: Icons.restaurant,
    TransactionCategory.transport: Icons.directions_car,
    TransactionCategory.entertainment: Icons.movie,
    TransactionCategory.utilities: Icons.lightbulb,
    TransactionCategory.shopping: Icons.shopping_bag,
    TransactionCategory.health: Icons.favorite,
    TransactionCategory.education: Icons.school,
    TransactionCategory.salary: Icons.account_balance_wallet,
    TransactionCategory.freelance: Icons.code,
    TransactionCategory.bonus: Icons.card_giftcard,
    TransactionCategory.other: Icons.more_horiz,
  };

  // Category Colors
  static Map<TransactionCategory, Color> categoryColors = {
    TransactionCategory.food: const Color(0xFFEF4444),
    TransactionCategory.transport: const Color(0xFFF97316),
    TransactionCategory.entertainment: const Color(0xFF8B5CF6),
    TransactionCategory.utilities: const Color(0xFFEAB308),
    TransactionCategory.shopping: const Color(0xFFEC4899),
    TransactionCategory.health: const Color(0xFF06B6D4),
    TransactionCategory.education: const Color(0xFF3B82F6),
    TransactionCategory.salary: const Color(0xFF10B981),
    TransactionCategory.freelance: const Color(0xFF6366F1),
    TransactionCategory.bonus: const Color(0xFFF59E0B),
    TransactionCategory.other: const Color(0xFF6B7280),
  };

  static Map<TransactionCategory, String> categoryLabels = {
    TransactionCategory.food: 'Food',
    TransactionCategory.transport: 'Transport',
    TransactionCategory.entertainment: 'Entertainment',
    TransactionCategory.utilities: 'Utilities',
    TransactionCategory.shopping: 'Shopping',
    TransactionCategory.health: 'Health',
    TransactionCategory.education: 'Education',
    TransactionCategory.salary: 'Salary',
    TransactionCategory.freelance: 'Freelance',
    TransactionCategory.bonus: 'Bonus',
    TransactionCategory.other: 'Other',
  };

  static Map<TransactionType, String> typeLabels = {
    TransactionType.income: 'Income',
    TransactionType.expense: 'Expense',
  };

  // 🛠️ THEME FIX: Upgraded to a Premium Purple
  static const Color primaryColor = Color(0xFF7C3AED); // Vivid Violet
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  static const Color lightBg = Color(0xFFF8F7FF);
  static const Color darkBg = Color(0xFF0F172A);

  // Gradient colors
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🛠️ THEME FIX: A beautiful Violet to Deep Purple gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

String getCategoryLabel(TransactionCategory category) {
  return AppConstants.categoryLabels[category] ?? 'Other';
}

Color getCategoryColor(TransactionCategory category) {
  return AppConstants.categoryColors[category] ?? Colors.grey;
}

IconData getCategoryIcon(TransactionCategory category) {
  return AppConstants.categoryIcons[category] ?? Icons.circle;
}

String getTypeLabel(TransactionType type) {
  return AppConstants.typeLabels[type] ?? 'Other';
}
