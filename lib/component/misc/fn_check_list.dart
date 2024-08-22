import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/padding_constants.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

/**
 *
 * @author chenhao91
 * @date   2023/11/15
 */
class FnCheckList extends StatelessWidget {
  final String title;
  final bool Function() valueSupplier;
  final Function(bool value) onChanged;

  const FnCheckList({Key? key, required this.title, required this.valueSupplier, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          return Checkbox(
            visualDensity: VisualDensity(horizontal: 0),
            value: valueSupplier.call(),
            onChanged: (v) {
              onChanged.call(v ?? false);
            },
          );
        }).sizedBox(height: 32),
        Text(title),
        gap8,
      ],
    ).inkWell(onTap: () => onChanged.call(!valueSupplier.call()));
  }
}
