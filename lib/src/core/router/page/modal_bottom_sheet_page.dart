import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/config.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

/// {@template modal_bottom_sheet_page}
/// Модальное окно
///{@endtemplate}
class ModalBottomSheetPage<T> extends Page<T?> {
  /// {@macro modal_bottom_sheet_page}
  const ModalBottomSheetPage({
    this.child,
    this.builder,
    super.key,
    super.name,
    this.constraints,
    this.title,
    this.subTitle,
    this.isDismissible = true,
    this.scaffold,
    this.closeButton,
  });

  factory ModalBottomSheetPage.scrollable({
    Widget Function(
      BuildContext context,
      ScrollController scrollController,
    )?
    builder,
    bool isDismissible = true,
  }) => ModalBottomSheetPage(
    isDismissible: isDismissible,
    builder: builder,
  );

  final Widget? child;

  final bool isDismissible;

  final BoxConstraints? constraints;

  final String? title;

  final String? subTitle;

  final Widget? scaffold;

  final Widget? closeButton;

  final Widget Function(
    BuildContext context,
    ScrollController scrollController,
  )?
  builder;

  static const roundedRectangleBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(UIConfig.kBorderRadius),
    ),
  );

  @override
  Route<T?> createRoute(BuildContext context) {
    return buildRoute(context);
  }

  ModalBottomSheetRoute<T?> buildRoute(BuildContext context) {
    return ModalBottomSheetRoute(
      isDismissible: isDismissible,
      builder: (context) => builder != null
          ? DraggableScrollableSheet(
              builder: builder!,
              expand: false,
            )
          : scaffold ??
                ModalSheetScaffold(
                  title: title,
                  subTitle: subTitle,
                  closeButton: closeButton,
                  isDismissible: isDismissible,
                  child: child,
                ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      showDragHandle: false,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      settings: this,
      enableDrag: isDismissible,
      constraints: constraints,
      shape: roundedRectangleBorder,
      isScrollControlled: builder == null,
    );
  }
}

class ModalSheetScaffold extends StatelessWidget {
  const ModalSheetScaffold({
    required this.child,
    this.title,
    this.subTitle,
    super.key,
    this.closeButtonColor,
    this.isDismissible = true,
    this.titleStyle,
    this.onExit,
    this.closeButton,
  });

  final TextStyle? titleStyle;

  final String? title;

  final String? subTitle;

  final Widget? child;

  final Color? closeButtonColor;

  final bool isDismissible;

  final VoidCallback? onExit;

  final Widget? closeButton;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final isTitleNotEmpty = title?.isNotEmpty ?? false;
    final isSubTitileIsNotEmpty = subTitle?.isNotEmpty ?? false;
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSubTitileIsNotEmpty || isTitleNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  32,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTitleNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: Text(
                                title!,
                                textAlign: TextAlign.left,
                                style: titleStyle ?? textTheme.headlineMedium,
                              ),
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),
                    if (isSubTitileIsNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subTitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Flexible(
              child: child ?? const SizedBox.shrink(),
            ),
          ],
        ),
        if (isDismissible)
          Positioned(
            top: 16,
            right: 16,
            child:
                closeButton ??
                AppRoundedIconButton(
                  onPressed: onExit ?? context.pop,
                  child: Icon(Icons.close, color: closeButtonColor),
                ),
          ),
      ],
    );
  }
}
