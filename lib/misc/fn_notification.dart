import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:local_notifier/local_notifier.dart';
export "./fn_notification_native.dart";

abstract class FnNotification {
  static GlobalKey<ScaffoldMessengerState> key = GlobalKey<ScaffoldMessengerState>();

  static void wip() {
    BotToast.showText(text: "🚧WIP");
  }

  static void toast(String msg) {
    BotToast.showText(text: msg);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showTextSnackBar({
    BuildContext? context,
    required String text,
    (String, void Function())? action,
    Duration? duration,
    double? width,
  }) {
    SnackBarAction? snackBarAction;
    if (action != null) {
      snackBarAction = SnackBarAction(label: action.$1, onPressed: action.$2);
    }
    return showSnackBar(
      context: context,
      content: Text(text),
      action: snackBarAction,
      duration: duration,
      width: width ?? (Get.context!.isMobile ? Get.width * .8 : null),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar({
    BuildContext? context,
    required Widget content,
    SnackBarAction? action,
    Duration? duration,
    double? width,
  }) {
    var isMobile2 = Get.context!.isMobile;
    var width2 = width ?? 280.0;
    var marginLefRight = (Get.width - width2) / 10;
    return key.currentState?.showSnackBar(
      SnackBar(
        action: action,
        content: content,
        margin: isMobile2 ? EdgeInsets.only(left: marginLefRight, right: marginLefRight, bottom: 60) : null,
        duration: duration ?? const Duration(milliseconds: 2500),
        width: isMobile2 ? null : width2,
        // Width of the SnackBar.
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
