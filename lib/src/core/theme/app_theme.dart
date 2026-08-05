import 'dart:io';

import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/theme/app_colors.dart';
import 'package:paywall_demo/src/core/theme/app_typography.dart';

/// Темы приложения
abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme();

  static const verticalRoundedRectangleBorder38 = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
  );

  static const roundedRectangleBorder38 = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(38)),
  );

  static const outlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide.none,
  );

  static const roundedRectangleBorder4 = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
  );

  static const roundedRectangleBorder2 = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
  );

  /// Светлая тема
  static ThemeData _buildTheme() {
    final colorScheme = _createColorScheme();

    final textTheme = _createTextTheme().apply(
      // Шрифт проекта: добавьте его в `pubspec.yaml` и укажите здесь
      // `fontFamily: FontFamily.<name>`. По умолчанию — системный.
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      // visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      splashFactory: NoSplash.splashFactory,
      primaryTextTheme: textTheme,

      // ==============================
      // Настройка компонентов
      // ==============================
      expansionTileTheme: ExpansionTileThemeData(
        collapsedBackgroundColor: colorScheme.surface,
        backgroundColor: colorScheme.surface,
        collapsedIconColor: colorScheme.primary,
        iconColor: colorScheme.primary,
        textColor: colorScheme.onSurface,
        collapsedTextColor: colorScheme.onSurface,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color:
            colorScheme.surfaceContainerHighest, // Заливка карточки (lightBlue)
        shape: roundedRectangleBorder4,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            colorScheme.surfaceContainerHighest, // Фон инпута (lightBlue)
        border: outlineInputBorder,
        enabledBorder: outlineInputBorder,
        // disabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.primary, // Фокус (darkBlue)
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        alignLabelWithHint: true,
        errorBorder: outlineInputBorder,
        focusedErrorBorder: outlineInputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        errorStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.error,
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant, // Лейбл (gray)
        ),
        floatingLabelStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionHandleColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: .2),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),

      dividerTheme: DividerThemeData(
        thickness: 1,
        color: colorScheme.outline, // Цвет дивайдера (lightGray)
      ),

      dialogTheme: DialogThemeData(
        shape: roundedRectangleBorder38,
        // insetPadding: const EdgeInsets.all(16),
        backgroundColor: colorScheme.surface,
        alignment: Alignment.center,
        titleTextStyle: textTheme.displayLarge?.copyWith(
          color: colorScheme.primary,
        ),
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      buttonTheme: const ButtonThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: colorScheme.primary,
          overlayColor: Platform.isAndroid ? null : Colors.transparent,
        ),
      ),

      highlightColor: colorScheme.primary.withValues(alpha: .2),

      iconTheme: IconThemeData(
        color: colorScheme.primary, // Основные иконки (darkBlue)
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: roundedRectangleBorder4,
          backgroundColor: colorScheme.surface,
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface, // Явно указываем фон AppBar
        titleTextStyle: textTheme.headlineMedium,
        foregroundColor: colorScheme.primary,
        scrolledUnderElevation: 0,
        actionsPadding: const EdgeInsetsDirectional.only(end: 8),
      ),

      chipTheme: ChipThemeData(
        shape: roundedRectangleBorder2,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        shape: verticalRoundedRectangleBorder38,
        modalElevation: 0,
        backgroundColor: colorScheme.surface,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary, // darkBlue
          foregroundColor: colorScheme.onPrimary, // white
          // disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          // disabledForegroundColor: colorScheme.onSurfaceVariant,
          minimumSize: UIConfig.kMaxButtonSize,
          shape: roundedRectangleBorder4,
          textStyle: textTheme.labelLarge,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        ),
      ),
    );
  }

  static TextTheme _createTextTheme() {
    // Создаем базовый стиль, который задает правила центрирования
    const baseStyle = TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
    );

    // Вспомогательная функция для сборки темы
    TextStyle fix(TextStyle customStyle) => customStyle.merge(baseStyle);

    return TextTheme(
      // Заголовки
      displayLarge: fix(AppTypography.header21),
      headlineMedium: fix(AppTypography.header16),
      headlineSmall: fix(AppTypography.header14),

      // Текстовые стили
      bodyLarge: fix(AppTypography.text16), // Основной текст 16px
      bodyMedium: fix(AppTypography.text14), // Основной текст 14px
      bodySmall: fix(AppTypography.text14), // Дополнительный текст
      // Специфичные стили
      labelLarge: fix(AppTypography.button16), // Для кнопок
      labelMedium: fix(AppTypography.button14), // Для маленьких кнопок
      labelSmall: fix(AppTypography.caption12), // Для маленького доп. текста
      titleMedium: fix(AppTypography.text14Bold), // Для выделенного текста 14px
    );
  }

  static ColorScheme _createColorScheme() => const ColorScheme(
    brightness: Brightness.light,
    // ==========================================
    // ГРУППА 1: Основные цвета бренда (Primary)
    // ==========================================
    // Основной цвет (darkBlue): активные табы, основная кнопка, иконки, лого
    primary: AppPalette.darkBlue,
    // Текст и элементы поверх primary (белый на синей кнопке)
    onPrimary: AppPalette.white,

    // ==========================================
    // ГРУППА 2: Второстепенные акценты (Secondary)
    // ==========================================
    // Второстепенный акцент (blue): светлые кнопки
    secondary: AppPalette.blue,
    // Текст поверх secondary
    onSecondary: AppPalette.white,

    // ==========================================
    // ГРУППА 3: Фоны и поверхности (Surface)
    // ==========================================
    // Основной фон приложения Scaffold (white)
    surface: AppPalette.white,
    // Основной текст (dark) на фоне surface
    onSurface: AppPalette.dark,
    // Второстепенный текст (gray) на фоне surface
    onSurfaceVariant: AppPalette.gray,
    // Фон для карточек и текстовых полей (lightBlue). В M3 это роль для заливки контейнеров.
    surfaceContainerHighest: AppPalette.lightBlue,

    // ==========================================
    // ГРУППА 4: Ошибки и экстренные действия (Error)
    // ==========================================
    // Цвет ошибок, текста, красных бордеров (red)
    error: AppPalette.red,
    // Текст на фоне error
    onError: AppPalette.white,
    // Фон под ошибочным/экстренным текстом (pink)
    errorContainer: AppPalette.pink,
    // Цвет текста на фоне errorContainer (red)
    onErrorContainer: AppPalette.red,

    // ==========================================
    // ГРУППА 5: Границы и разделители (Outline)
    // ==========================================
    // Цвет границ элементов (lightGray)
    outline: AppPalette.lightGray,
    // Цвет для разделителей (lightSilver)
    outlineVariant: AppPalette.lightSilver,
  );
}
