// ignore_for_file: non_constant_identifier_names

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/service/hotkey/hotkey_wrapper.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotKeySerice extends GetxService {
  late final HotKeyWrapper winActiveHotkey = HotKeyWrapper(
    hotKeyBinder: (isInit, lastHotKey, hotKey) async {
      this.log.dd(() => "update winActiveHotkey:${hotKey}");
      if (hotKey == null) {
        if (lastHotKey != null) {
          await hotKeyManager.unregister(lastHotKey);
        }
        return;
      }
      await hotKeyManager.unregister(hotKey);
      hotKeyManager.register(hotKey, keyDownHandler: (_) async {
        if (await $windowService.isFocus()) {
          await $windowService.requestWindowHide();
        } else {
          await $windowService.requestWindowShow();
        }
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          fixHotKeyBug();
        });
      });
      if (!isInit) {
        BotToast.showText(
          text: "修改快捷键为:%s".i18n.fill(
            [
              hotKey.toString(),
            ],
          ),
        );
      }
    },
    originKey: HotKey(
      KeyCode.keyP,
      modifiers: [
        KeyModifier.meta,
        KeyModifier.alt,
        KeyModifier.control,
        KeyModifier.shift,
      ],
      // Set hotkey scope (default is HotKeyScope.system)
      scope: HotKeyScope.system, // Set as inapp-wide hotkey.
    ),
    settingHolder: SettingService.instance.windowHotKey,
  );

  late final HotKeyWrapper winTopHotkey = HotKeyWrapper(
    hotKeyBinder: (isInit, lastHotKey, hotKey) async {
      this.log.dd(() => "update winTopHotKey:${hotKey}");
      if (hotKey == null) {
        if (lastHotKey != null) {
          await hotKeyManager.unregister(lastHotKey);
        }
        return;
      }
      await hotKeyManager.unregister(hotKey);
      hotKeyManager.register(hotKey, keyDownHandler: (_) async {
        $windowService.alwaysOnTop.toggle();
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          fixHotKeyBug();
        });
      });
      if (!isInit) {
        BotToast.showText(
          text: "修改快捷键为:%s".i18n.fill(
            [
              hotKey.toString(),
            ],
          ),
        );
      }
    },
    originKey: HotKey(
      KeyCode.keyP,
      modifiers: [
        KeyModifier.meta,
        KeyModifier.alt,
        KeyModifier.control,
      ],
      // Set hotkey scope (default is HotKeyScope.system)
      scope: HotKeyScope.system, // Set as inapp-wide hotkey.
    ),
    settingHolder: SettingService.instance.windowTopHotKey,
  );

  @override
  void onInit() {
    fnassert(() => PlatformUtils.isDesktop);
    super.onInit();
    _initKey();
  }

  void _initKey() async {
    await hotKeyManager.unregisterAll();
    await winActiveHotkey.init();
    this.log.dd(() => "init ${winActiveHotkey.hotkey} to bind window action");
    await winTopHotkey.init();
    this.log.dd(() => "init ${winTopHotkey.hotkey} to bind window top");
  }

  @override
  void onClose() async {
    await hotKeyManager.unregisterAll();
  }

  @override
  void onReady() {}

  void fixHotKeyBug() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // ignore: invalid_use_of_visible_for_testing_member
      RawKeyboard.instance.clearKeysPressed();
    });
  }
}
