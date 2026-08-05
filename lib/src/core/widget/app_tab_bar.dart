import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({required this.tabs, required this.controller, super.key});

  final List<String> tabs;

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: colorScheme.outline),
      ),
      padding: const EdgeInsets.all(2),
      child: TabBar(
        indicatorWeight: 0,
        controller: controller,
        tabs: tabs.map((tab) {
          return Tab(text: tab.toUpperCase(), height: 36);
        }).toList(),
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.primary,
        labelStyle: textTheme.labelMedium?.copyWith(height: 1),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(height: 1),
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        tabAlignment: TabAlignment.fill,
      ),
    );
  }
}
