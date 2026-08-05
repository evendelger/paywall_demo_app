import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/app_rounded_icon_button.dart';

/// Обёртка для содержимого bottom sheet: drag-handle сверху + дочерний виджет.
class AppSheetBody extends StatelessWidget {
  const AppSheetBody({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSheetDragHandle(),
        Flexible(child: child),
      ],
    );
  }
}

class AppSheetDragHandle extends StatelessWidget {
  const AppSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Center(
      child: Container(
        height: 5,
        width: 36,
        margin: const EdgeInsets.only(top: 5, bottom: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: AppRoundedIconButton(
        icon: Assets.icons.arrowLeft,
        raduis: 100,
        showBorder: false,
        onPressed: () => context.maybePop(),
      ),
      toolbarHeight: 40,
      primary: false,
      title: Text(title, style: textTheme.bodyLarge),
      leadingWidth: 40 + 16 + 8,
    );
  }
}
