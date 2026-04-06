import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
import 'package:finance_app/widgets/animated_fab.dart';
import 'package:finance_app/widgets/animated_transaction_item.dart';
import 'package:finance_app/widgets/common_widgets.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late TextEditingController _searchController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionCategory> _getRelevantCategories(TransactionType? type) {
    if (type == TransactionType.income) {
      return [
        TransactionCategory.salary,
        TransactionCategory.freelance,
        TransactionCategory.bonus,
        TransactionCategory.other,
      ];
    } else if (type == TransactionType.expense) {
      return TransactionCategory.values
          .where(
            (c) =>
                c != TransactionCategory.salary &&
                c != TransactionCategory.freelance &&
                c != TransactionCategory.bonus,
          )
          .toList();
    }
    return TransactionCategory.values;
  }

  void _handleFilterChange(
    TransactionProvider provider,
    VoidCallback filterAction,
  ) {
    filterAction();

    if (provider.transactions.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();

      String message = 'No transactions found';
      if (provider.selectedType == TransactionType.income) {
        message = 'No income found';
      } else if (provider.selectedType == TransactionType.expense) {
        message = 'No expense found';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          String emptyMessage = 'Your financial journey begins here.';
          if (provider.isFilterActive) {
            if (provider.selectedType == TransactionType.income) {
              emptyMessage = 'No income matches your current filters.';
            } else if (provider.selectedType == TransactionType.expense) {
              emptyMessage = 'No expense matches your current filters.';
            } else {
              emptyMessage = 'No transactions match your current filters.';
            }
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _handleFilterChange(
                          provider,
                          () => provider.searchTransactions(value),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.cancel_rounded,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.searchTransactions('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _showFilters = !_showFilters),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: _showFilters
                                    ? AppConstants.primaryColor
                                    : (isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _showFilters
                                      ? AppConstants.primaryColor
                                      : (isDark
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.grey[200]!),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    color: _showFilters
                                        ? Colors.white
                                        : Colors.grey[500],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Filters',
                                    style: TextStyle(
                                      color: _showFilters
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (provider.isFilterActive)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.errorColor
                                  .withOpacity(0.1),
                              foregroundColor: AppConstants.errorColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearFilters();
                            },
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_showFilters) _buildFilters(context, provider),
              Expanded(
                child: provider.transactions.isEmpty
                    ? EmptyState(
                        title: provider.selectedType == TransactionType.income
                            ? 'No Income'
                            : (provider.selectedType == TransactionType.expense
                                  ? 'No Expenses'
                                  : 'No Transactions'),
                        message: emptyMessage,
                        icon: Icons.receipt_long_rounded,
                        actionLabel: provider.isFilterActive
                            ? 'Clear Filters'
                            : 'Add First Entry',
                        onAction: provider.isFilterActive
                            ? () {
                                _searchController.clear();
                                provider.clearFilters();
                              }
                            : () => _navigateToAddTransaction(context),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = provider.transactions[index];
                          return AnimatedTransactionListItem(
                            title: getCategoryLabel(transaction.category),
                            amount:
                                '${transaction.type == TransactionType.income ? '+' : '-'} ${NumberUtils.formatCurrency(transaction.amount)}',
                            date: DateUtils.formatDateTimeCompact(
                              transaction.date,
                            ),
                            categoryColor: getCategoryColor(
                              transaction.category,
                            ),
                            categoryIcon: getCategoryIcon(transaction.category),
                            onTap: () => _navigateToEditTransaction(
                              context,
                              transaction,
                            ),
                            // 🛠️ ADDED: Now swiping right triggers the edit screen
                            onEdit: () => _navigateToEditTransaction(
                              context,
                              transaction,
                            ),
                            onDelete: () =>
                                _deleteTransaction(context, transaction),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: () => _navigateToAddTransaction(context),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, TransactionProvider provider) {
    final relevantCategories = _getRelevantCategories(provider.selectedType);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: provider.selectedType == null,
                  onSelected: () => _handleFilterChange(
                    provider,
                    () => provider.filterByType(null),
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Income',
                  selected: provider.selectedType == TransactionType.income,
                  onSelected: () => _handleFilterChange(
                    provider,
                    () => provider.filterByType(TransactionType.income),
                  ),
                  color: AppConstants.successColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Expense',
                  selected: provider.selectedType == TransactionType.expense,
                  onSelected: () => _handleFilterChange(
                    provider,
                    () => provider.filterByType(TransactionType.expense),
                  ),
                  color: AppConstants.errorColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: provider.selectedCategory == null,
                  onSelected: () => _handleFilterChange(
                    provider,
                    () => provider.filterByCategory(null),
                  ),
                ),
                ...relevantCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildFilterChip(
                      label: getCategoryLabel(category),
                      selected: provider.selectedCategory == category,
                      onSelected: () => _handleFilterChange(
                        provider,
                        () => provider.filterByCategory(category),
                      ),
                      color: getCategoryColor(category),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = color ?? AppConstants.primaryColor;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? activeColor
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? activeColor
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );
  }

  void _navigateToEditTransaction(
    BuildContext context,
    Transaction transaction,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _deleteTransaction(BuildContext context, Transaction transaction) {
    final provider = context.read<TransactionProvider>();

    provider.deleteTransaction(transaction.id);

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
            provider.addTransaction(transaction);
          },
        ),
      ),
    );
  }
}
