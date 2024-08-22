import 'dart:async';
import 'dart:convert';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:universal_io/io.dart';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/download_utils.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class FnConst {
  static String packageName = "flutter_pasteboard";

  static const privateUrl = "https://doc-hosting.flycricket.io/zendoro-s-privacy-policy/2e2b1136-ebee-46af-889b-91056ab1ee3e/privacy";
  static const termsUrl = "https://doc-hosting.flycricket.io/zendoro-s-terms-conditions/8cc83e71-1d8c-498d-b4f7-b450e5c2261a/terms";
  static String reportUrl = "https://t2bj3wxiaa.feishu.cn/share/base/form/shrcnG4NY19N0IfVRkyuh0iWm7f";
  static String homeUrl = "https://t2bj3wxiaa.feishu.cn/wiki/HhL9wbQd6iqTGOkOpMkcg68bnTh";
  static String appstoreUrl = "https://apps.apple.com/cn/app/zendoro/id6504215286?mt=12";
  static String purchanceUrl = "https://t2bj3wxiaa.feishu.cn/wiki/HhL9wbQd6iqTGOkOpMkcg68bnTh";
  static List<FeedBackInfo> feedbackInfos = [];

  static String get appName => packageInfo.appName;
  static late final PackageInfo packageInfo;
  static final Completer<int> _newestVersion = Completer();

  static Future<int> get newestVersion => _newestVersion.future;

  static String get version => "${packageInfo.version}+${packageInfo.buildNumber}";

  static int get innerVersion => int.tryParse(packageInfo.buildNumber) ?? 0;
}

Future $initConst() async {
  var hiveKey = "app_version_from_remote";
  var log = LoggerWrapper.build("fnconst");
  DownloadUtils.startDownload(
      requestUpdate: true,
      url: "https://gitee.com/chen-hao91/publix_resource/raw/main/const.json",
      fileName: "const.json",
      onComplete: (path) async {
        var file = File(path);
        var result = file.readAsStringSync();
        if (DebugFlag.download) log.dd(() => "result:${result}");
        var map = json.decode(result);

        var feedbackInfoFromRemote = map["feedbackInfos"];
        if (feedbackInfoFromRemote != null) {
          FnConst.feedbackInfos.clear();
          FnConst.feedbackInfos.addAll((feedbackInfoFromRemote as List<dynamic>).mapToList((e) => FeedBackInfo.fromJson(e)));
          logger.i("fetch feedbackinfo:${feedbackInfoFromRemote},${FnConst.feedbackInfos}");
        }

        String key = "";
        if (GetPlatform.isWindows) {
          key = "window";
        } else if (GetPlatform.isMacOS) {
          key = "mac";
        } else if (GetPlatform.isIOS) {
          key = "ios";
        } else if (GetPlatform.isAndroid) {
          key = "android";
        }
        if (key.isEmptyOrNull) return;
        var version = map["lastVersion"][key];
        if (version == null) {
          return;
        }
        FnConst._newestVersion.complete(int.tryParse(version) ?? 0);

        FnConst.homeUrl = map["homeUrl"] ?? FnConst.homeUrl;
        FnConst.purchanceUrl = map["purchanceUrl"] ?? FnConst.purchanceUrl;
        FnConst.reportUrl = map["reportUrl"] ?? FnConst.homeUrl;
      });
}

bool get requestDashBoard => appCache.get("requestDashBoard", defaultValue: 1) == 1;

set requestDashBoard(bool value) => appCache.put("requestDashBoard", 1);
