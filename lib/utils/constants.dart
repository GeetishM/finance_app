import 'package:finance_app/models/transaction.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // Category Icons (Kept identical so logic doesn't break)
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

  // Upgraded Category Colors (Softer, modern tones)
  static Map<TransactionCategory, Color> categoryColors = {
    TransactionCategory.food: const Color(0xFFFF6B6B), // Soft Red
    TransactionCategory.transport: const Color(0xFF4D96FF), // Bright Blue
    TransactionCategory.entertainment: const Color(0xFF9D4EDD), // Royal Purple
    TransactionCategory.utilities: const Color(0xFFF4A261), // Soft Orange
    TransactionCategory.shopping: const Color(0xFFFF99C8), // Soft Pink
    TransactionCategory.health: const Color(0xFF06D6A0), // Mint Green
    TransactionCategory.education: const Color(0xFF118AB2), // Ocean Blue
    TransactionCategory.salary: const Color(0xFF00B4D8), // Cyan
    TransactionCategory.freelance: const Color(0xFF6366F1), // Indigo
    TransactionCategory.bonus: const Color(0xFFFFD166), // Warm Yellow
    TransactionCategory.other: const Color(0xFF9CA3AF), // Cool Gray
  };

  // Category Labels
  static Map<TransactionCategory, String> categoryLabels = {
    // ... Keep your existing category labels here ...
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

  // App Colors
  static const Color primaryColor = Color(0xFF4F46E5); 
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  // Fancier Gradients (Added a slight angle for a modern look)
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(0.5),
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(0.5),
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(0.8), // Gives it a credit-card sheen
  );
}

// ... Keep your existing helper functions (getCategoryLabel, etc.) ...
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