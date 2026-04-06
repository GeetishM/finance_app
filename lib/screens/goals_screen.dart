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
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          indicatorColor: AppConstants.primaryColor,
          indicatorWeight: 3,
          dividerColor:
              Colors.transparent, // Clean up the harsh line under tabs
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
                      message:
                          'Create a savings goal to start tracking your progress',
                      icon: Icons.flag_rounded,
                      actionLabel: 'Add Goal',
                      onAction: () => _navigateToAddGoal(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
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
                      icon: Icons.emoji_events_rounded,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: provider.completedGoals.length,
                      itemBuilder: (context, index) {
                        final goal = provider.completedGoals[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCompletedGoalCard(
                            context,
                            goal,
                            provider,
                          ),
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
    final primaryColor = onTrack
        ? AppConstants.successColor
        : AppConstants.warningColor;

    return GestureDetector(
      onTap: () => _navigateToEditGoal(context, goal),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              onTrack ? 'On Track' : 'Needs Attention',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateUtils.formatDate(goal.deadline),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 🛠️ FIX #4: Custom Themed Popup Menu with Icons
                Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      elevation: 8,
                    ),
                  ),
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.grey[400],
                    ),
                    offset: const Offset(
                      0,
                      40,
                    ), // Pushes the menu slightly down
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Edit Goal',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        onTap: () => Future.delayed(
                          Duration.zero,
                          () => _navigateToEditGoal(context, goal),
                        ),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 20,
                              color: AppConstants.successColor,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Add Progress',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        onTap: () => Future.delayed(
                          Duration.zero,
                          () => _showAddProgressDialog(context, goal, provider),
                        ),
                      ),
                      if (goal.currentAmount >= goal.targetAmount)
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emoji_events_rounded,
                                size: 20,
                                color: AppConstants.warningColor,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Mark Complete',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          onTap: () => Future.delayed(
                            Duration.zero,
                            () => _completeGoal(context, goal, provider),
                          ),
                        ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: AppConstants.errorColor,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Delete',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppConstants.errorColor,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Future.delayed(
                          Duration.zero,
                          () => _deleteGoal(context, goal.id, provider),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: goal.progressPercentage.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(goal.progressPercentage * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberUtils.formatCurrency(goal.currentAmount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
                Text(
                  NumberUtils.formatCurrency(goal.targetAmount),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
          width: 1.5,
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.successColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: AppConstants.successColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            goal.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Completed: ${DateUtils.formatDate(goal.deadline)}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppConstants.errorColor,
                ),
                onPressed: () => _deleteGoal(context, goal.id, provider),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            NumberUtils.formatCurrency(goal.targetAmount),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
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
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );
  }

  void _navigateToEditGoal(BuildContext context, SavingsGoal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGoalScreen(goal: goal)),
    );
  }

  // 🛠️ UX FIX: Completely revamped Add Progress Dialog to act as an "Add Funds" deposit box!
  void _showAddProgressDialog(
    BuildContext context,
    SavingsGoal goal,
    GoalProvider provider,
  ) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Add to Savings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current total: ${NumberUtils.formatCurrency(goal.currentAmount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppConstants.successColor,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixText: '+ ₹ ',
                prefixStyle: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(
                      color: AppConstants.successColor,
                      fontWeight: FontWeight.w800,
                    ),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final amountToAdd = double.tryParse(controller.text);
              if (amountToAdd != null && amountToAdd > 0) {
                // We add the inputted amount to the current amount
                final newTotal = goal.currentAmount + amountToAdd;
                provider.updateGoalProgress(goal.id, newTotal);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added ${NumberUtils.formatCurrency(amountToAdd)} to ${goal.title}! 🎉',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppConstants.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Goal completed! 🎉',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteGoal(BuildContext context, String goalId, GoalProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Delete Goal',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to delete this goal? All progress will be lost.',
          style: TextStyle(height: 1.5),
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              provider.deleteGoal(goalId);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
