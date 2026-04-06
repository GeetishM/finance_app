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

    // Dynamically set colors based on the theme for better visibility
    final activeItemColor = isDark ? Colors.white : AppConstants.primaryColor;
    final inactiveItemColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    
    // Slightly boost the background opacity in dark mode so the active pill stands out
    final activeBackgroundColor = isDark 
        ? AppConstants.primaryColor.withOpacity(0.3) 
        : AppConstants.primaryColor.withOpacity(0.15);

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
              color: Colors.transparent,
              width: 0,
            ),
            tabBorder: Border.all(color: Colors.transparent, width: 0),
            tabBackgroundColor: activeBackgroundColor,
            activeColor: activeItemColor,
            iconSize: 24,

            // Padding & Gap
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            gap: 8,

            // Style
            hoverColor: AppConstants.primaryColor.withOpacity(0.1),
            color: inactiveItemColor,
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
                  color: currentIndex == 0 ? activeItemColor : inactiveItemColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                iconActiveColor: activeItemColor,
                iconColor: inactiveItemColor,
              ),
              GButton(
                icon: Icons.receipt_long_rounded,
                text: 'Transactions',
                textStyle: TextStyle(
                  color: currentIndex == 1 ? activeItemColor : inactiveItemColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                iconActiveColor: activeItemColor,
                iconColor: inactiveItemColor,
              ),
              GButton(
                icon: Icons.flag_rounded,
                text: 'Goals',
                textStyle: TextStyle(
                  color: currentIndex == 2 ? activeItemColor : inactiveItemColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                iconActiveColor: activeItemColor,
                iconColor: inactiveItemColor,
              ),
              GButton(
                icon: Icons.analytics_rounded,
                text: 'Insights',
                textStyle: TextStyle(
                  color: currentIndex == 3 ? activeItemColor : inactiveItemColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                iconActiveColor: activeItemColor,
                iconColor: inactiveItemColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}