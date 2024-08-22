import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/theme.dart';

class HollowCircleWidget extends StatelessWidget {
  const HollowCircleWidget({
    super.key,
    required this.percent,
    required this.strokeWidth,
  });

  final double percent;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: context.colorScheme.primary,
      backgroundColor: context.colorScheme.primary.blend(context.colorScheme.background, 80),
      value: clampDouble(percent, 0, 1),
      // calculates the progress as a value between 0 and 1
      strokeWidth: strokeWidth,
      strokeCap: StrokeCap.round,
    );
  }
}
