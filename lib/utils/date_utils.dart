// lib/utils/date_utils.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppDateUtils {
  // Formatters
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat displayDateFormat = DateFormat('EEEE, MMMM dd, yyyy');
  static final DateFormat displayTimeFormat = DateFormat('hh:mm a');
  static final DateFormat shortDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy');

  // Format DateTime to display string
  static String formatDisplayDate(DateTime date) {
    return displayDateFormat.format(date);
  }

  static String formatDisplayTime(DateTime time) {
    return displayTimeFormat.format(time);
  }

  static String formatShortDate(DateTime date) {
    return shortDateFormat.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return dateTimeFormat.format(dateTime);
  }

  // Time ago formatter
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Get display text for date (Today, Tomorrow, Yesterday, or date)
  static String getDisplayDateText(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatShortDate(date);
    }
  }

  // Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Check if date is within a range
  static bool isWithinRange(
    DateTime date,
    DateTime start,
    DateTime end,
  ) {
    return date.isAfter(start) && date.isBefore(end);
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  // Get end of week
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Add business days
  static DateTime addBusinessDays(DateTime date, int days) {
    var result = date;
    var addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return result;
  }

  // Check if date is a weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  // Get duration between two dates in readable format
  static String getDurationText(DateTime start, DateTime end) {
    final duration = end.difference(start);

    if (duration.inHours < 1) {
      return '${duration.inMinutes} minutes';
    } else if (duration.inDays < 1) {
      return '${duration.inHours} hours';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} days';
    } else if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).floor();
      return '$weeks weeks';
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).floor();
      return '$months months';
    } else {
      final years = (duration.inDays / 365).floor();
      return '$years years';
    }
  }

  // Parse date string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Combine date and time
  static DateTime combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // Get age from birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
