// lib/core/utils/date_utils.dart

import 'package:intl/intl.dart'; // Import the intl package for date formatting

class DateUtils {
  /// Formats a DateTime object into a "Month Day, Year" string (e.g., "Jan 1, 2023").
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Formats a DateTime object into a "Month Day, Year at Hour:Minute AM/PM" string (e.g., "Jan 1, 2023 at 10:30 AM").
  static String formatFullDateTime(DateTime date) {
    return DateFormat('MMM d, y \'at\' h:mm a').format(date);
  }

  /// Formats a DateTime object into a "Day/Month/Year" string (e.g., "01/01/2023").
  static String formatNumericDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Checks if two DateTime objects represent the same day (ignoring time).
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
