import 'package:finance_app/services/database_service.dart';
import 'package:finance_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/providers/theme_provider.dart';
import 'package:finance_app/providers/localization_provider.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/providers/goal_provider.dart';
import 'package:finance_app/utils/constants.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem({required Widget child, required int index}) {
    final delay = (index * 0.1).clamp(0.0, 1.0);
    final animation = Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: animation,
        child: child,
      ),
    );
  }

  Future<void> _handleClearData(BuildContext context, LocalizationProvider loc) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // 🛠️ Added breathing room at the bottom
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppConstants.errorColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                loc.translate('Clear All Data?'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          loc.translate('This will permanently delete all your transactions, goals, and history. This action cannot be undone.'),
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              loc.translate('Cancel'),
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              elevation: 0,
              // 🛠️ FIXED: Explicit padding to prevent squished text
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              loc.translate('Delete All'), // 🛠️ FIXED: Shortened text for better UX
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DatabaseService.clearAllData();
      
      if (mounted) {
        context.read<TransactionProvider>().loadTransactions();
        context.read<GoalProvider>().loadGoals();
        
        Navigator.pop(context); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.translate('All data cleared successfully'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final locProvider = context.watch<LocalizationProvider>();
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F7FF),
      child: Column(
        children: [
          _buildAnimatedItem(
            index: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
              decoration: const BoxDecoration(
                gradient: AppConstants.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    locProvider.translate('Finance Companion'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locProvider.translate('Offline & Secure'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAnimatedItem(
                  index: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      locProvider.translate('Preferences'),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                ),

                _buildAnimatedItem(
                  index: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(
                      locProvider.translate('Appearance'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: GestureDetector(
                      onTap: () => themeProvider.toggleTheme(),
                      child: Container(
                        width: 72,
                        height: 36,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Icon(
                                      Icons.light_mode_rounded,
                                      size: 16,
                                      color: isDark ? Colors.grey[500] : Colors.transparent,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Icon(
                                      Icons.dark_mode_rounded,
                                      size: 16,
                                      color: isDark ? Colors.transparent : Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutBack,
                              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                    size: 14, 
                                    color: isDark ? Colors.indigoAccent : Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                _buildAnimatedItem(
                  index: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.successColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.language_rounded, color: AppConstants.successColor, size: 22),
                    ),
                    title: Text(
                      locProvider.translate('Language'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: locProvider.currentLanguage,
                          icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          onChanged: (String? newValue) {
                            if (newValue != null) locProvider.setLanguage(newValue);
                          },
                          items: locProvider.supportedLanguages.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                _buildAnimatedItem(
                  index: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.alarm_rounded, color: Colors.amber, size: 22),
                    ),
                    title: Text(
                      locProvider.translate('Daily Reminder'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${DatabaseService.getReminderTime()['hour'].toString().padLeft(2, '0')}:${DatabaseService.getReminderTime()['minute'].toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: DatabaseService.getReminderTime()['hour']!,
                          minute: DatabaseService.getReminderTime()['minute']!,
                        ),
                      );
                      if (picked != null) {
                        await DatabaseService.saveReminderTime(picked.hour, picked.minute);
                        await NotificationService().scheduleDailyReminder(picked.hour, picked.minute);
                        setState(() {});
                      }
                    },
                  ),
                ),

                _buildAnimatedItem(
                  index: 5,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Divider(),
                  ),
                ),

                _buildAnimatedItem(
                  index: 6,
                  child: _buildDrawerItem(
                    context,
                    Icons.file_download_outlined,
                    locProvider.translate('Export Data'),
                    Colors.blue,
                    () => Navigator.pop(context),
                  ),
                ),
                _buildAnimatedItem(
                  index: 7,
                  child: _buildDrawerItem(
                    context,
                    Icons.restore_page_outlined,
                    locProvider.translate('Backup & Restore'),
                    Colors.teal,
                    () => Navigator.pop(context),
                  ),
                ),
                
                _buildAnimatedItem(
                  index: 8,
                  child: _buildDrawerItem(
                    context,
                    Icons.delete_forever_rounded,
                    locProvider.translate('Clear All Data'),
                    AppConstants.errorColor,
                    () => _handleClearData(context, locProvider),
                  ),
                ),
              ],
            ),
          ),

          _buildAnimatedItem(
            index: 9,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}