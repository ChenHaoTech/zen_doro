import 'dart:async';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_pasteboard/misc/env_param_utils.dart';
import 'package:flutter_pasteboard/misc/fnUrlUtils.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

abstract class PurchaseUtils {
  static final String pro_entitlement_id = "pro";
  static Completer _completer = Completer();

  static Future get future => _completer.future;

  static Future markLogin(String userId) async {
    //todo web 可能要自己兼容
    if (PlatformUtils.isWeb) return;
    await future;
    LogInResult result = await Purchases.logIn(userId);
    logger.i("init Purchases userId: ${result}");
  }

  static Future<void> $initPlatformState() async {
    if (PlatformUtils.isWeb) return;
    fnassert(() => !_completer.isCompleted);
    await Purchases.setDebugLogsEnabled(kDebugMode);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      // configuration = PurchasesConfiguration(<revenuecat_project_google_api_key>);
      logger.e("暂时 安卓还没有配置付费墙");
    } else if (Platform.isIOS | Platform.isMacOS) {
      configuration = PurchasesConfiguration(EnvParamUtils.IOS_API_KEY);
    }
    if (configuration != null) {
      await Purchases.configure(configuration);
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        logger.i("Purchases customer info update: ${customerInfo}");
      });
      _completer.complete();
    }
  }

  static Future<bool> checkPro() async {
    var isMe = (await AccountService.init).email == "chenhaoaixuexi@gmail.com";
    if (isMe) return true;
    //todo web 可能要自己兼容
    if (PlatformUtils.isWeb) return false;
    await future;
    CustomerInfo data = await Purchases.getCustomerInfo();
    return data.entitlements.all[pro_entitlement_id]?.isActive == true;
  }

  static Future showPurchasePage() async {
    await future;
    if (PlatformUtils.isMobile) {
      await RevenueCatUI.presentPaywall();
    } else {
      FnNotification.toast("暂时只支持移动端购买".i18n);
      FnUriUtils.openUrl(FnConst.purchanceUrl);
    }
  }
}
