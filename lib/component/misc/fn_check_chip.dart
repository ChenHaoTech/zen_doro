import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/padding_constants.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

/**
 *
 * @author chenhao91
 * @date   2023/11/15
 */
class FnCheckChip extends StatelessWidget {
  final String title;
  final bool Function() valueSupplier;
  final Function(bool value) onChanged;

  const FnCheckChip({
    Key? key,
    required this.title,
    required this.valueSupplier,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = 18.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          if (valueSupplier.call()) {
            return Chip(
                avatar: Icon(
                  Icons.check_circle,
                  size: size,
                ),
                labelPadding: p0,
                label: Text(title).paddingOnly(right: 4));
          }
          return Chip(
            avatar: Icon(Icons.radio_button_unchecked, size: size),
            labelPadding: p0,
            label: Text(title).paddingOnly(right: 4),
          );
        }),
      ],
    ).easyTap(onTap: () {
      onChanged.call(valueSupplier.call());
    });
  }
}
