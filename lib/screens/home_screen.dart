import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/providers/goal_provider.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
import 'package:finance_app/widgets/common_widgets.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Finance Companion',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Consumer2<TransactionProvider, GoalProvider>(
          builder: (context, transactionProvider, goalProvider, _) {
            final income = transactionProvider.totalIncome;
            final expenses = transactionProvider.totalExpenses;
            final balance = transactionProvider.balance;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  _buildBalanceCard(context, balance),
                  const SizedBox(height: 24),

                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          label: 'Income',
                          amount: NumberUtils.formatCurrency(income),
                          color: AppConstants.successColor,
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          label: 'Expenses',
                          amount: NumberUtils.formatCurrency(expenses),
                          color: AppConstants.errorColor,
                          icon: Icons.trending_down,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Spending by Category Chart
                  if (transactionProvider.transactions.isNotEmpty)
                    _buildCategoryChart(context, transactionProvider),
                  const SizedBox(height: 24),

                  // Goals Section
                  if (goalProvider.activeGoals.isNotEmpty)
                    _buildGoalsSection(context, goalProvider),
                  const SizedBox(height: 24),

                  // Recent Transactions
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberUtils.formatCurrency(balance),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Last updated: ${DateUtils.formatDateTimeCompact(DateTime.now())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
            ],
          ),
        ],
      ),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: topCategories
                    .map((entry) {
                      final percentage = entry.value / totalExpenses;
                      return PieChartSectionData(
                        value: percentage,
                        title:
                            '${(percentage * 100).toStringAsFixed(0)}%',
                        color:
                            getCategoryColor(entry.key),
                        radius: 80,
                        titleStyle:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      );
                    })
                    .toList(),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: topCategories
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: getCategoryColor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              getCategoryLabel(entry.key),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            NumberUtils.formatCurrency(entry.value),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Savings Goals',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GoalProgressCard(
          goalTitle: primaryGoal.title,
          progressPercentage: primaryGoal.progressPercentage,
          currentAmount: NumberUtils.formatCurrency(primaryGoal.currentAmount),
          targetAmount: NumberUtils.formatCurrency(primaryGoal.targetAmount),
          primaryColor: AppConstants.primaryColor,
          onTap: () {
            // Navigate to goals screen
          },
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
        icon: Icons.receipt_long,
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to transactions screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: recentTransactions
              .map((transaction) => TransactionListItem(
                    title: getCategoryLabel(transaction.category),
                    amount: '${transaction.type == TransactionType.income ? '+' : '-'} ${NumberUtils.formatCurrency(transaction.amount)}',
                    date: DateUtils.formatDateTime(transaction.date),
                    categoryColor: getCategoryColor(transaction.category),
                    categoryIcon: getCategoryIcon(transaction.category),
                  ))
              .toList(),
        ),
      ],
    );
  }
}