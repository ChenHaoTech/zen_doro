import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

abstract class FnBottomSheet {
  static Future sharp(
    Widget widget,
  ) async {
    await Get.bottomSheet(
      widget.safeArea().material(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
          ),
      isScrollControlled: true,
      enterBottomSheetDuration: Duration(seconds: 0),
    );
  }

  static Future<void> bottomSheet<T>(
    Widget widget, {
    GlobalKey<ScaffoldState>? keyHolder,
    Color? backgroundColor,
    double? elevation,
    bool persistent = true,
    Clip? clipBehavior,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? settings,
    double radius = 20,
    Duration? enterBottomSheetDuration,
    Duration? exitBottomSheetDuration,
  }) async {
    var widget2 = widget.paddingOnly(top: 12, left: 12, right: 12).safeArea().material(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          color: backgroundColor,
        );
    if (keyHolder != null && keyHolder.currentState != null) {
      var controller = keyHolder.currentState?.showBottomSheet(
        (context) => widget2,
        backgroundColor: backgroundColor,
        elevation: elevation,
        clipBehavior: clipBehavior,
        enableDrag: enableDrag,
      );
      return await controller?.closed;
    }
    return await Get.bottomSheet(
      widget2,
      backgroundColor: backgroundColor,
      elevation: elevation,
      persistent: persistent,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled ?? false,
      settings: settings,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      enterBottomSheetDuration: enterBottomSheetDuration,
      exitBottomSheetDuration: exitBottomSheetDuration,
      isDismissible: isDismissible,
    );
  }
}
