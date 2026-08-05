import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/widget/app_rounded_icon_button.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.leading,
    this.leadingWidth,
    this.action,
    this.centerTitle = true,
  });

  final Widget? title;

  final Widget? leading;

  final double? leadingWidth;

  final Widget? action;

  final bool centerTitle;

  static const double height = 52;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      actionsPadding: const EdgeInsets.only(right: 16),
      title: title,
      centerTitle: centerTitle,
      leadingWidth: 40 + 32,
      leading: leading ?? _buildLeading(context, null),
      actions: [
        ?action,
      ],
    );
  }

  Widget _buildLeading(
    BuildContext context,
    void Function()? onPressed,
  ) {
    return AutoLeadingButton(
      ignorePagelessRoutes: true,
      builder: (context, leadingType, action) {
        final onTap = onPressed ?? action;
        if (onTap == null) {
          return const SizedBox();
        }

        return AppRoundedIconButton(
          onPressed: onTap,
          icon: Assets.icons.arrowLeft,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(height);
}
