import 'package:intl/intl.dart';

extension StringExt on String {
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get titleCase => split(' ').map((w) => w.capitalised).join(' ');

  /// "arjun sharma" → "AS"
  String get initials {
    final parts = trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return isNotEmpty ? this[0].toUpperCase() : '';
  }
}

extension DateTimeExt on DateTime {
  /// "15 April 2026"
  String get displayDate => DateFormat('d MMMM yyyy').format(this);

  /// "15 Apr 2026"
  String get shortDate => DateFormat('d MMM yyyy').format(this);

  /// "09:00 AM"
  String get displayTime => DateFormat('hh:mm a').format(this);

  /// "15 April 2026 09:00 AM"
  String get displayDateTime => '$displayDate ${displayTime}';

  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return day == yesterday.day && month == yesterday.month && year == yesterday.year;
  }

  String get relativeLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return displayDate;
  }
}
