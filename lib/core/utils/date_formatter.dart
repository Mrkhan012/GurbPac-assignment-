import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShort(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('MMM dd').format(date);
  }

  static String formatRelative(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }

  static String toIsoDateOnly(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
