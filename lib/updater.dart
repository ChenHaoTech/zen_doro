import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fnUrlUtils.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

void tryUpdateDialog() async {
  await Future.delayed(1.seconds);
  var newestVersion = await FnConst.newestVersion;
  if (FnConst.innerVersion <= newestVersion) {
    FnDialog.showDefault(
        title: "更新".i18n,
        content: ListTile(
          title: Text("有新版本包需要下载".i18n),
          subtitle: debugWidget(() => Text("${FnConst.version}=>${newestVersion}").opacity(.3)),
        ).boxConstraints(maxWidth: 240),
        cancelTxt: "Not Now".i18n,
        confirmWidget: ElevatedButton(
            child: Text("去下载".i18n),
            onPressed: () {
              if (GetPlatform.isMacOS || GetPlatform.isIOS) {
                FnUriUtils.openUrl(FnConst.appstoreUrl);
              } else {
                FnUriUtils.openUrl(FnConst.homeUrl);
              }
              Get.back();
            }));
  } else {
    print("is newest: ${FnConst.innerVersion}>${newestVersion}");
  }
}
