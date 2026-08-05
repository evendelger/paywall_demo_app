import 'package:intl/intl.dart';

extension NumX on num {
  /// Переводит в рубли
  String get rubles => NumberFormat.currency(
    locale: 'ru',
    symbol: '\u{20BD}',
    decimalDigits: 0,
  ).format(this);

  /// Переводит в доллары
  String get dollars => NumberFormat.currency(
    locale: 'ru',
    symbol: '\$',
    decimalDigits: 0,
  ).format(this);

  String get number => NumberFormat.compact().format(this);
}
