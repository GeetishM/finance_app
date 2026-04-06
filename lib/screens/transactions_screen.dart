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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  children: [
                    // Glassmorphic Search Bar
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: provider.searchTransactions,
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.cancel_rounded, color: Colors.grey[400]),
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
                    // Premium Filter Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showFilters = !_showFilters),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: _showFilters ? AppConstants.primaryColor : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _showFilters ? AppConstants.primaryColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.tune_rounded, color: _showFilters ? Colors.white : Colors.grey[500], size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Filters',
                                    style: TextStyle(
                                      color: _showFilters ? Colors.white : Colors.grey[600],
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (provider.selectedType != null || provider.selectedCategory != null || provider.startDate != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.errorColor.withOpacity(0.1),
                              foregroundColor: AppConstants.errorColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: provider.clearFilters,
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
                        title: 'No Transactions',
                        message: provider.searchQuery.isNotEmpty ? 'No matches found.' : 'Your financial journey begins here.',
                        icon: Icons.receipt_long_rounded,
                        actionLabel: 'Add First Entry',
                        onAction: () => _navigateToAddTransaction(context),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = provider.transactions[index];
                          return AnimatedTransactionListItem(
                            title: getCategoryLabel(transaction.category),
                            amount: '${transaction.type == TransactionType.income ? '+' : '-'} ${NumberUtils.formatCurrency(transaction.amount)}',
                            date: DateUtils.formatDateTimeCompact(transaction.date),
                            categoryColor: getCategoryColor(transaction.category),
                            categoryIcon: getCategoryIcon(transaction.category),
                            onTap: () => _navigateToEditTransaction(context, transaction),
                            onDelete: () => _deleteTransaction(context, transaction.id),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: Colors.grey[500])),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(label: 'All', selected: provider.selectedType == null, onSelected: () => provider.filterByType(null)),
                const SizedBox(width: 8),
                _buildFilterChip(label: 'Income', selected: provider.selectedType == TransactionType.income, onSelected: () => provider.filterByType(TransactionType.income), color: AppConstants.successColor),
                const SizedBox(width: 8),
                _buildFilterChip(label: 'Expense', selected: provider.selectedType == TransactionType.expense, onSelected: () => provider.filterByType(TransactionType.expense), color: AppConstants.errorColor),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Category', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: Colors.grey[500])),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(label: 'All', selected: provider.selectedCategory == null, onSelected: () => provider.filterByCategory(null)),
                ...TransactionCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildFilterChip(
                      label: getCategoryLabel(category),
                      selected: provider.selectedCategory == category,
                      onSelected: () => provider.filterByCategory(category),
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

  Widget _buildFilterChip({required String label, required bool selected, required VoidCallback onSelected, Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = color ?? AppConstants.primaryColor;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? activeColor : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? activeColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
  }

  void _navigateToEditTransaction(BuildContext context, Transaction transaction) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen(transaction: transaction)));
  }

  void _deleteTransaction(BuildContext context, String id) {
    context.read<TransactionProvider>().deleteTransaction(id);
  }
}