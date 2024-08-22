import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

/// Simple preloader inside a Center widget
const loadingWidget = Center(child: CircularProgressIndicator(color: Colors.orange));
const emptyWidget = SizedBox.shrink();

String debugString(String? debug) {
  return kDebugMode ? (debug ?? "") : "";
}

Widget debugStrWidget(dynamic Function() supplier) {
  if (!kDebugMode) return emptyWidget;
  return Obx(() => Text(supplier.call().toString()));
}

Widget debugWidget(Widget Function() supplier) {
  if (!kDebugMode) return emptyWidget;
  return Obx(() => supplier.call());
}

Widget debugTb() {
  return debugStrWidget(() => $zenService.$curTimeBlock.value.debugString());
}

Widget errorWidget(
  String msg, {
  TextStyle? style,
}) {
  return Center(
    child: Text(
      msg,
      style: style ?? TextStyle(color: Colors.red, fontSize: 16),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

const SizedBox gap2 = SizedBox(height: 2, width: 2);
const SizedBox gap4 = SizedBox(height: 4, width: 4);
const SizedBox gap8 = SizedBox(height: 8, width: 8);
const SizedBox gap12 = SizedBox(height: 12, width: 12);
const SizedBox gap16 = SizedBox(height: 16, width: 16);
const SizedBox gap24 = SizedBox(height: 24, width: 24);
const SizedBox gap32 = SizedBox(height: 32, width: 32);
const SizedBox gap48 = SizedBox(height: 48, width: 48);

const EdgeInsets p0 = EdgeInsets.all(0);
const EdgeInsets p2 = EdgeInsets.all(2);
const EdgeInsets p4 = EdgeInsets.all(4);
const EdgeInsets p8 = EdgeInsets.all(8);
const EdgeInsets p12 = EdgeInsets.all(12);
const EdgeInsets p16 = EdgeInsets.all(16);
const EdgeInsets p24 = EdgeInsets.all(24);
const EdgeInsets p32 = EdgeInsets.all(32);
const EdgeInsets p48 = EdgeInsets.all(48);

const EdgeInsets px4 = EdgeInsets.symmetric(horizontal: 4);
const EdgeInsets px8 = EdgeInsets.symmetric(horizontal: 8);
const EdgeInsets px12 = EdgeInsets.symmetric(horizontal: 12);
const EdgeInsets px16 = EdgeInsets.symmetric(horizontal: 16);
const EdgeInsets px24 = EdgeInsets.symmetric(horizontal: 24);
const EdgeInsets px32 = EdgeInsets.symmetric(horizontal: 32);
const EdgeInsets px48 = EdgeInsets.symmetric(horizontal: 48);

const EdgeInsets py4 = EdgeInsets.symmetric(vertical: 4);
const EdgeInsets py8 = EdgeInsets.symmetric(vertical: 8);
const EdgeInsets py12 = EdgeInsets.symmetric(vertical: 12);
const EdgeInsets py16 = EdgeInsets.symmetric(vertical: 16);
const EdgeInsets py24 = EdgeInsets.symmetric(vertical: 24);
const EdgeInsets py32 = EdgeInsets.symmetric(vertical: 32);
const EdgeInsets py48 = EdgeInsets.symmetric(vertical: 48);

abstract class FnPadding {
  // static EdgeInsets get keyboard => EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom);
  static SizedBox gap(double size) => SizedBox(height: size, width: size);

  static SizedBox hgap(double size) => SizedBox(width: size);

  static SizedBox vgap(double size) => SizedBox(height: size);
}
