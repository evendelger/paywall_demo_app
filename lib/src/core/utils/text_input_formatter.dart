import 'package:flutter/services.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Формат вводимого текста
extension TextInputFormatterX on TextInputFormatter {
  /// Только текст
  static FilteringTextInputFormatter get onlyText =>
      FilteringTextInputFormatter.allow(RegExp(r'\D'));

  static MaskTextInputFormatter get dateMask => MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp('[0-9]')},
  );

  /// Только цифры
  static FilteringTextInputFormatter get onlyDigits =>
      FilteringTextInputFormatter.allow(RegExp(r'\d'));
}

class RuPhoneInputFormatter extends TextInputFormatter {
  const RuPhoneInputFormatter({this.allowAllOperators = false});

  /// When false (default) only mobile numbers starting with 9 are accepted,
  /// producing the mask '+7 (9XX) XXX-XX-XX'.
  /// When true, any operator code is accepted: '+7 (XXX) XXX-XX-XX'.
  final bool allowAllOperators;

  static const int maxChars = 18;

  /// Formats a raw phone string (e.g. '79161234567' or '7XXXXXXXXXX')
  /// into '+7 (XXX) XXX-XX-XX'.
  /// Returns null if the input does not yield exactly 10 digits after the
  /// country code.
  static String? formatPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('8') || digits.startsWith('7')) {
      digits = digits.substring(1);
    }
    if (digits.length != 10) return null;
    return '+7 (${digits.substring(0, 3)}) '
        '${digits.substring(3, 6)}-'
        '${digits.substring(6, 8)}-'
        '${digits.substring(8, 10)}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return TextEditingValue.empty;

    final isDeleting = oldValue.text.length > newValue.text.length;

    return allowAllOperators
        ? _formatAllOperators(oldValue, newValue, isDeleting)
        : _formatMobileOnly(oldValue, newValue, isDeleting);
  }

  // '+7 (9XX) XXX-XX-XX' — only 9XX operator codes (original behaviour).
  TextEditingValue _formatMobileOnly(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    bool isDeleting,
  ) {
    // Умное стирание: стёрли последний символ "+7 (9" → очищаем поле
    if (isDeleting &&
        oldValue.text == '+7 (9' &&
        newValue.text.length < oldValue.text.length) {
      return TextEditingValue.empty;
    }

    // Извлекаем цифры ПОСЛЕ кода страны и девятки
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('89') || digits.startsWith('79')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('8') ||
        digits.startsWith('7') ||
        digits.startsWith('9')) {
      digits = digits.substring(1);
    }
    if (digits.length > 9) digits = digits.substring(0, 9);

    final buffer = StringBuffer()..write('+7 (9');
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write(') ');
      if (i == 5) buffer.write('-');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // '+7 (XXX) XXX-XX-XX' — any operator code.
  TextEditingValue _formatAllOperators(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    bool isDeleting,
  ) {
    // Умное стирание: стёрли последний символ "+7 (" → очищаем поле
    if (isDeleting &&
        oldValue.text == '+7 (' &&
        newValue.text.length < oldValue.text.length) {
      return TextEditingValue.empty;
    }

    // Извлекаем цифры ПОСЛЕ кода страны (7 или 8)
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('8') || digits.startsWith('7')) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) digits = digits.substring(0, 10);

    final buffer = StringBuffer()..write('+7 (');
    for (var i = 0; i < digits.length; i++) {
      if (i == 3) buffer.write(') ');
      if (i == 6) buffer.write('-');
      if (i == 8) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
