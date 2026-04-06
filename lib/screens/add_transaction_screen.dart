import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TransactionType _transactionType;
  late TransactionCategory _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController = TextEditingController(text: widget.transaction!.amount.toString());
      _descriptionController = TextEditingController(text: widget.transaction!.description);
      _transactionType = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _transactionType = TransactionType.expense;
      _selectedCategory = TransactionCategory.food;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction != null ? 'Edit Transaction' : 'New Entry',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 32),
            
            // Massive Amount Input
            Center(
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _transactionType == TransactionType.income ? AppConstants.successColor : AppConstants.errorColor,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.grey[300]),
                  prefixText: '₹ ',
                  prefixStyle: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.grey[400]),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            _buildSectionTitle(context, 'Category'),
            const SizedBox(height: 16),
            _buildCategoryGrid(),
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'Date'),
            const SizedBox(height: 12),
            _buildDatePicker(),
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'Description (Optional)'),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'What was this for?',
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56, // Taller, more premium button
              child: ElevatedButton(
                onPressed: _saveTransaction,
                child: Text(
                  widget.transaction != null ? 'Update' : 'Save Entry',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: Colors.grey[500]),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Passed the requested icons here!
          Expanded(child: _buildTypeButton('Expense', TransactionType.expense, AppConstants.errorColor, Icons.trending_down_rounded)),
          Expanded(child: _buildTypeButton('Income', TransactionType.income, AppConstants.successColor, Icons.trending_up_rounded)),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type, Color activeColor, IconData icon) {
    final isSelected = _transactionType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
          _selectedCategory = type == TransactionType.income ? TransactionCategory.salary : TransactionCategory.food;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected && !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _transactionType == TransactionType.income
        ? [TransactionCategory.salary, TransactionCategory.freelance, TransactionCategory.bonus, TransactionCategory.other]
        : TransactionCategory.values.where((c) => c != TransactionCategory.salary && c != TransactionCategory.freelance && c != TransactionCategory.bonus).toList();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: categories.map((category) => _buildCategoryBubble(category)).toList(),
    );
  }

  Widget _buildCategoryBubble(TransactionCategory category) {
    final isSelected = _selectedCategory == category;
    final color = getCategoryColor(category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? color : (isDark ? const Color(0xFF1E293B) : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!), width: 1.5),
                boxShadow: [
                  if (isSelected) BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(getCategoryIcon(category), color: isSelected ? Colors.white : color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              getCategoryLabel(category),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppConstants.primaryColor),
            const SizedBox(width: 16),
            Text(
              DateFormat('MMMM dd, yyyy').format(_selectedDate),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final transaction = Transaction(
      id: widget.transaction?.id,
      amount: amount,
      type: _transactionType,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );

    widget.transaction != null ? await context.read<TransactionProvider>().updateTransaction(transaction) : await context.read<TransactionProvider>().addTransaction(transaction);
    if (mounted) Navigator.pop(context);
  }
}