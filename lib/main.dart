import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/audio/audio_mix_widget.dart';
import 'package:flutter_pasteboard/component/setting/setting_page_share.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_function.dart';
import 'package:flutter_pasteboard/global_future.dart';
import 'package:flutter_pasteboard/misc/HotKeyService.dart';
import 'package:flutter_pasteboard/misc/debug_function.dart';
import 'package:flutter_pasteboard/misc/env_param_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/guide/guide_data.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/misc/log/logger_view.dart';
import 'package:flutter_pasteboard/misc/purchase_utils.dart';
import 'package:flutter_pasteboard/screens/DebugPage.dart';
import 'package:flutter_pasteboard/screens/desktop/dash_board.dart';
import 'package:flutter_pasteboard/screens/mobile/auth/auth.dart';
import 'package:flutter_pasteboard/screens/mobile/promodo_home_mobile.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:flutter_pasteboard/service/sync/supabase/supabase_service.dart';
import 'package:flutter_pasteboard/service/system_tray_service.dart';
import 'package:flutter_pasteboard/service/window_service.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/updater.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:i18n_extension/i18n_extension.dart' as i18n;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_io/io.dart';

import 'screens/main_wrapper.dart';

late String appUuid;
late final Box appCache;
late final LazyBox lazyAppCache;

Future<Box> initFlutter([String? subDir]) async {
  WidgetsFlutterBinding.ensureInitialized();
  String path = applicationDocumentsDirectory.path;
  Hive.init(p.join(path, subDir));
  appCache = await Hive.openBox("appCache");
  lazyAppCache = await Hive.openLazyBox("lazyAppCache");
  var key = "app_uuid";
  appUuid = appCache.get(key, defaultValue: newUuid()) as String;
  appCache.put(key, appUuid);
  print("appUuid: ${appUuid}");

  // if (kDebugMode) await appCache.put("_innerVersion", appCache.get("_innerVersion", defaultValue: 0) + 1);

  return appCache;
}

void _handlei18n() {
  i18n.Translations.missingTranslationCallback = (Object? key, String locale) {
    //todo 本地化todo
    // logger.e("没有 ${locale}:${key} 的翻译");
  };
  i18n.Translations.missingKeyCallback = (Object? key, String locale) {
    // logger.e("没有 ${locale}:${key} 的翻译");
  };
}

Future _initSupabse() async {
  if (kDebugMode) return;
  RealtimeClientOptions? option = null;
  if (kAnyDebug) {
    option = RealtimeClientOptions(
      eventsPerSecond: 10,
      logLevel: RealtimeLogLevel.debug,
    );
  }
  if (kDebugMode) {
    print("_SUPABASE_URL: ${EnvParamUtils.SUPABASE_URL},_SUPABASE_ANON_KEY: ${EnvParamUtils.SUPABASE_ANON_KEY}");
  }
  if (EnvParamUtils.SUPABASE_URL.isEmptyOrNull || EnvParamUtils.SUPABASE_ANON_KEY.isEmptyOrNull) {
    logger.e("no _SUPABASE_URL or _SUPABASE_ANON_KEY,");
  }
  await Supabase.initialize(
    url: EnvParamUtils.SUPABASE_URL.trim(),
    anonKey: EnvParamUtils.SUPABASE_ANON_KEY.trim(),
    authOptions: FlutterAuthClientOptions(
      autoRefreshToken: !kDebugMode,
      localStorage: SharedPreferencesLocalStorage(persistSessionKey: 'supabase-zendoro'),
    ),
    realtimeClientOptions: option ?? RealtimeClientOptions(),
    debug: kDebugMode,
  );
  Get.put(SupabaseService());
  GlobalFuture.initSupbase.tryComplete();
}

Future<void> main(List<String> args) async {
  EnvParamUtils.$assert();
  await SentryFlutter.init(
    (options) {
      options.dsn = EnvParamUtils.SENTRY_DSN;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      // Note: Profiling alpha is available for iOS and macOS since SDK version 7.12.0
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => mainInner(args),
  );

  // you can also configure SENTRY_DSN, SENTRY_RELEASE, SENTRY_DIST, and
  // SENTRY_ENVIRONMENT via Dart environment variable (--dart-define)
}

void mainInner(List<String> args) async {
  var start = DateTime.now();
  // 动画效果
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    Get.reset();
    if (PlatformUtils.isDesktop) {
      await hotKeyManager.unregisterAll();
    }
  }

  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
  FnActions.initKeys();
  FnConst.packageInfo = await PackageInfo.fromPlatform();
  if (PlatformUtils.isWeb) {
    //todo 目录咋搞?
    applicationDocumentsDirectory = Directory("./");
  } else {
    applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
  }
  var box = await initFlutter(kDebugMode ? "debug" : null);
  var appdabase = AppDatabase.register(AppDatabase.$getCurrentDataBaseKey(box));
  PurchaseUtils.$initPlatformState();
  await _initSupabse();
  $handleError();
  _handlei18n();
  //设置为 true 将导致焦点发生变化时发生大量日志记录。
  // debugFocusChanges = true;
  await $initConst();
  UserAccountState userAccountState = UserAccountState.init;
  watch("account", () async {
    await GlobalFuture.initSupbase.future;
    var accountService = Get.put(AccountService(SupabaseService.tryFind!));
    GlobalFuture.initAccount.tryComplete();
    userAccountState = await accountService.state;
  });
  FnAudioService.instance;
  GuideService.instance.tryInitGuide();
  if (PlatformUtils.isDesktop) {
    _runAppOnDesktop(userAccountState);
  } else {
    _runAppOnMobile(userAccountState);
  }
  if (kAnyDebug) {
    var millSeconds = DateTime.now().difference(start).inMilliseconds;
    runOnNextFrame(() => BotToast.showText(text: "start cost ${millSeconds} ms"));
  }

  tryUpdateDialog();
}

Future watch(String key, FutureOr Function() callback) async {
  var start = DateTime.now();
  await callback.call();
  var millSeconds = DateTime.now().difference(start).inMilliseconds;
  print("cost[${key}]: ${millSeconds} ms");
}

void _runAppOnMobile(UserAccountState userAccountState) {
  runApp(MainAppWrapper(
    homeWidget: Builder(builder: (context) {
      var isDesktop = context.isDesktop;
      return userAccountState == UserAccountState.logout
          ? SignUp()
          : Builder(builder: (context) {
              if (isDesktop) {
                return DashboardDesktop();
              } else {
                return PomodoroHomeMobile();
              }
            });
    }),
    decorator: (context, child) {
      var originTheme = Theme.of(context);
      var appBarTheme = originTheme.appBarTheme;
      var colorScheme = originTheme.colorScheme;
      return Theme(
        data: originTheme.copyWith(
            appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: colorScheme.background,
        )),
        child: child,
      );
    },
  ));
}

void _runAppOnDesktop(UserAccountState userAccountState) {
  var isLogout = userAccountState == UserAccountState.logout;
  SystemTrayService.instance;
  Get.put(HotKeySerice());
  Get.put(WindowService());
  int idx = 0;
  var values = FlexScheme.values.toList();
  runApp(MainAppWrapper(
    homeWidget: Builder(builder: (context) {
      var isMobile = context.isMobile;
      if (isLogout) {
        return SignUp();
      }
      return requestDashBoard ? (isMobile ? PomodoroHomeMobile() : DashboardDesktop()) : DashboardDesktop();
    }),
    decorator: (_, child) => child.simpleShortcuts({
      FnActions.CloseCurrentWindow: () => $windowService.requestWindowHide(),
      FnActions.OpenMixAdjustmentWindow: () => showAuioMixWidget(),
      FnActions.AddTimeBlock: () => showTimeBlockCardEditor(),
      FnActions.OpenSettingsPage: () async {
        showSettingDialog();
      },
      FnActions.ToggleMute: () {
        FnAudioService.instance.toggleMute();
      },
      FnKeys.cmdBack: () => Get.back(),

      // FnKeys.cmdAltBackspace: () => TimeRuleController.instance.reset(),
      // FnActions.ToggleMiniWindow: () async {
      //   if (!requestDashBoard) {
      //     await $windowService.setSize(dashboardSize);
      //     await $windowService.center();
      //     await $windowService.setWindowButtonVisibility(true);
      //     await routes.offAll(() => DashboardDesktop());
      //   } else {
      //     await $windowService.setSize(promodoSize);
      //     await $windowService.setWindowButtonVisibility(false);
      //     await $windowService.center();
      //     await routes.offAll(() => PromodoEdit());
      //   }
      // },
      if (kAnyDebug) FnKeys.f12: () => routes.to(() => $LoggerView()),
      if (kAnyDebug) FnKeys.f11: () => routes.to(() => DebugPage()),
    }),
  ));
}

late Directory applicationDocumentsDirectory;
