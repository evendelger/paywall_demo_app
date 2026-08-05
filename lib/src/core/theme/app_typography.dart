import 'package:flutter/material.dart';

/// Основные стили текста в приложении
abstract final class AppTypography {
  // Header_21px - w500, 21px, height - 110%
  static const TextStyle header21 = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w500,
    height: 1.1,
  );

  // header_16px - w500, 16px, height - 20px (20/16 = 1.25)
  static const TextStyle header16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  // Header_14px - w400, 14px, height - 14px (14/14 = 1.0)
  static const TextStyle header14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  // Button_16px - w500, 16px, height - 16px
  static const TextStyle button16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // Button_14px - w500, 14px, height - 14px
  static const TextStyle button14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // Text_14px_Bold - w700, 14px, height - 20px (20/14 ≈ 1.43)
  static const TextStyle text14Bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  // Text_16px - w500, 16px, height - 20px (20/16 = 1.25)
  static const TextStyle text16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  // Text_14px - w400, 14px, height - 14px
  static const TextStyle text14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  // Caption_12px - w400, 12px, height - 12px
  static const TextStyle caption12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1,
  );
}
