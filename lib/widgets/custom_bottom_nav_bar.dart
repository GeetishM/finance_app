import 'package:finance_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: AppConstants.primaryColor.withOpacity(0.2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: GNav(
            // Animation & Behavior
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            tabActiveBorder: Border.all(
              color: AppConstants.primaryColor,
              width: 0,
            ),
            tabBorder: Border.all(color: Colors.transparent, width: 0),
            tabBackgroundColor: AppConstants.primaryColor.withOpacity(0.15),
            activeColor: AppConstants.primaryColor,
            iconSize: 24,

            // Padding & Gap
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            gap: 8,

            // Style
            hoverColor: AppConstants.primaryColor.withOpacity(0.1),
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            backgroundColor: Colors.transparent,

            // Current index
            selectedIndex: currentIndex,
            onTabChange: onTabChange,

            // Tabs
            tabs: [
              GButton(
                icon: Icons.home_rounded,
                text: 'Home',
                textStyle: TextStyle(
                  color: currentIndex == 0
                      ? AppConstants.primaryColor
                      : (isDark ? Colors.grey[500] : Colors.grey[600]),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                iconActiveColor: AppConstants.primaryColor,
                iconColor: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              GButton(
                icon: Icons.receipt_long_rounded,
                text: 'Transactions',
                textStyle: TextStyle(
                  color: currentIndex == 1
                      ? AppConstants.primaryColor
                      : (isDark ? Colors.grey[500] : Colors.grey[600]),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                iconActiveColor: AppConstants.primaryColor,
                iconColor: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              GButton(
                icon: Icons.flag_rounded,
                text: 'Goals',
                textStyle: TextStyle(
                  color: currentIndex == 2
                      ? AppConstants.primaryColor
                      : (isDark ? Colors.grey[500] : Colors.grey[600]),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                iconActiveColor: AppConstants.primaryColor,
                iconColor: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              GButton(
                icon: Icons.analytics_rounded,
                text: 'Insights',
                textStyle: TextStyle(
                  color: currentIndex == 3
                      ? AppConstants.primaryColor
                      : (isDark ? Colors.grey[500] : Colors.grey[600]),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                iconActiveColor: AppConstants.primaryColor,
                iconColor: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}