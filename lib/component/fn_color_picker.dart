import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:get/get.dart';

Future<void> openColorPicker({
  Color? selectedColor,
  Function(Color color)? onColorPick,
  Function(ColorSwatch? colorSwatch)? onMainColorPick,
  Function(Color? color)? onSubmit,
}) async {
  Color? _color;
  Widget content = MaterialColorPicker(
    selectedColor: selectedColor,
    allowShades: true,
    onColorChange: (color) {
      _color = color;
      onColorPick?.call(color);
    },
    onMainColorChange: (colorw) {
      _color = colorw;
      onMainColorPick?.call(colorw);
    },
  );
  // content = Column(
  //   mainAxisSize: MainAxisSize.min,
  //   children: <Widget>[
  //     FloatingActionButton(
  //       onPressed: () {},
  //       backgroundColor: _color,
  //     ),
  //     const Divider(),
  //     SizedBox(
  //       width: 222,
  //       height: 222,
  //
  //       ///---------------------------------
  //       child: WheelPicker(
  //         color: HSVColor.fromColor(_color ?? Colors.redAccent),
  //         onChanged: (value) => {},
  //       ),
  //     ),
  //   ],
  // );
  Get.defaultDialog(title: "选择颜色".i18n, content: content, actions: [
    TextButton(
        onPressed: () {
          onSubmit?.call(null);
          Get.back();
        },
        child: Text("删除".i18n)),
    ElevatedButton(
        onPressed: () {
          onSubmit?.call(_color);
          Get.back();
        },
        child: Text("确认".i18n)),
  ]);
}