import 'package:finance_app/services/database_service.dart';
import 'package:finance_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/providers/theme_provider.dart';
import 'package:finance_app/providers/localization_provider.dart';
import 'package:finance_app/utils/constants.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final locProvider = context.watch<LocalizationProvider>();
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8F7FF),
      child: Column(
        children: [
          // 🛠️ UX FIX: Replaced fake User Profile with an App Branding Header
          Container(
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

          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    locProvider.translate('Preferences'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),

                // Dark Mode Toggle
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.indigo.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: isDark ? Colors.indigoAccent : Colors.orange,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    locProvider.translate('Dark Mode'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  value: isDark,
                  activeColor: AppConstants.primaryColor,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),

                // Language Selector
                // 🛠️ UX FIX: Added overflow control & fixed container height to stop text squishing
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: AppConstants.successColor,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    locProvider.translate('Language'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    height: 36, // Force compact height
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: locProvider.currentLanguage,
                        icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                        dropdownColor: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            locProvider.setLanguage(newValue);
                          }
                        },
                        items: locProvider.supportedLanguages
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Daily Reminder
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.alarm_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    locProvider.translate('Daily Reminder'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 🛠️ UX FIX: Added subtle background to time to make it look clickable
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
                      await DatabaseService.saveReminderTime(
                        picked.hour,
                        picked.minute,
                      );
                      await NotificationService().scheduleDailyReminder(
                        picked.hour,
                        picked.minute,
                      );
                      // Trigger a rebuild to show new time
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Divider(),
                ),

                // 🛠️ UX FIX: Replaced "Log Out" with offline-appropriate app actions
                _buildDrawerItem(
                  context,
                  Icons.file_download_outlined,
                  locProvider.translate('Export Data'),
                  Colors.blue,
                ),
                _buildDrawerItem(
                  context,
                  Icons.restore_page_outlined,
                  locProvider.translate('Backup & Restore'),
                  Colors.teal,
                ),
                _buildDrawerItem(
                  context,
                  Icons.delete_forever_rounded,
                  locProvider.translate('Clear All Data'),
                  AppConstants.errorColor,
                ),
              ],
            ),
          ),

          // App Version Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
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
      onTap: () {
        Navigator.pop(context); // Closes drawer
        // TODO: Implement action (e.g., show a dialog or navigate to export screen)
      },
    );
  }
}