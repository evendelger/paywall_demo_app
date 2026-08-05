import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/theme/app_animations.dart';
import 'package:paywall_demo/src/feature/app/model/nav_item.dart';

/// {@template app_bottom_nav_bar}
/// Нижняя панель навигации
/// {@endtemplate}
class AppBottomNavBar extends StatelessWidget {
  /// {@macro app_bottom_nav_bar}
  const AppBottomNavBar({
    required this.tabsRouter,
    super.key,
  });

  final TabsRouter tabsRouter;

  /// Элементы панели навигации.
  ///
  /// Порядок должен совпадать с порядком роутов в `MainShell`.
  static List<NavItem> items(AppLocalizations l10n) => [
    NavItem(
      icon: Assets.icons.home,
      title: l10n.homeLabel,
    ),
    // Новый элемент добавляется сюда и в `MainShell`
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final items = AppBottomNavBar.items(l10n);

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NavigationBar(
        selectedIndex: tabsRouter.activeIndex,
        onDestinationSelected: (index) => tabsRouter.setActiveIndex(index),
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((state) {
          const height = 17 / 14;
          if (state.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(height: height);
          }
          return textTheme.bodyMedium?.copyWith(height: height);
        }),
        destinations: items.mapIndexed((index, item) {
          final isSelected = index == tabsRouter.activeIndex;

          return AnimatedOpacity(
            opacity: isSelected ? 1 : 0.4,
            duration: AppAnimations.navBarTransition,
            child: NavigationDestination(
              label: item.title,
              icon: item.icon.svg(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
