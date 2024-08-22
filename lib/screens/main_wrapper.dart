import 'package:bot_toast/bot_toast.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_pasteboard/component/lifecycle/life_navigator_observer.dart';
import 'package:flutter_pasteboard/global_future.dart';
import 'package:flutter_pasteboard/misc/env_param_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/screens/binding/bindings.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:ui_extension/ui_extension.dart';
import 'package:wiredash/wiredash.dart';

import '../theme/theme.dart';

class MainAppWrapper extends StatelessWidget {
  final Widget homeWidget;
  final Widget Function(BuildContext context, Widget child)? decorator;

  const MainAppWrapper({
    super.key,
    required this.homeWidget,
    this.decorator,
  });

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit(); //1.
    return DevicePreview(
      enabled: !kReleaseMode && PlatformUtils.isDesktop,
      builder: (BuildContext context) {
        return _buildInner(context, botToastBuilder);
      },
    );
  }

  Wiredash _buildInner(BuildContext context, TransitionBuilder botToastBuilder) {
    return Wiredash(
        projectId: EnvParamUtils.WIREDASH_ID,
        secret: EnvParamUtils.WIREDASH_SECRET,
        child: GetMaterialApp(
            initialBinding: HomeBinding(),
            debugShowCheckedModeBanner: false,
            useInheritedMediaQuery: true,
            locale: DevicePreview.locale(context),
            scaffoldMessengerKey: FnNotification.key,
            fallbackLocale: FnLocalUtils.fallback,
            // locale: FnLocalUtils.local,
            home: I18n(
              initialLocale: FnLocalUtils.supportLocals[0],
              child: homeWidget,
            ),
            //todo 是不是可以删除
            supportedLocales: FnLocalUtils.supportLocals,
            theme: FnTheme.lightTheme,
            darkTheme: FnTheme.darkTheme,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            navigatorObservers: [
              BotToastNavigatorObserver(),
              LifeNavigatorObserver(),
            ],
            builder: (BuildContext context, Widget? child) {
              var $child = botToastBuilder(context, child?.focus());
              GlobalFuture.loadingInit.tryComplete();
              $child = I18n(
                initialLocale: FnLocalUtils.supportLocals[0],
                child: ResponsiveBreakpoints.builder(
                  child: $child,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 500, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                  ],
                ),
              );
              return DevicePreview.appBuilder.call(context, Portal(child: decorator?.call(context, $child) ?? $child));
            }));
  }
}
