import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/service/pomodoro_controller.dart';
import 'package:get/get.dart';

import 'misc/HotKeyService.dart';
import 'service/window_service.dart';

export "package:flutter_pasteboard/service/pomodoro_controller.dart";

// final ClipboardVM clipboardVM = Get.find<ClipboardVM>();
WindowService get $windowService {
  assert(PlatformUtils.isDesktop);
  return Get.find<WindowService>();
}

HotKeySerice get $hotKeySerice {
  assert(PlatformUtils.isDesktop);
  return Get.find<HotKeySerice>();
}

late final PomodoroController $zenService = Get.touch(() => PomodoroController());
