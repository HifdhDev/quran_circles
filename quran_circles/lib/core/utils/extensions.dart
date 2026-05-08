extension DateTimeExtension on DateTime {
  String toIso8601Ms() => toUtc().toIso8601String();

  static DateTime fromIso8601Ms(String iso) => DateTime.parse(iso).toLocal();
}
