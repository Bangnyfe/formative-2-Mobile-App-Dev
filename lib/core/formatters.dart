import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String dateTime(DateTime date) =>
      DateFormat('MMM d, yyyy • h:mm a').format(date);

  static String shortDate(DateTime date) => DateFormat('MMM d').format(date);
}
