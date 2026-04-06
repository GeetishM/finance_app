import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/providers/goal_provider.dart';
import 'package:finance_app/providers/theme_provider.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/providers/localization_provider.dart';
import 'package:finance_app/screens/transactions_screen.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/screens/add_goal_screen.dart';
import 'package:finance_app/screens/goals_screen.dart';
import 'package:finance_app/services/database_service.dart';
import 'package:finance_app/utils/animations.dart';
import 'package:finance_app/utils/constants.dart';
import 'package:finance_app/utils/helpers.dart';
import 'package:finance_app/widgets/common_widgets.dart';
import 'package:finance_app/widgets/animated_transaction_item.dart';
import 'package:finance_app/widgets/custom_drawer.dart'; 
import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Controls the notification red dot badge
  bool _hasUnreadNotifications = true;
  
  // 🛠️ FIXED: Static flag ensures it only shows once per session when the time is met
  static bool _hasShownReminderSession = false;

  final List<Map<String, String>> _notificationHistory = [
    {
      'title': 'Daily Reminder',
      'body': 'Time to log your expenses!',
      'time': '8:00 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    
    // 🛠️ FIXED: Only check for the daily reminder logic. 
    // Removed the forced _showTopNotification() that was causing the duplicate/spam issue.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDailyReminder());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Custom Top-Right Notification Animation
  void _showTopNotification() {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopRightNotification(
        message: "Time to log your expenses!",
        onDismiss: () => overlayEntry.remove(),
        onTap: () {
          overlayEntry.remove();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto-remove after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }

  // Sleek Notification Menu (Opened by Bell)
  void _showNotificationMenu() {
    setState(() => _hasUnreadNotifications = false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Notifications",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (_notificationHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text("No new notifications")),
              )
            else
              ..._notificationHistory
                  .map(
                    (n) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppConstants.primaryColor.withOpacity(
                          0.1,
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: AppConstants.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        n['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(n['body']!),
                      trailing: Text(
                        n['time']!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Dynamic Time-based greeting
  String _getGreeting(LocalizationProvider loc) {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return loc.translate('Good Morning');
    } else if (hour < 17) {
      return loc.translate('Good Afternoon');
    } else {
      return loc.translate('Good Evening');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(loc),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              loc.translate('Finance Companion'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    _hasUnreadNotifications
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    size: 28,
                  ),
                  onPressed: _showNotificationMenu,
                ),
                if (_hasUnreadNotifications)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppConstants.errorColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Consumer2<TransactionProvider, GoalProvider>(
          builder: (context, transactionProvider, goalProvider, _) {
            final income = transactionProvider.totalIncome;
            final expenses = transactionProvider.totalExpenses;
            final balance = transactionProvider.balance;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaleFadeAnimation(
                    duration: const Duration(milliseconds: 600),
                    child: _buildBalanceCard(context, balance, loc),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: StaggerAnimation(
                          index: 0,
                          delay: const Duration(milliseconds: 100),
                          child: SummaryCard(
                            label: loc.translate('Income'),
                            amount: NumberUtils.formatCurrency(income),
                            color: AppConstants.successColor,
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StaggerAnimation(
                          index: 1,
                          delay: const Duration(milliseconds: 150),
                          child: SummaryCard(
                            label: loc.translate('Expenses'),
                            amount: NumberUtils.formatCurrency(expenses),
                            color: AppConstants.errorColor,
                            icon: Icons.trending_down_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (transactionProvider.expensesByCategory.isNotEmpty)
                    SlideInAnimation(
                      beginOffset: const Offset(0, 0.5),
                      child: _buildCategoryChart(
                        context,
                        transactionProvider,
                        loc,
                      ),
                    ),
                  const SizedBox(height: 24),

                  if (goalProvider.activeGoals.isNotEmpty)
                    SlideInAnimation(
                      beginOffset: const Offset(0, 0.3),
                      child: _buildGoalsSection(context, goalProvider, loc),
                    ),
                  const SizedBox(height: 24),

                  _buildRecentTransactions(context, transactionProvider, loc),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    double balance,
    LocalizationProvider loc,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: balance),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('Total Balance'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                NumberUtils.formatCurrency(value),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${loc.translate('Updated')} ${DateUtils.formatDateTimeCompact(DateTime.now())}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    TransactionProvider provider,
    LocalizationProvider loc,
  ) {
    final expensesByCategory = provider.expensesByCategory;

    if (expensesByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedEntries.take(5).toList();
    final totalExpenses = topCategories.fold(
      0.0,
      (sum, entry) => sum + entry.value,
    );

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
            loc.translate('Spending by Category'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: topCategories.map((entry) {
                  final percentage = entry.value / totalExpenses;
                  return PieChartSectionData(
                    value: percentage,
                    title: '${(percentage * 100).toStringAsFixed(0)}%',
                    color: getCategoryColor(entry.key),
                    radius: 60,
                    titleStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: topCategories
                .asMap()
                .entries
                .map(
                  (entry) => StaggerAnimation(
                    index: entry.key,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: getCategoryColor(entry.value.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.translate(getCategoryLabel(entry.value.key)),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            NumberUtils.formatCurrency(entry.value.value),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(
    BuildContext context,
    GoalProvider provider,
    LocalizationProvider loc,
  ) {
    final primaryGoal = provider.primaryGoal;

    if (primaryGoal == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onTrack = primaryGoal.isOnTrack;
    final primaryColor = onTrack
        ? AppConstants.successColor
        : AppConstants.warningColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('Savings Goals'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        BounceAnimation(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalsScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[200]!,
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
                              primaryGoal.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
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
                                onTrack
                                    ? loc.translate('On Track')
                                    : loc.translate('Needs Attention'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppConstants.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: primaryGoal.progressPercentage.clamp(
                              0.0,
                              1.0,
                            ),
                            minHeight: 12,
                            backgroundColor: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(primaryGoal.progressPercentage * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberUtils.formatCurrency(primaryGoal.currentAmount),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                      ),
                      Text(
                        NumberUtils.formatCurrency(primaryGoal.targetAmount),
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
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    TransactionProvider provider,
    LocalizationProvider loc,
  ) {
    final recentTransactions = provider.allTransactions.take(5).toList();

    if (recentTransactions.isEmpty) {
      return EmptyState(
        title: loc.translate('No Transactions'),
        message: loc.translate('Start by adding your first transaction'),
        icon: Icons.receipt_long_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.translate('Recent Transactions'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
              child: Text(
                loc.translate('View All'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: recentTransactions
              .asMap()
              .entries
              .map(
                (entry) => StaggerAnimation(
                  index: entry.key,
                  delay: const Duration(milliseconds: 50),
                  child: AnimatedTransactionListItem(
                    title: loc.translate(
                      getCategoryLabel(entry.value.category),
                    ),
                    amount:
                        '${entry.value.type == TransactionType.income ? '+' : '-'} ${NumberUtils.formatCurrency(entry.value.amount)}',
                    date: DateUtils.formatDateTimeCompact(entry.value.date),
                    categoryColor: getCategoryColor(entry.value.category),
                    categoryIcon: getCategoryIcon(entry.value.category),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddTransactionScreen(transaction: entry.value),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddTransactionScreen(transaction: entry.value),
                        ),
                      );
                    },
                    onDelete: () {
                      provider.deleteTransaction(entry.value.id);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.translate('Transaction deleted'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFF334155),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 4),
                          action: SnackBarAction(
                            label: loc.translate('UNDO'),
                            textColor: AppConstants.primaryColor,
                            onPressed: () {
                              provider.addTransaction(entry.value);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _checkDailyReminder() {
    // 🛠️ FIXED: Skip if we've already shown the notification in this app session
    if (_hasShownReminderSession) return;

    final now = DateTime.now();
    final time = DatabaseService.getReminderTime();

    // If current time is past the reminder time, and we haven't shown it yet...
    if (now.hour >= time['hour']! && now.minute >= time['minute']!) {
      setState(() {
        _hasUnreadNotifications = true; // Updates the AppBar icon dynamically
      });

      // 🛠️ FIXED: Call the top sliding notification instead of the bottom SnackBar
      _showTopNotification();
      
      // 🛠️ FIXED: Mark as shown so it doesn't trigger again when coming back to the tab
      _hasShownReminderSession = true;
    }
  }
}

// The Top-Right Sliding Notification Card
class _TopRightNotification extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _TopRightNotification({required this.message, required this.onDismiss, required this.onTap});

  @override
  State<_TopRightNotification> createState() => _TopRightNotificationState();
}

class _TopRightNotificationState extends State<_TopRightNotification> with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _aniController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _aniController, curve: Curves.elasticOut),
    );
    _aniController.forward();
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, right: 16),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(widget.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: widget.onDismiss,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}