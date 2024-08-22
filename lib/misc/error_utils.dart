import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/global_future.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:rich_clipboard/rich_clipboard.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ui_extension/ui_extension.dart';

abstract class ErrorUtils {
  static Future<bool> get enable async {
    // 大于的版本号, 一般就是内部测试邦本
    var i = await FnConst.newestVersion;
    var innerHint = FnConst.innerVersion > (i);
    if (kDebugMode) fnassert(() => innerHint, [FnConst.innerVersion, i]);
    return kReleaseMode && !innerHint;
  }

  static Future login({
    required String userId,
    required String? email,
    required String userName,
  }) async {
    await Sentry.configureScope(
      (scope) => scope.setUser(SentryUser(
        id: userId,
        email: email,
        name: userName,
      )),
    );
  }

  static void report(dynamic e, [StackTrace? trace]) async {
//     DebugUtils.log("ErrorUtils: report: ${e}, stack: ${trace}");
    try {
      if (!await enable) {
        return;
      }
      if (e is String) {
        Sentry.captureMessage(e, level: SentryLevel.error);
      }
      Sentry.captureException(
        e,
        stackTrace: trace ?? StackTrace.current,
      );
    } on Exception catch (e) {
      DebugUtils.log("[ERROR]error_utils:52 ${e} \n${StackTrace.current}");
    }
  }

  static void toast(
    dynamic e, {
    StackTrace? stacktrace,
  }) {
    if (!GlobalFuture.loadingInit.isCompleted) return;
    BotToast.showWidget(toastBuilder: (void Function() cancelFunc) {
      var builder = Builder(builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await RichClipboard.setData(RichClipboardData(text: e.toString() + "\n" + (stacktrace?.toString() ?? "")));
                    cancelFunc.call();
                  },
                  child: Text("copy"),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    cancelFunc();
                  },
                  child: Text("close"),
                ),
                TextButton(
                  onPressed: () {
                    BotToast.cleanAll();
                  },
                  child: Text("close all"),
                ),
              ],
            ),
            Text(
              e.toString(),
              style: context.bodyMedium.copyWith(
                color: context.cs.onError,
                backgroundColor: context.cs.error,
              ),
            )
          ],
        ).paddingSymmetric(horizontal: 12, vertical: 16).boxConstraints(maxWidth: 720).material(color: context.cs.primaryContainer).easyTap(
            onTap: () {
          print("error: ${e}");
          cancelFunc.call();
          FnBottomSheet.bottomSheet(SingleChildScrollView(
            child: Text(e.toString() + "\n" + (stacktrace?.toString() ?? "")),
          ));
        });
      });
      return builder.center();
    });
  }
}
