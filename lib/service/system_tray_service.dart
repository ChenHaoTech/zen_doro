import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_pasteboard/misc/debounce.dart';
import 'package:flutter_pasteboard/misc/fnUrlUtils.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/screens/desktop/dash_board.dart';
import 'package:flutter_pasteboard/service/window_service.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get.dart';
import 'package:system_tray/system_tray.dart';
import 'package:universal_io/io.dart';

export './model/fn_state.dart';

class SystemTrayService extends GetxService {
  static SystemTrayService get instance => Get.touch(() => SystemTrayService());
  final SystemTray _systemTray = SystemTray();
  final RxString title = RxString('');

  @override
  void onInit() {
    super.onInit();
    fnassert(() => PlatformUtils.isDesktop);
    _initSystemTray();
    title.listen((p0) {
      _systemTray.setTitle(p0);
    });
  }

  Future _setContextMenu() async {
    final Menu menu = Menu();
    await menu.buildFrom([
      if (kDebugMode) MenuItemLabel(label: 'DEBUG', onClicked: (menuItem) => $windowService.requestWindowShow()),
      MenuItemLabel(label: '展示'.i18n + "  ", onClicked: (menuItem) => $windowService.requestWindowShow()),
      MenuItemLabel(label: '隐藏'.i18n, onClicked: (menuItem) => $windowService.requestWindowHide()),
      if (PlatformUtils.isDesktop)
        MenuItemCheckbox(
            label: $windowService.alwaysOnTop.justValue ? "取消置顶".i18n : "置顶".i18n,
            checked: false,
            onClicked: (menuItem) {
              var isTop = $windowService.alwaysOnTop.toggle();
              if (isTop.justValue) {
                $windowService.requestWindowShow();
              }
              DebounceUtils.debounce("_setContextMenu()", 1.seconds, () {
                _setContextMenu();
              });
            }),
      MenuSeparator(),
      MenuItemLabel(
          label: '😘反馈'.i18n,
          onClicked: (menuItem) {
            FnUriUtils.openUrl(FnConst.termsUrl);
          }),
      MenuItemLabel(
          label: '设置'.i18n,
          onClicked: (menuItem) async {
            await $windowService.requestWindowShow();
            await $windowService.setSize(dashboardSize);
            await routes.offAll(() => DashboardDesktop(
                  initialIdx: -1,
                ));
          }),
      MenuItemLabel(
          label: '统计'.i18n,
          onClicked: (menuItem) async {
            await $windowService.setSize(dashboardSize);
            await $windowService.center();
            await $windowService.requestWindowShow();
            await routes.offAll(() => DashboardDesktop(
                  initialIdx: 1,
                ));
          }),
      MenuSeparator(),
      MenuItemLabel(label: '退出'.i18n, onClicked: (menuItem) => exit(0)),
    ]);

    // set context menu
    await _systemTray.setContextMenu(menu);
  }

  Future<void> _initSystemTray() async {
    if (!PlatformUtils.isDesktop) return;
    String path = 'assets/app_icon.png';

    // We first init the systray menu
    await _systemTray.initSystemTray(
      iconPath: path,
    );
    _setContextMenu();
    _systemTray.registerSystemTrayEventHandler((eventName) {
      logger.dd(() => "eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? $windowService.requestWindowShow() : _systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? _systemTray.popUpContextMenu() : $windowService.requestWindowShow();
      }
    });
  }
}
