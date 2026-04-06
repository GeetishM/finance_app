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
      _targetAmountController =
          TextEditingController(text: widget.goal!.targetAmount.toString());
      _currentAmountController =
          TextEditingController(text: widget.goal!.currentAmount.toString());
      _descriptionController =
          TextEditingController(text: widget.goal!.description);
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildSectionTitle(context, 'Goal Title'),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Vacation Fund, Emergency Fund',
                ),
              ),
              const SizedBox(height: 24),

              // Target Amount
              _buildSectionTitle(context, 'Target Amount'),
              const SizedBox(height: 12),
              TextField(
                controller: _targetAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 24),

              // Current Amount
              _buildSectionTitle(context, 'Current Amount'),
              const SizedBox(height: 12),
              TextField(
                controller: _currentAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 24),

              // Deadline
              _buildSectionTitle(context, 'Deadline'),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 24),

              // Description
              _buildSectionTitle(context, 'Description (Optional)'),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Add details about your goal...',
                  hintMaxLines: 3,
                ),
              ),
              const SizedBox(height: 32),

              // Progress Preview
              _buildProgressPreview(context),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  child: Text(
                    widget.goal != null ? 'Update Goal' : 'Create Goal',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateUtils.formatDate(_selectedDeadline),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today,
              color: AppConstants.primaryColor,
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

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Widget _buildProgressPreview(BuildContext context) {
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
    final currentAmount = double.tryParse(_currentAmountController.text) ?? 0;
    final progress = targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Preview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${NumberUtils.formatCurrency(currentAmount)} / ${NumberUtils.formatCurrency(targetAmount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    final targetAmount = double.tryParse(_targetAmountController.text);
    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target amount')),
      );
      return;
    }

    final currentAmount = double.tryParse(_currentAmountController.text) ?? 0;

    final goal = SavingsGoal(
      id: widget.goal?.id,
      title: _titleController.text,
      targetAmount: targetAmount,
      currentAmount: currentAmount.clamp(0.0, targetAmount),
      deadline: _selectedDeadline,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      isCompleted: widget.goal?.isCompleted ?? false,
    );

    try {
      if (widget.goal != null) {
        await context.read<GoalProvider>().updateGoal(goal);
      } else {
        await context.read<GoalProvider>().addGoal(goal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.goal != null
                ? 'Goal updated successfully'
                : 'Goal created successfully'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}