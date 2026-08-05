import 'package:intl/intl.dart';

/// {@template price_formatter}
/// Формат цены для UI: `2 990 ₽`.
///
/// Собран в одном месте, чтобы цены не склеивались строками по экранам:
/// пейвол показывает и цену периода, и цену в пересчёте на месяц.
/// {@endtemplate}
abstract final class PriceFormatter {
  /// Копейки не показываем: тарифы задаются целыми рублями
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: '₽',
    decimalDigits: 0,
  );

  /// {@macro price_formatter}
  static String format(double price) => _currency.format(price);
}
