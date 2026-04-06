import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  static String formatDateTimeCompact(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly.year == now.year) {
      return DateFormat('MMM dd').format(dateTime);
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return !date.isBefore(weekAgo) && !date.isAfter(now);
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}

class NumberUtils {
  static String formatCurrency(double amount) {
    // 🛠️ UX FIX: Only show decimals if there are actual cents. 
    // This saves tons of space! (e.g. ₹20,000.00 -> ₹20,000)
    bool hasDecimals = amount.truncateToDouble() != amount;

    final formatter = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      name: '₹',
      decimalDigits: hasDecimals ? 2 : 0, 
    );
    return formatter.format(amount);
  }

  static String formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

class AnimationHelpers {
  static Duration getDuration(AnimationDuration duration) {
    switch (duration) {
      case AnimationDuration.fast:
        return const Duration(milliseconds: 200);
      case AnimationDuration.normal:
        return const Duration(milliseconds: 300);
      case AnimationDuration.slow:
        return const Duration(milliseconds: 500);
    }
  }
}

enum AnimationDuration { fast, normal, slow }