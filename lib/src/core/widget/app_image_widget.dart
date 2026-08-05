import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

/// {@macro app_image_widget}
/// Виджет изображения с кэшированием
class AppImageWidget extends StatelessWidget {
  /// {@macro app_image_widget}
  const AppImageWidget({
    this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeHolderPadding = EdgeInsets.zero,
    this.placeholder,
    this.borderRadius = 4,
  });

  final String? imageUrl;

  final double? width;

  final double? height;

  final BoxFit fit;

  final Widget? placeholder;

  final EdgeInsets placeHolderPadding;

  final double borderRadius;

  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.all(Radius.circular(borderRadius));

    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: br,
        child: CachedNetworkImage(
          width: width,
          height: height,
          fit: fit,
          imageUrl: imageUrl!,
          progressIndicatorBuilder: (context, url, progress) => AppSkeleton(
            width: width ?? double.maxFinite,
            height: height ?? double.maxFinite,
            borderRadius: BorderRadius.zero,
          ),
          errorWidget:
              errorWidget ??
              (context, _, error) => _buildFallback(context.theme),
        ),
      );
    }
    return _buildFallback(context.theme);
  }

  Widget _buildFallback(ThemeData theme) {
    final br = BorderRadius.all(Radius.circular(borderRadius));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: br,
      ),
      padding: placeHolderPadding,
      child:
          placeholder ??
          FractionallySizedBox(
            heightFactor: 0.9,
            widthFactor: 0.9,
            child: FittedBox(
              child: Icon(
                Icons.image_not_supported_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
    );
  }
}
