// ignore_for_file: deprecated_member_use

import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/providers/goal_provider.dart';
import 'package:finance_app/providers/theme_provider.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/screens/transactions_screen.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/screens/goals_screen.dart'; 
import 'package:finance_app/utils/animations.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
import 'package:finance_app/widgets/common_widgets.dart';
import 'package:finance_app/widgets/animated_transaction_item.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Finance Companion',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              context.read<ThemeProvider>().isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Consumer2<TransactionProvider, GoalProvider>(
          builder: (context, transactionProvider, goalProvider, _) {
            final income = transactionProvider.totalIncome;
            final expenses = transactionProvider.totalExpenses;
            final balance = transactionProvider.balance;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaleFadeAnimation(
                    duration: const Duration(milliseconds: 600),
                    child: _buildBalanceCard(context, balance),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: StaggerAnimation(
                          index: 0,
                          delay: const Duration(milliseconds: 100),
                          child: SummaryCard(
                            label: 'Income',
                            amount: NumberUtils.formatCurrency(income),
                            color: AppConstants.successColor,
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StaggerAnimation(
                          index: 1,
                          delay: const Duration(milliseconds: 150),
                          child: SummaryCard(
                            label: 'Expenses',
                            amount: NumberUtils.formatCurrency(expenses),
                            color: AppConstants.errorColor,
                            icon: Icons.trending_down_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (transactionProvider.expensesByCategory.isNotEmpty)
                    SlideInAnimation(
                      beginOffset: const Offset(0, 0.5),
                      child: _buildCategoryChart(context, transactionProvider),
                    ),
                  const SizedBox(height: 24),

                  if (goalProvider.activeGoals.isNotEmpty)
                    SlideInAnimation(
                      beginOffset: const Offset(0, 0.3),
                      child: _buildGoalsSection(context, goalProvider),
                    ),
                  const SizedBox(height: 24),

                  _buildRecentTransactions(context, transactionProvider),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: balance),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                  ),
                  Icon(Icons.account_balance_wallet, color: Colors.white.withOpacity(0.8)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                NumberUtils.formatCurrency(value),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Updated ${DateUtils.formatDateTimeCompact(DateTime.now())}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final expensesByCategory = provider.expensesByCategory;

    if (expensesByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedEntries.take(5).toList();
    final totalExpenses =
        topCategories.fold(0.0, (sum, entry) => sum + entry.value);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: topCategories
                    .map((entry) {
                      final percentage = entry.value / totalExpenses;
                      return PieChartSectionData(
                        value: percentage,
                        title: '${(percentage * 100).toStringAsFixed(0)}%',
                        color: getCategoryColor(entry.key),
                        radius: 60,
                        titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      );
                    })
                    .toList(),
                sectionsSpace: 2, 
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: topCategories
                .asMap()
                .entries
                .map((entry) => StaggerAnimation(
                      index: entry.key,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: getCategoryColor(entry.value.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                getCategoryLabel(entry.value.key),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            Text(
                              NumberUtils.formatCurrency(entry.value.value),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, GoalProvider provider) {
    final primaryGoal = provider.primaryGoal;

    if (primaryGoal == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onTrack = primaryGoal.isOnTrack;
    final primaryColor = onTrack ? AppConstants.successColor : AppConstants.warningColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Savings Goals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        BounceAnimation(
          child: GestureDetector(
            // 🛠️ FIX: Navigate to the full Goals Screen instead of Edit Goal
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoalsScreen(), 
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24), // 🛠️ FIX: Matched the 24px padding of the pie chart
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primaryGoal.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                onTrack ? 'On Track' : 'Needs Attention',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // ignore: duplicate_ignore
                          // ignore: deprecated_member_use
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppConstants.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: primaryGoal.progressPercentage.clamp(0.0, 1.0),
                            minHeight: 12,
                            backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(primaryGoal.progressPercentage * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberUtils.formatCurrency(primaryGoal.currentAmount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                      ),
                      Text(
                        NumberUtils.formatCurrency(primaryGoal.targetAmount),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final recentTransactions = provider.allTransactions.take(5).toList();

    if (recentTransactions.isEmpty) {
      return EmptyState(
        title: 'No Transactions',
        message: 'Start by adding your first transaction',
        icon: Icons.receipt_long_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
              child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: recentTransactions
              .asMap()
              .entries
              .map((entry) => StaggerAnimation(
                    index: entry.key,
                    delay: const Duration(milliseconds: 50),
                    child: AnimatedTransactionListItem(
                      title: getCategoryLabel(entry.value.category),
                      amount:
                          '${entry.value.type == TransactionType.income ? '+' : '-'} ${NumberUtils.formatCurrency(entry.value.amount)}',
                      date: DateUtils.formatDateTimeCompact(entry.value.date),
                      categoryColor: getCategoryColor(entry.value.category),
                      categoryIcon: getCategoryIcon(entry.value.category),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(transaction: entry.value),
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(transaction: entry.value),
                          ),
                        );
                      },
                      onDelete: () {
                        provider.deleteTransaction(entry.value.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Transaction deleted',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: const Color(0xFF334155),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 4),
                            action: SnackBarAction(
                              label: 'UNDO',
                              textColor: AppConstants.primaryColor,
                              onPressed: () {
                                provider.addTransaction(entry.value);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}