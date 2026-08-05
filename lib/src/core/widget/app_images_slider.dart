import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/config.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// {@template images_slider}
/// Слайдер изображений
/// {@endtemplate}
class AppImagesSlider extends StatefulWidget {
  /// {@macro images_slider}

  const AppImagesSlider({
    required this.images,
    required this.height,
    super.key,
    this.viewportFraction = 1.0,
    this.separationValue = 0,
    this.radius = 0,
    this.imageAlignment,
    this.isAsset = false,
  });

  factory AppImagesSlider.asset({
    required List<String> images,
    required double height,
    double viewportFraction = 1.0,
    double separationValue = 0,
    double radius = 0,
    Alignment? imageAlignment,
  }) => AppImagesSlider(
    images: images,
    height: height,
    imageAlignment: imageAlignment,
    isAsset: true,
    radius: radius,
    separationValue: separationValue,
    viewportFraction: viewportFraction,
  );

  final List<String> images;

  final double height;

  final double viewportFraction;

  final double separationValue;

  final double radius;

  final Alignment? imageAlignment;

  final bool isAsset;

  @override
  State<AppImagesSlider> createState() => _AppImagesSliderState();
}

class _AppImagesSliderState extends State<AppImagesSlider> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: widget.viewportFraction);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final images = widget.images;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView(
            controller: _pageController,
            children: images.isEmpty
                ? [
                    const AppImageWidget(
                      placeHolderPadding: EdgeInsets.all(
                        UIConfig.kSidePadding,
                      ),
                    ),
                  ]
                : images
                      .mapIndexed(
                        (index, url) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: widget.isAsset
                              ? Image.asset(
                                  url,
                                  fit: BoxFit.cover,
                                )
                              : AppImageWidget(imageUrl: url),
                        ),
                      )
                      .toList(),
          ),
        ),

        if (widget.images.length > 1)
          SmoothPageIndicator(
            controller: _pageController,
            count: widget.images.length,
            effect: SlideEffect(
              activeDotColor: colorScheme.primary,
              dotColor: colorScheme.onSurfaceVariant,
              dotHeight: 8,
              spacing: 6,
              radius: 1,
              dotWidth: 8,
            ),
          ),
      ],
    );
  }
}
