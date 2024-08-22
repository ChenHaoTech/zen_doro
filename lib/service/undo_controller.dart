import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class FnUndoController extends GetxController {
  static FnUndoController get find => Get.find();
  late final RxList<(String, Function)> _undoActions = RxList();

  List<(String, Function)> get undoActions => _undoActions;
  ScaffoldFeatureController? _lastController;

  @override
  void onInit() {
    super.onInit();
  }

  void undo() {
    var lastOrNull = _undoActions.lastOrNull;
    lastOrNull?.$2.call();
    _undoActions.remove(lastOrNull);
  }

  Disposer _bindKey() {
    var hotKey = HotKey(KeyCode.keyZ,
        modifiers: [
          GetPlatform.isMacOS ? KeyModifier.meta : KeyModifier.control,
        ],
        scope: HotKeyScope.inapp);
    hotKeyManager.register(hotKey, keyDownHandler: (_) {
      undo();
    });
    return Disposer(() => hotKeyManager.unregister(hotKey));
  }

  void showUndo({
    required String promopt,
    required void Function() onUndo,
    BuildContext? context,
    bool persistent = false,
  }) async {
    try {
      _lastController?.close();
    } catch (e) {}
    late ScaffoldFeatureController? controller;
    var disposor = _bindKey();
    var _onUndo = () {
      onUndo.call();
      try {
        controller?.close.call();
        disposor.dispose();
      } catch (e) {}
    };
    var unit = (promopt, _onUndo);
    _undoActions.add(unit);
    var duration = Duration(seconds: 3);
    controller = FnNotification.showTextSnackBar(
      context: context,
      text: promopt,
      action: (PlatformUtils.isMobile ? "Cancel".i18n : "${FnModifyString.adptiveMeta} Z", _onUndo),
      duration: duration,
    );
    _lastController = controller;
    if (!persistent) {
      await controller?.closed;
      _undoActions.remove(unit);
      disposor.dispose();
    }
  }
}
