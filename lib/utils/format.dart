import 'package:intl/intl.dart';

/// "2026-10-29" -> "29 Oct 2026". Null / empty -> "—".
String fmtDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final d = DateTime.tryParse(iso);
  return d == null ? iso : DateFormat('dd MMM yyyy').format(d);
}

String dash(Object? value) {
  final s = value?.toString().trim() ?? '';
  return s.isEmpty ? '—' : s;
}

String ordinal(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

String timeAgo(DateTime time) {
  final diff = DateTime.now().toUtc().difference(time.toUtc());
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return DateFormat('dd MMM').format(time.toLocal());
}
