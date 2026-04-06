import 'package:finance_app/models/goal.dart';
import 'package:finance_app/providers/goal_provider.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';

class AddGoalScreen extends StatefulWidget {
  final SavingsGoal? goal;

  const AddGoalScreen({Key? key, this.goal}) : super(key: key);

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDeadline;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController = TextEditingController(text: widget.goal!.title);
      _targetAmountController = TextEditingController(text: widget.goal!.targetAmount.toString());
      _currentAmountController = TextEditingController(text: widget.goal!.currentAmount.toString());
      _descriptionController = TextEditingController(text: widget.goal!.description);
      _selectedDeadline = widget.goal!.deadline;
    } else {
      _titleController = TextEditingController();
      _targetAmountController = TextEditingController();
      _currentAmountController = TextEditingController(text: '0');
      _descriptionController = TextEditingController();
      _selectedDeadline = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.goal != null ? 'Edit Goal' : 'New Goal',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'What are you saving for?'),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'e.g., Vacation, Laptop...',
                hintStyle: TextStyle(color: Colors.grey[400]), // Added light grey hint
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'Target Amount'),
            const SizedBox(height: 12),
            TextField(
              controller: _targetAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppConstants.primaryColor),
              decoration: InputDecoration(
                hintText: '0.00', 
                hintStyle: TextStyle(color: Colors.grey[400]), // Added light grey hint
                prefixText: '₹ ',
              ),
              onChanged: (_) => setState(() {}), // Trigger progress update
            ),
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'Already Saved (Current)'),
            const SizedBox(height: 12),
            TextField(
              controller: _currentAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '0.00', 
                hintStyle: TextStyle(color: Colors.grey[400]), // Added light grey hint
                prefixText: '₹ ',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'Target Date'),
            const SizedBox(height: 12),
            _buildDatePicker(),
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'Details (Optional)'),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Any extra notes...',
                hintStyle: TextStyle(color: Colors.grey[400]), // Added light grey hint
              ),
            ),
            const SizedBox(height: 40),

            _buildProgressPreview(context),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveGoal,
                child: Text(
                  widget.goal != null ? 'Update Goal' : 'Create Goal',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800, 
        color: isDark ? Colors.white : Colors.black, // Set to Black for light mode
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
            const Icon(Icons.flag_rounded, color: AppConstants.primaryColor),
            const SizedBox(width: 16),
            Text(
              DateUtils.formatDate(_selectedDeadline),
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
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );
    if (picked != null && picked != _selectedDeadline) setState(() => _selectedDeadline = picked);
  }

  Widget _buildProgressPreview(BuildContext context) {
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
    final currentAmount = double.tryParse(_currentAmountController.text) ?? 0;
    final progress = targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppConstants.primaryColor),
                  ),
                  const SizedBox(height: 6),
                  // Formatted amount added back here!
                  Text(
                    '${NumberUtils.formatCurrency(currentAmount)} / ${NumberUtils.formatCurrency(targetAmount)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700, 
                      color: AppConstants.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppConstants.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (_titleController.text.isEmpty) return;
    final targetAmount = double.tryParse(_targetAmountController.text);
    if (targetAmount == null || targetAmount <= 0) return;

    final currentAmount = double.tryParse(_currentAmountController.text) ?? 0;

    final goal = SavingsGoal(
      id: widget.goal?.id,
      title: _titleController.text,
      targetAmount: targetAmount,
      currentAmount: currentAmount.clamp(0.0, targetAmount),
      deadline: _selectedDeadline,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      isCompleted: widget.goal?.isCompleted ?? false,
    );

    widget.goal != null ? await context.read<GoalProvider>().updateGoal(goal) : await context.read<GoalProvider>().addGoal(goal);
    if (mounted) Navigator.pop(context);
  }
}