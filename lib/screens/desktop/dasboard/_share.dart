import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:ui_extension/ui_extension.dart';

class FnBtn extends StatelessWidget {
  final void Function()? onTap;
  final IconData data;
  final double? iconSize;
  final Color? iconColor;
  final Color? containerColor;
  final LogicalKeySet? keySet;

  const FnBtn({
    super.key,
    this.onTap,
    required this.data,
    this.keySet,
    this.iconColor,
    this.containerColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: context.primary,
      iconSize: 48,
      onPressed: onTap,
      splashRadius: 40,
      hoverColor: Colors.transparent,
      icon: Icon(
        data,
        size: iconSize,
        color: iconColor,
      ),
    )
        .material(
          color: containerColor,
          radius: 40,
        )
        .guideToolTip(keySet);
  }
}
