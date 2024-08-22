import 'dart:developer' as dev;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/global_future.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/screens/DebugPage.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:get/get.dart';

abstract class DebugUtils {
  static log(String msg) {
    dev.log("[DebugUtils] $msg");
  }

  static void decodeDebugMode(String value) {
    if (value == "妖魔鬼怪快离开妖魔鬼怪快离开") {
      $kFnDebugRx.value = !kFnDebug;
      BotToast.showText(text: "DEBUG  MODE ${$kFnDebugRx.value ? "ON" : "OFF"}");
      return;
    }
    if (value == "lkjhgfdsa") {
      routes.to(() => DebugPage());
      return;
    }
  }

  static toast(String msg) {
    if (DebugFlag.debugToast) {
      if (GlobalFuture.loadingInit.isCompleted) BotToast.showText(text: msg);
    }
  }

  static List<Widget> widgets = [];

  static Disposer addView(Widget child) {
    if (kAnyDebug) {
      widgets.add(child);
      Get.rootController.update();
      return Disposer(() {
        widgets.remove(child);
        Get.rootController.update();
      });
    }
    return Disposer.empty();
  }
}

abstract class DebugFlag {
  static bool get syncLog => kDebugMode;

  static bool get download => kDebugMode;

  static bool get audio => false;

  static bool get debugToast => kAnyDebug;
}
