import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/utils/animations.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
import 'package:finance_app/widgets/animated_fab.dart';
import 'package:finance_app/widgets/common_widgets.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedPeriod = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insights',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.allTransactions.isEmpty) {
            return EmptyState(
              title: 'No Data Yet',
              message: 'Add transactions to generate beautiful insights',
              icon: Icons.analytics_rounded,
              actionLabel: 'Add First Entry',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              // 🛠️ UI FIX: 20px horizontal padding to perfectly match the Home Screen margins
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  _buildPeriodSelector(),
                  const SizedBox(height: 32),

                  // Summary Cards
                  SlideInAnimation(
                    beginOffset: const Offset(0, 0.2),
                    child: _buildSummarySection(context, provider),
                  ),
                  const SizedBox(height: 24),

                  // Trend Chart
                  SlideInAnimation(
                    beginOffset: const Offset(0, 0.4),
                    child: _buildTrendChart(context, provider),
                  ),
                  const SizedBox(height: 24),

                  // Top Spending Categories
                  SlideInAnimation(
                    beginOffset: const Offset(0, 0.6),
                    child: _buildTopSpendingCategories(context, provider),
                  ),
                  const SizedBox(height: 24),

                  // Category Breakdown
                  SlideInAnimation(
                    beginOffset: const Offset(0, 0.8),
                    child: _buildCategoryBreakdown(context, provider),
                  ),
                  const SizedBox(height: 100), // Padding for the FAB
                ],
              ),
            ),
          );
        },
      ),
      // 🛠️ ADDED: Animated FAB for quick adding from the Insights page
      floatingActionButton: AnimatedFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        icon: Icons.add,
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: ['Weekly', 'Monthly', 'Yearly'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF334155) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : Colors.grey[500],
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final weekTransactions = provider.getWeeklyTransactions();
    final monthTransactions = provider.getMonthlyTransactions();

    final transactions = _selectedPeriod == 'Weekly'
        ? weekTransactions
        : _selectedPeriod == 'Monthly'
        ? monthTransactions
        : provider.allTransactions;

    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final savings = income - expenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_selectedPeriod Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: 'Income',
                amount: NumberUtils.formatCurrency(income),
                color: AppConstants.successColor,
                icon: Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                label: 'Expenses',
                amount: NumberUtils.formatCurrency(expenses),
                color: AppConstants.errorColor,
                icon: Icons.trending_down_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SummaryCard(
          label: 'Net Savings',
          amount: NumberUtils.formatCurrency(savings),
          color: savings >= 0
              ? AppConstants.primaryColor
              : AppConstants.errorColor,
          icon: savings >= 0
              ? Icons.account_balance_wallet_rounded
              : Icons.money_off_rounded,
        ),
      ],
    );
  }

  Widget _buildTrendChart(BuildContext context, TransactionProvider provider) {
    final weekTransactions = provider.getWeeklyTransactions();
    final monthTransactions = provider.getMonthlyTransactions();

    final transactions = _selectedPeriod == 'Weekly'
        ? weekTransactions
        : _selectedPeriod == 'Monthly'
        ? monthTransactions
        : provider.allTransactions;

    // Group by date
    final dateMap = <String, double>{};
    for (var transaction in transactions) {
      final dateStr = DateUtils.formatShortDate(transaction.date);
      final value = dateMap[dateStr] ?? 0;
      if (transaction.type == TransactionType.expense) {
        dateMap[dateStr] = value + transaction.amount;
      }
    }

    final sortedDates = dateMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (sortedDates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            'No expense data for this period',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24), // Premium padding
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark)
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
            'Daily Expense Trend',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220, // Slightly taller for a more impressive chart
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  sortedDates.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: sortedDates[index].value,
                        color: AppConstants.primaryColor,
                        width: 14, // 🛠️ Made the bars much thicker
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // 🛠️ Fully rounded "bubble" tips
                      ),
                    ],
                  ),
                ),
                borderData: FlBorderData(show: false),
                // 🛠️ Turned on horizontal grid lines so users can read the chart!
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateInterval(sortedDates),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[200],
                      strokeWidth: 1.5,
                      dashArray: [
                        4,
                        4,
                      ], // Adds a nice dashed effect to the grid
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedDates.length) {
                          // Display just the day number (e.g. "12" instead of "Apr 12") for a cleaner X-axis
                          String dayStr = sortedDates[index].key
                              .split(' ')
                              .last;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dayStr,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to keep grid lines manageable
  double _calculateInterval(List<MapEntry<String, double>> data) {
    if (data.isEmpty) return 100;
    double max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (max == 0) return 100;
    return (max / 4).ceilToDouble(); // 4 horizontal grid lines
  }

  Widget _buildTopSpendingCategories(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final weekTransactions = provider.getWeeklyTransactions();
    final monthTransactions = provider.getMonthlyTransactions();

    final transactions = _selectedPeriod == 'Weekly'
        ? weekTransactions
        : _selectedPeriod == 'Monthly'
        ? monthTransactions
        : provider.allTransactions;

    final categoryMap = <TransactionCategory, double>{};
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final current = categoryMap[transaction.category] ?? 0;
        categoryMap[transaction.category] = current + transaction.amount;
      }
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    final topCategories = sortedCategories.take(3).toList();
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
          if (!isDark)
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
            'Top Spending Categories',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          Column(
            children: topCategories.map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final totalExpenses = sortedCategories.fold(
                0.0,
                (sum, e) => sum + e.value,
              );
              final percentage = amount / totalExpenses;

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: getCategoryColor(
                                  category,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                getCategoryIcon(category),
                                color: getCategoryColor(category),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              getCategoryLabel(category),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: getCategoryColor(category),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8, // 🛠️ UX FIX: Thicker progress bars
                        backgroundColor: isDark
                            ? const Color(0xFF334155)
                            : Colors.grey[100],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          getCategoryColor(category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberUtils.formatCurrency(amount),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final weekTransactions = provider.getWeeklyTransactions();
    final monthTransactions = provider.getMonthlyTransactions();

    final transactions = _selectedPeriod == 'Weekly'
        ? weekTransactions
        : _selectedPeriod == 'Monthly'
        ? monthTransactions
        : provider.allTransactions;

    final categoryMap = <TransactionCategory, double>{};
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final current = categoryMap[transaction.category] ?? 0;
        categoryMap[transaction.category] = current + transaction.amount;
      }
    }

    if (categoryMap.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          if (!isDark)
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
            'All Categories',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Column(
            children: sortedCategories.map((entry) {
              final category = entry.key;
              final amount = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: getCategoryColor(category).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            getCategoryIcon(category),
                            color: getCategoryColor(category),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          getCategoryLabel(category),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      NumberUtils.formatCurrency(amount),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
