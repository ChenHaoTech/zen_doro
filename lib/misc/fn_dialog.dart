// import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:get/get.dart';

abstract class FnDialog {
  static bool _showSearchDialogShow = false;
  static bool _show = false;

  static bool get isShow => _show;

  // static Future<Duration?> showDurationPicker({
  //   required Duration initialTime,
  //   BaseUnit baseUnit = BaseUnit.minute,
  //   double snapToMins = 1.0,
  //   BoxDecoration? decoration,
  //   String? title,
  // }) async {
  //   var du = Rx(initialTime);
  //   return Get.dialog(
  //     Dialog(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           if (title != null)
  //             Text(
  //               title,
  //               style: FnTextTheme.titleLarge,
  //             ),
  //           Obx(() {
  //             return DurationPicker(
  //               baseUnit: baseUnit,
  //               duration: du.value,
  //               onChange: (val) {
  //                 du.value = val;
  //               },
  //               snapToMins: 5.0,
  //             );
  //           }),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: [
  //               OutlinedButton(
  //                   onPressed: () {
  //                     Get.back();
  //                   },
  //                   child: Text("取消".i18n)),
  //               ElevatedButton(
  //                   onPressed: () {
  //                     Get.back(result: du.value);
  //                   },
  //                   child: Text("确认".i18n)),
  //             ],
  //           ).paddingSymmetric(horizontal: 24)
  //         ],
  //       ),
  //     ),
  //   );
  // }
  static Future<T> show<T>(Widget widget) async {
    _show = true;
    var result = await Get.dialog(widget);
    _show = false;
    return result;
  }

  static Future<void> showDialog(
    Widget widget, {
    List<Widget>? actions,
    CrossAxisAlignment? alignment,
    double radius = 20,
  }) {
    _show = true;
    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius))),
        child: Column(
          crossAxisAlignment: alignment ?? CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.paddingSymmetric(horizontal: 12, vertical: 12),
            if (actions != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
          ],
        ),
      ),
    ).then((value) => _show = false);
  }

  static Future<void> showDefault({
    String title = "Alert",
    Widget? content,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? confirmWidget,
    String? cancelTxt,
    bool? autoFocusConfirm,
  }) async {
    _show = true;
    fnassert(() => onConfirm != null || confirmWidget != null);
    await Get.defaultDialog(
      title: title,
      content: content,
      confirm: confirmWidget ??
          ElevatedButton(
            autofocus: autoFocusConfirm ?? PlatformUtils.isDesktop,
            onPressed: () {
              onConfirm?.call();
            },
            child: Text("Confirm".i18n),
          ),
      cancel: OutlinedButton(
        child: Text(cancelTxt ?? "Cancel".i18n),
        onPressed: () {
          if (onCancel == null) {
            Get.back();
          } else {
            onCancel.call();
          }
        },
      ),
    ).then((value) => _show = false);
  }
}
