import 'package:finance_app/models/goal.dart';
import 'package:finance_app/providers/goal_provider.dart';
import 'package:finance_app/screens/add_goal_screen.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
import 'package:finance_app/widgets/animated_fab.dart';
import 'package:finance_app/widgets/common_widgets.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';


class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Savings Goals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Active Goals
              provider.activeGoals.isEmpty
                  ? EmptyState(
                      title: 'No Active Goals',
                      message: 'Create a savings goal to get started',
                      icon: Icons.flag,
                      actionLabel: 'Add Goal',
                      onAction: () => _navigateToAddGoal(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.activeGoals.length,
                      itemBuilder: (context, index) {
                        final goal = provider.activeGoals[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildGoalCard(context, goal, provider),
                        );
                      },
                    ),
              // Completed Goals
              provider.completedGoals.isEmpty
                  ? EmptyState(
                      title: 'No Completed Goals',
                      message: 'Complete your savings goals to see them here',
                      icon: Icons.check_circle,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.completedGoals.length,
                      itemBuilder: (context, index) {
                        final goal = provider.completedGoals[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child:
                              _buildCompletedGoalCard(context, goal, provider),
                        );
                      },
                    ),
            ],
          );
        },
      ),
      floatingActionButton: AnimatedFAB(
        onPressed: () => _navigateToAddGoal(context),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    SavingsGoal goal,
    GoalProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onTrack = goal.isOnTrack;

    return GestureDetector(
      onTap: () => _navigateToEditGoal(context, goal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: onTrack
                  ? AppConstants.successColor.withOpacity(0.1)
                  : AppConstants.errorColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: onTrack
                                  ? AppConstants.successColor.withOpacity(0.2)
                                  : AppConstants.warningColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              onTrack ? 'On Track' : 'Off Track',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: onTrack
                                    ? AppConstants.successColor
                                    : AppConstants.warningColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Due: ${DateUtils.formatDate(goal.deadline)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () =>
                          _navigateToEditGoal(context, goal),
                    ),
                    PopupMenuItem(
                      child: const Text('Add Progress'),
                      onTap: () =>
                          _showAddProgressDialog(context, goal, provider),
                    ),
                    if (goal.currentAmount >= goal.targetAmount)
                      PopupMenuItem(
                        child: const Text('Mark Complete'),
                        onTap: () =>
                            _completeGoal(context, goal, provider),
                      ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () =>
                          _deleteGoal(context, goal.id, provider),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progressPercentage.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  onTrack
                      ? AppConstants.successColor
                      : AppConstants.warningColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Amount Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberUtils.formatCurrency(goal.currentAmount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onTrack
                            ? AppConstants.successColor
                            : AppConstants.primaryColor,
                      ),
                ),
                Text(
                  NumberUtils.formatCurrency(goal.targetAmount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedGoalCard(
    BuildContext context,
    SavingsGoal goal,
    GoalProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppConstants.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            goal.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completed: ${DateUtils.formatDate(goal.deadline)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    _deleteGoal(context, goal.id, provider),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberUtils.formatCurrency(goal.targetAmount),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.successColor,
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddGoal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGoalScreen(),
      ),
    );
  }

  void _navigateToEditGoal(BuildContext context, SavingsGoal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGoalScreen(goal: goal),
      ),
    );
  }

  void _showAddProgressDialog(
    BuildContext context,
    SavingsGoal goal,
    GoalProvider provider,
  ) {
    final controller = TextEditingController(
      text: goal.currentAmount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Current Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount >= 0) {
                provider.updateGoalProgress(goal.id, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _completeGoal(
    BuildContext context,
    SavingsGoal goal,
    GoalProvider provider,
  ) {
    provider.completeGoal(goal.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal completed! 🎉')),
    );
  }

  void _deleteGoal(
    BuildContext context,
    String goalId,
    GoalProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
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
              provider.deleteGoal(goalId);
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