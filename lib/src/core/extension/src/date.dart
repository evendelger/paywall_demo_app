import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

extension DateTimeFormattingX on DateTime {
  /// dd.MM.yyyy
  String localizedNumericDate(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd.MM.yyyy', locale).format(toLocal());
  }

  /// dd.MM.yyyy HH:mm
  String localizedNumericDateTime(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd.MM.yyyy HH:mm', locale).format(toLocal());
  }

  /// dd MMMM yyyy
  String localizedFullDate(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMMd(locale).format(toLocal());
  }

  String get nonLocalizedTime => DateFormat('HH:mm').format(toLocal());

  /// HH:mm (локализованное время)
  String localizedTime(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('HH:mm', locale).format(toLocal());
  }

  /// EE, d MMMM
  String localizedDayString(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('EE, d MMMM', locale).format(toLocal());
  }

  /// dd MMMM, E
  String localizedDateWithMonthName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMMM, E', locale).format(toLocal());
  }

  /// dd MMM | E
  String localizedDateWithMonthShort(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMM | E', locale).format(toLocal());
  }

  /// dd MMMM, yyyy
  String localizedFullDateOnly(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMMM, yyyy', locale).format(toLocal());
  }

  /// dd MMMM, HH:mm
  String localizedFullDateTime(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMMd(locale).add_Hm().format(toLocal());
  }

  /// dd MMMM HH:mm
  String localizedFullDateTimeWithoutComma(BuildContext context) {
    return localizedFullDateTime(context).replaceAll('.', '');
  }

  /// dd.MM
  String localizedMonthDay(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd.MM', locale).format(toLocal());
  }

  /// являются ли дни равными
  bool equalDay(DateTime date) =>
      day == date.day && month == date.month && year == date.year;

  /// одинаковые ли месяцы у дат
  bool equalMonth(DateTime date) => year == date.year && month == date.month;

  String get apiDate => DateFormat('yyyy-MM-dd').format(this);

  /// MMM
  String localizedMonthShort(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('MMM', locale).format(toLocal()).replaceAll('.', '');
  }

  /// MMMM
  String localizedMonthName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('MMMM', locale).format(toLocal());
  }

  // LLLL
  String localizedMonthNameFromDay(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('LLLL', locale).format(toLocal());
  }

  // EEEE, dd MMMM
  String localizedWeekdayFull(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('EEEE, dd MMMM', locale).format(toLocal());
  }

  /// dd MMM
  String localizedDayMonthShort(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMM', locale).format(toLocal());
  }

  /// EEE
  String localizedWeekdayShort(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.E(locale).format(toLocal());
  }

  /// EEEE, dd MMM
  String localizedPrettyWeekdayShort(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('EEEE, dd MMM', locale).format(toLocal());
  }

  TimeOfDay get toTimeOfDay {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// LLLL yyyy
  String formatMonthYear(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('LLLL yyyy', locale).format(this).capitalize;
  }

  /// LLLL or yLLLL
  String monthNameWithYearIfNeeded(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();

    final pattern = (year == now.year) ? 'LLLL' : 'yLLLL';
    return DateFormat(pattern, locale).format(this).capitalize;
  }

  /// dd MMMM
  String dayMonth(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMMM', locale).format(this);
  }
}

extension DateTimeLogicX on DateTime {
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }

  bool get isPastDay {
    final today = DateTime.now();
    return DateTime(
      year,
      month,
      day,
    ).isBefore(DateTime(today.year, today.month, today.day));
  }

  bool get isFutureDay {
    final today = DateTime.now();
    return DateTime(
      year,
      month,
      day,
    ).isAfter(DateTime(today.year, today.month, today.day));
  }

  bool get isFirstDayOfMonth => day == 1;

  bool get isLastDayOfMonth => day == DateTime(year, month + 1, 0).day;

  bool get isInCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}
