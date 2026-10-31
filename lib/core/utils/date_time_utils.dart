import 'package:intl/intl.dart';

abstract class DateTimeUtils {
  static String formatDate(DateTime date, {String locale = 'ar'}) {
    return DateFormat('dd MMM yyyy', locale).format(date);
  }

  static String formatTime(DateTime date, {String locale = 'ar'}) {
    return DateFormat('hh:mm a', locale).format(date);
  }

  static String formatDateTime(DateTime date, {String locale = 'ar'}) {
    return DateFormat('dd MMM yyyy • hh:mm a', locale).format(date);
  }

  static String formatShortDate(DateTime date, {String locale = 'ar'}) {
    return DateFormat('dd MMM', locale).format(date);
  }

  static String relativeTime(DateTime date, {String locale = 'ar'}) {
    final diff = DateTime.now().difference(date);
    if (locale == 'ar') {
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
      return formatDate(date, locale: 'ar');
    } else {
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return formatDate(date, locale: 'en');
    }
  }

  static String durationLabel(int nights, {String locale = 'ar'}) {
    if (locale == 'ar') return '$nights ليلة';
    return '$nights nights';
  }

  static String flightDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}
