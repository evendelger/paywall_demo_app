import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';

/// {@template app_loader}
/// Индикатор загрузки
/// {@endtemplate}
class AppLoader extends StatelessWidget {
  /// {@macro loader}
  const AppLoader({
    super.key,
    this.color,
    this.dimension = 20,
  });

  final Color? color;

  final double dimension;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.theme.colorScheme.primary;

    return Center(
      child: Platform.isIOS
          ? CupertinoActivityIndicator(
              color: color,
              radius: dimension / 2,
            )
          : SizedBox.square(
              dimension: dimension,
              child: CircularProgressIndicator(
                color: color,
                strokeWidth: 2,
              ),
            ),
    );
  }
}
