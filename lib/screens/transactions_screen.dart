import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        provider.searchTransactions(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.searchTransactions('');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showFilters = !_showFilters;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _showFilters
                                    ? AppConstants.primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.tune,
                                    color: _showFilters
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Filters',
                                    style: TextStyle(
                                      color:
                                          _showFilters
                                              ? Colors.white
                                              : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (provider.selectedType != null ||
                            provider.selectedCategory != null ||
                            provider.startDate != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              provider.clearFilters();
                            },
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Filters
              if (_showFilters) _buildFilters(context, provider),
              // Transactions List
              Expanded(
                child: provider.transactions.isEmpty
                    ? EmptyState(
                        title: 'No Transactions',
                        message: provider.searchQuery.isNotEmpty
                            ? 'No transactions match your search'
                            : 'Start by adding your first transaction',
                        icon: Icons.receipt_long,
                        actionLabel: 'Add Transaction',
                        onAction: () => _navigateToAddTransaction(context),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = provider.transactions[index];
                          return TransactionListItem(
                            title:
                                getCategoryLabel(transaction.category),
                            amount:
                                '${transaction.type == TransactionType.income ? '+' : '-'} ${NumberUtils.formatCurrency(transaction.amount)}',
                            date: DateUtils
                                .formatDateTimeCompact(transaction.date),
                            categoryColor:
                                getCategoryColor(transaction.category),
                            categoryIcon:
                                getCategoryIcon(transaction.category),
                            onTap: () => _navigateToEditTransaction(
                              context,
                              transaction,
                            ),
                            onDelete: () =>
                                _deleteTransaction(context, transaction.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Filter
          Text(
            'Transaction Type',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'All',
                selected: provider.selectedType == null,
                onSelected: () => provider.filterByType(null),
              ),
              _buildFilterChip(
                label: 'Income',
                selected: provider.selectedType == TransactionType.income,
                onSelected: () =>
                    provider.filterByType(TransactionType.income),
              ),
              _buildFilterChip(
                label: 'Expense',
                selected: provider.selectedType == TransactionType.expense,
                onSelected: () =>
                    provider.filterByType(TransactionType.expense),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category Filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'All',
                selected: provider.selectedCategory == null,
                onSelected: () =>
                    provider.filterByCategory(null),
              ),
              ...TransactionCategory.values.map((category) {
                return _buildFilterChip(
                  label: getCategoryLabel(category),
                  selected: provider.selectedCategory == category,
                  onSelected: () =>
                      provider.filterByCategory(category),
                  color: getCategoryColor(category),
                );
              }).toList(),
            ],
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
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? AppConstants.primaryColor)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? (color ?? AppConstants.primaryColor)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }

  void _navigateToEditTransaction(
    BuildContext context,
    Transaction transaction,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _deleteTransaction(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<TransactionProvider>().deleteTransaction(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}