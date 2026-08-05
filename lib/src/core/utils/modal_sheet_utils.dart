import 'package:flutter/widgets.dart';
import 'package:paywall_demo/src/core/extension/src/build_context.dart';
import 'package:paywall_demo/src/core/widget/app_sheet_body.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

abstract class ModalSheetUtils {
  static ModalSheetRoute<T> routeConfig<T>({
    required Widget Function(BuildContext context) builder,
    RouteSettings? settings,
    bool canDismiss = true,
    bool isScrollable = true,
    SheetOffset dismissalOffset = const SheetOffset.proportionalToViewport(0.3),
  }) => ModalSheetRoute<T>(
    settings: settings,
    swipeDismissible: canDismiss,
    barrierDismissible: canDismiss,
    swipeDismissSensitivity: SwipeDismissSensitivity(
      dismissalOffset: dismissalOffset,
    ),
    viewportBuilder: (context, child) {
      return SheetViewport(
        padding: EdgeInsets.only(top: context.mediaQuery.padding.top),
        child: child,
      );
    },
    builder: builder,
  );

  static Future<T?> openSheet<T>(
    BuildContext context, {
    required Widget content,
    String? title,
    bool canDismiss = true,
    bool isScrollable = true,
    SheetOffset dismissalOffset = const SheetOffset.proportionalToViewport(0.3),
  }) async {
    final modalRoute = routeConfig<T>(
      canDismiss: canDismiss,
      isScrollable: isScrollable,
      dismissalOffset: dismissalOffset,
      builder: (context) => AppBaseSheet(
        title: title,
        content: content,
        isScrollable: isScrollable,
      ),
    );

    return await Navigator.push<T>(context, modalRoute);
  }
}

class AppBaseSheet extends StatelessWidget {
  const AppBaseSheet({
    required this.isScrollable,
    required this.content,
    this.title,
    super.key,
  });

  final String? title;

  final Widget content;

  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final scrollConfig = isScrollable
        ? const SheetScrollConfiguration(
            scrollSyncMode: SheetScrollHandlingBehavior.onlyFromTop,
          )
        : SheetScrollConfiguration.disabled;

    return Sheet(
      scrollConfiguration: scrollConfig,
      physics: const BouncingSheetPhysics(bounceExtent: 0),
      decoration: const MaterialSheetDecoration(
        size: SheetSize.stretch,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
        elevation: 3,
      ),
      // snapGrid: SheetSnapGrid.single(
      //   snap: SheetOffset.proportionalToViewport(0.5),
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetDragHandle(),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppSheetHeader(title: title!),
            )
          else
            const SizedBox(height: 16),
          Flexible(child: content),
        ],
      ),
    );
  }
}
