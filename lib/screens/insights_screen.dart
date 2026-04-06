import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.allTransactions.isEmpty) {
            return EmptyState(
              title: 'No Data Yet',
              message: 'Add transactions to see insights',
              icon: Icons.analytics,
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),

                  // Summary Cards
                  _buildSummarySection(context, provider),
                  const SizedBox(height: 24),

                  // Trend Chart
                  _buildTrendChart(context, provider),
                  const SizedBox(height: 24),

                  // Top Spending Categories
                  _buildTopSpendingCategories(context, provider),
                  const SizedBox(height: 24),

                  // Category Breakdown
                  _buildCategoryBreakdown(context, provider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: ['Weekly', 'Monthly', 'Yearly']
          .map(
            (period) => Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedPeriod == period
                        ? AppConstants.primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          _selectedPeriod == period
                              ? Colors.white
                              : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList()
          .expand((widget) => [widget, const SizedBox(width: 8)])
          .toList()
          .sublist(0, 5),
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
          '${_selectedPeriod} Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        SummaryCard(
          label: 'Savings',
          amount: NumberUtils.formatCurrency(savings),
          color: savings >= 0
              ? AppConstants.successColor
              : AppConstants.errorColor,
          icon: Icons.favorite,
        ),
      ],
    );
  }

  Widget _buildTrendChart(
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

    if (sortedDates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final maxExpense = sortedDates.isNotEmpty
        ? sortedDates.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Expense Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
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
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < sortedDates.length) {
                          return Text(
                            sortedDates[index].key,
                            style:
                                Theme.of(context).textTheme.labelSmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Spending Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Column(
            children: topCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value.key;
              final amount = entry.value.value;
              final totalExpenses = sortedCategories.fold(
                0.0,
                (sum, entry) => sum + entry.value,
              );
              final percentage = amount / totalExpenses;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: getCategoryColor(category),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              getCategoryLabel(category),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          getCategoryColor(category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberUtils.formatCurrency(amount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Column(
            children: categoryMap.entries.map((entry) {
              final category = entry.key;
              final amount = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                getCategoryColor(category).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
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
                          style:
                              Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Text(
                      NumberUtils.formatCurrency(amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: getCategoryColor(category),
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