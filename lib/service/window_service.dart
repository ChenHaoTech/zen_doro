import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

get promodoSize => _promodoSizeRx.value;
final _promodoSizeRx = Rx(Size(210 * 3, 350));
const dashboardSize = Size(1200, 800);

class WindowService extends GetxService with WindowListener {
  final alwaysOnTop = RxBool(false);
  final windowHide = RxBool(false);
  final windowFocus = RxBool(true);

  bool get _isDesk => PlatformUtils.isDesktop;
  Rx<Size> size = Rx(Size(420, 320));

  WindowOptions get windowOptions => WindowOptions(
        size: requestDashBoard ? dashboardSize : promodoSize,
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: true,
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: requestDashBoard ? true : false,
      );

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    windowFocus.value = true;
  }

  @override
  void onWindowClose() {
    windowFocus.value = false;
  }

  @override
  void onWindowBlur() {
    windowFocus.value = false;
  }

  @override
  void onInit() async {
    super.onInit();
    fnassert(() => _isDesk, "不是移动端怎么还会初始化");
    if (!_isDesk) return;
    await windowManager.ensureInitialized();
    if (kDebugMode) return;
    windowManager.waitUntilReadyToShow(windowOptions, () {
      windowManager.show();
    });
    windowManager.setMovable(true);
    windowManager.setResizable(true);
    windowManager.setVisibleOnAllWorkspaces(false);
    windowHide.listen((p0) {
      if (p0) {
        windowManager.hide();
      } else {
        requestWindowShow();
      }
    });
    // space_test();
    alwaysOnTop.listen((p0) async {
      windowManager.setAlwaysOnTop(p0);
      if (!p0 && await isFocus()) {
        windowHide.value = true;
      }
    });
    size.value = await windowManager.getSize();
    windowManager.addListener(this);
    this.log.dd(() => "window init end");
  }

  Future setWindowButtonVisibility(bool visibility) async {
    await windowManager.setTitleBarStyle(windowOptions.titleBarStyle!, windowButtonVisibility: visibility);
  }

  Future setSize(Size size, {bool animate = false}) async {
    if (!_isDesk) return;
    await windowManager.setSize(size, animate: animate);
  }

  Future center({bool animate = false}) async {
    if (!_isDesk) return;
    await windowManager.center(animate: animate);
  }

  @override
  void onWindowResized() async {
    if (!_isDesk) return;
    size.value = await windowManager.getSize();
  }

  Future<void> requestWindowHide() async {
    if (!_isDesk) return;
    await windowManager.hide();
  }

  Future<void> requestWindowShow({
    Function? needDoOnWindowFocus = null,
    bool? top,
  }) async {
    if (!_isDesk) return;
    windowManager.show();
    await windowManager.focus();
    if (needDoOnWindowFocus != null) {
      needDoOnWindowFocus.call();
    } else {
      // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      //   autoFocusOnWindowShow?.requestFocus();
      // });
    }
    if (top != null) {
      alwaysOnTop.justValue = top;
      await windowManager.setAlwaysOnTop(top);
    }
  }

  Future<bool> isFocus() async {
    if (!_isDesk) return true;
    return await windowManager.isFocused();
  }
}
