import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

extension StringX on String {
  /// Только цифры
  String get onlyDigits => replaceAll(RegExp('[^0-9]'), '');

  /// Форматирование строки с первой заглавной
  String get capitalize {
    if (isEmpty) return this;

    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Форматирование строки с установлением заглавных во всех словах
  String get capitalizeWords {
    if (isEmpty) return this;

    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Форматирует в дату
  DateTime toDate({bool clearHours = false}) {
    final date = DateFormat(
      'dd.MM.yyyy',
    ).parse(this);

    return clearHours ? DateTime(date.year, date.month, date.day) : date;
  }

  /// Форматирует в дату из строки вида 'yyyy-MM-dd'
  DateTime get fromApiDate => DateFormat('yyyy-MM-dd').parse(this);

  bool get isEmailValid =>
      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(this);

  /// Перевод строки вида "hh:mm:ss" в модель TimeOfDay
  TimeOfDay? get toTimeOfDay {
    final timeRegExp = RegExp(
      r'^(?<hours>[01]\d|2[0-3]):(?<minutes>[0-5]\d):(?<seconds>[0-5]\d)$',
    );

    final match = timeRegExp.firstMatch(this);

    if (match == null) return null;

    final hours = int.tryParse(match.namedGroup('hours') ?? '');
    final minutes = int.tryParse(match.namedGroup('minutes') ?? '');

    if (hours == null || minutes == null) return null;

    return TimeOfDay(hour: hours, minute: minutes);
  }

  String get replaceNulls => replaceAll('null', '').trim();
}
