import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

class AppAvatarImage extends StatelessWidget {
  const AppAvatarImage({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.borderRadius = 4,
    this.color,
    this.nameLetter,
  });

  final String? imageUrl;

  final double size;

  final double borderRadius;

  final Color? color;

  final String? nameLetter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final iconPlaceholder = Icon(
      Icons.person_rounded,
      color: colorScheme.primary,
    );

    return AppImageWidget(
      imageUrl: imageUrl,
      height: size,
      width: size,
      borderRadius: borderRadius,
      placeHolderPadding: const EdgeInsets.all(4),
      placeholder: iconPlaceholder,
    );
  }
}
