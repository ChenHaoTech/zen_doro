import 'package:bot_toast/bot_toast.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/network_utils.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/component/fn_getx/fn_obx_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:rich_clipboard/rich_clipboard.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:ui_extension/ui_extension.dart';

import 'constants.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Sign In', actions: [
        TextButton(
            onPressed: () {
              routes.offHome();
            },
            child: Text("跳过".i18n)),
        if (kAnyDebug)
          FnPopUpMenu(configs: [
            PopUpMenuConfig.textBtn("skip", () {
              AccountService.setUserAccountState(UserAccountState.init);
              routes.offHome();
            }),
          ])
      ]),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          FnObxValue(() {
            var supaEmailAuth = SupaEmailAuth(
              onSignInComplete: (response) {
                this.log.dd(() => "onSignInComplete: response: ${response}");
                _toHome();
              },
              onSignUpComplete: (response) {
                this.log.dd(() => "onSignUpComplete: response: ${response}");
                _toHome();
              },
              onError: (error) {
                var msg = "登入出现问题请稍后再试".i18n;
                if (error is AuthException) {
                  var message2 = (error as AuthException).message;
                  if (message2.contains("Exception")) {
                    this.log.e("$error", error);
                  } else {
                    msg = message2;
                  }
                } else {
                  this.log.e("$error", error);
                }
                BotToast.showText(text: msg);
              },
              metadataFields: [
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: 'Username',
                  key: 'username',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter something';
                    }
                    return null;
                  },
                ),
              ],
            );
            if (NetWorkUtils.instance.offline) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "offline" + (kAnyDebug ? "${NetWorkUtils.instance.connectResult.join(",")}" : ""),
                    style: context.bodyMedium.copyWith(color: context.cs.onError),
                  ).paddingAll(8).center().material(color: context.cs.error),
                  gap12,
                  IgnorePointer(
                    child: supaEmailAuth.opacity(.6),
                  ),
                ],
              );
            }
            return supaEmailAuth;
          }, [
            NetWorkUtils.instance.connectResult,
          ]),
          // const Divider(),
          // optionText,
          spacer,
          // if (kDebugMode) Text("Getx.sigleKeys: ${GetInstance.singlKey.join(",")}"),
          Builder(builder: (context) {
            var infos = FnConst.feedbackInfos;
            if (infos.isEmptyOrNull) return emptyWidget;
            return Text(
              'Support'.i18n,
              style: context.linkStyle.withColor(context.defaultTextColor),
            ).inkWell(onTap: () {
              FnBottomSheet.bottomSheet(ListView(
                children: infos.mapToList((e) => ListTile(
                      onTap: () {
                        RichClipboard.setData(RichClipboardData(text: e.value));
                        BotToast.showText(text: "copy \"${e.value}\"");
                      },
                      title: Text(e.label),
                      subtitle: Text(e.value),
                      trailing: Icon(Icons.paste_outlined),
                    )),
              ));
            });
          }).opacity(.7).center(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     //todo 如果是 安卓配置的 apple 登入, 那么需要特殊配置
          //     _buildIconBtn(
          //       backgroundColor: Colors.white,
          //       iconColor: Colors.black,
          //       onTap: () async {
          //         AuthResponse res = await FnAuthUtils.signInWithApple();
          //         // Account Service 是否有监听?有的话怎么处理?
          //         this.log.dd(() => "res:${res.session}");
          //         _toHome();
          //       },
          //       iconData: FontAwesome.apple_brand,
          //     ),
          //     // todo google 登入需要配置
          //     // 如何打通或者绑定多个登入途径的账号
          //     // SupaSocialsAuth(
          //     //   socialProviders: [
          //     //     // ios 或者 macos 才会有 apple登入
          //     //     OAuthProvider.google,
          //     //     OAuthProvider.apple,
          //     //   ],
          //     //   redirectUrl: kIsWeb ? null : 'better-menox://login-callback/',
          //     //   socialButtonVariant: SocialButtonVariant.icon,
          //     //   onSuccess: (session) {
          //     //     Get.engine.addPostFrameCallback((du) => Get.offAllNamed(Routes.HOME));
          //     //   },
          //     // ),
          //   ],
          // ),
          // todo 短信验证码登入
        ],
      ),
    );
  }

  void _toHome() async {
    var cancelFunc = BotToast.showLoading();
    var service = await AccountService.init;
    var result = await (service.loginSuccessFuture).timeout(3.seconds, onTimeout: () async {
      cancelFunc.call();
      BotToast.showText(text: "登入超时,请稍后重试".i18n);
      return false;
    });
    if (result) {
      cancelFunc.call();
      routes.offHome();
    }
  }

  Widget _buildIconBtn({
    required Color backgroundColor,
    required Color iconColor,
    required Function() onTap,
    required IconData iconData,
  }) {
    return Material(
      shape: const CircleBorder(),
      elevation: 2,
      color: backgroundColor,
      child: InkResponse(
        radius: 24,
        onTap: onTap,
        child: SizedBox(
          height: 48,
          width: 48,
          child: Icon(
            iconData,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
