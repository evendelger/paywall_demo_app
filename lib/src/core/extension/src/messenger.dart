import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/core/theme/theme.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:share_plus/share_plus.dart';

enum MessageType {
  success,
  warning,
  error;

  Color get color => switch (this) {
    success => AppPalette.success,
    warning => AppPalette.warning,
    error => AppPalette.red,
  };
}

extension ContextMessengerX on BuildContext {
  /// Копировать в буфер обмена
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    return showMessage('Скопировано', dialogType: MessageType.success);
  }

  /// Показать toast-сообщение поверх UI
  Future<void> showMessage(
    String? text, {
    String? title,
    MessageType? dialogType,
    List<Widget> actions = const [],
    Duration? duration,
    Widget? icon,
  }) async {
    final overlayState = Overlay.of(this);
    late OverlayEntry overlayEntry;

    final textContent = text ?? l10n.error;
    const symbolRowSize = 40;
    final milliseconds = switch (textContent.length) {
      > symbolRowSize * 3 => 7000,
      > symbolRowSize * 2 => 5000,
      >= symbolRowSize => 4000,
      _ => 3000,
    };
    final displayDuration = duration ?? Duration(milliseconds: milliseconds);

    overlayEntry = OverlayEntry(
      builder: (context) {
        final resolvedIcon =
            icon ??
            switch (dialogType) {
              MessageType.success => Assets.icons.statusSuccessCircle.svg(),
              MessageType.error => Assets.icons.statusErrorCircle.svg(),
              _ => Assets.icons.statusWarningCircle.svg(),
            };
        return AppToastMessage(
          title: textContent,
          icon: resolvedIcon,
          duration: displayDuration,
          onDismiss: () => overlayEntry.remove(),
        );
      },
    );

    overlayState.insert(overlayEntry);
  }

  /// Поделиться
  Future<ShareResult> share(
    String text, {
    String? subject,
    String? title,
  }) async {
    final box = findRenderObject() as RenderBox?;
    return SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        title: title,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  /// Показать modal bottom sheet диалог
  /// НЕ ИСПОЛЬЗОВАТЬ - НЕ НАСТРОЕНО
  Future<T?> showModalDialog<T>({
    required String title,
    String? acceptLabel,
    String? subTitle,
    String? cancelLabel,
    VoidCallback? onAccept,
    Color? acceptLabelColor,
    MessageType dialogType = MessageType.success,
    bool isDismissible = true,
    Widget? buttonContent,
    EdgeInsets? contentPadding,
    Widget? Function(BuildContext context)? builder,
  }) async {
    return showModalBottomSheet<T?>(
      context: this,
      enableDrag: isDismissible,
      isDismissible: isDismissible,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme = context.colorScheme;
        void onPressed() {
          if (isDismissible) context.pop();
          onAccept?.call();
        }

        return ModalSheetScaffold(
          isDismissible: isDismissible,
          closeButtonColor: theme.cardColor,
          title: title,
          subTitle: subTitle,
          child: Padding(
            padding:
                contentPadding?.copyWith(top: 26) ??
                const EdgeInsets.fromLTRB(
                  UIConfig.kSidePadding,
                  26,
                  UIConfig.kSidePadding,
                  16,
                ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (builder != null)
                  Flexible(child: SafeArea(child: builder(context)!)),
                if (acceptLabel != null) ...[
                  SafeArea(
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: switch (dialogType) {
                        MessageType.success => FilledButton(
                          onPressed: onPressed,
                          child: buttonContent ?? Text(acceptLabel),
                        ),
                        MessageType.warning => FilledButton(
                          style: FilledButton.styleFrom(
                            textStyle: textTheme.bodySmall,
                            backgroundColor:
                                theme.colorScheme.tertiaryContainer,
                            foregroundColor: context.textTheme.bodySmall?.color,
                          ),
                          onPressed: onPressed,
                          child: Text(acceptLabel),
                        ),
                        _ => FilledButton(
                          style: FilledButton.styleFrom(
                            textStyle: textTheme.bodySmall,
                            backgroundColor: colorScheme.errorContainer,
                            foregroundColor: colorScheme.onErrorContainer,
                          ),
                          onPressed: onPressed,
                          child: Text(acceptLabel),
                        ),
                      },
                    ),
                  ),
                  if (cancelLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: context.pop,
                          child: Text(cancelLabel),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
      backgroundColor: theme.scaffoldBackgroundColor,
      showDragHandle: false,
      clipBehavior: Clip.antiAlias,
    );
  }

  /// Показать диалоговое окно
  Future<T?> showAcceptDialog<T>({
    required String text,
    required VoidCallback onAccept,
    Color? acceptColor,
  }) {
    return showAdaptiveDialog<T?>(
      context: this,
      barrierDismissible: true,
      builder: (context) {
        final cancelButtonLabel = MaterialLocalizations.of(
          context,
        ).cancelButtonLabel;
        return AlertDialog.adaptive(
          title: Text(
            text,
          ),
          actions: [
            TextButton(
              onPressed: context.pop,
              child: Text(cancelButtonLabel),
            ),
            TextButton(
              onPressed: () {
                onAccept.call();
                context.pop();
              },
              child: Text(
                context.l10n.yesLabel,
                style: TextStyle(color: acceptColor),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Показать информационный диалог
  Future<T?> showInfoDialog<T>({
    required Widget content,
  }) {
    return showDialog<T?>(
      context: this,
      builder: (context) {
        final colorScheme = context.colorScheme;

        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                content,

                Positioned(
                  right: 0,
                  top: 0,
                  child: ColoredBox(
                    color: colorScheme.surface,
                    child: AppRoundedIconButton(
                      icon: Assets.icons.close,
                      raduis: 100,
                      dimension: 25,
                      showBorder: false,
                      onPressed: () => context.maybePop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
