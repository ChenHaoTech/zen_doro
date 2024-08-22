import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/src/enums/key_code.dart';
import 'package:hotkey_manager/src/enums/key_modifier.dart';
import 'package:hotkey_manager/src/hotkey.dart';
import 'package:hotkey_manager/src/widgets/hotkey_virtual_view.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

class FnHotKeyRecorder extends StatefulWidget {
  const FnHotKeyRecorder({
    Key? key,
    this.initalHotKey,
    required this.onHotKeyRecorded,
    this.focusNode,
    this.needModify = true,
  }) : super(key: key);
  final HotKey? initalHotKey;
  final FocusNode? focusNode;
  final ValueChanged<HotKey?> onHotKeyRecorded;
  final bool needModify;

  @override
  State<FnHotKeyRecorder> createState() => _FnHotKeyRecorderState();
}

class _FnHotKeyRecorderState extends State<FnHotKeyRecorder> {
  HotKey? _hotKey;
  late final FocusNode foccusNode = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    if (widget.initalHotKey != null) {
      _hotKey = widget.initalHotKey!;
    }
    super.initState();
  }

  _handleRawKeyEvent(RawKeyEvent value) {
    if (value is! RawKeyDownEvent) return;
    // fix [leanflutter/hotkey_manager: This plugin allows Flutter desktop apps to defines system/inapp wide hotkey (i.e. shortcut). --- Leanflutter/hotkey_manager：该插件允许 Flutter 桌面应用程序定义系统/应用内范围的热键（即快捷方式）。](https://github.com/leanflutter/hotkey_manager/issues/19)
    if (value.character == null) return;

    if (value.isKeyPressed(LogicalKeyboardKey.escape) && !value.isMetaPressed && !value.isAltPressed && !value.isControlPressed) {
      foccusNode.unfocus();
      return;
    }
    if (widget.needModify && !value.isModifyPressed) {
      return;
    }

    KeyCode? keyCode;
    List<KeyModifier>? keyModifiers;

    keyCode = KeyCode.values.firstWhereOrNull(
      (kc) {
        if (!value.isKeyPressed(kc.logicalKey)) return false;
        KeyModifier? keyModifier = KeyModifierParser.fromLogicalKey(kc.logicalKey);

        if (keyModifier != null && value.data.isModifierPressed(keyModifier.modifierKey)) {
          return false;
        }

        return true;
      },
    );
    keyModifiers = KeyModifier.values.where((km) => value.data.isModifierPressed(km.modifierKey)).toList();

    if (keyCode != null) {
      _hotKey = HotKey(
        keyCode,
        modifiers: keyModifiers,
      );
      if (widget.initalHotKey != null) {
        _hotKey?.identifier = widget.initalHotKey!.identifier;
        _hotKey?.scope = widget.initalHotKey!.scope;
      }

      widget.onHotKeyRecorded(_hotKey!);
      foccusNode.unfocus();

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    late Widget child;
    if (_hotKey == null) {
      child = VirtualKeyView(
        keyLabel: '未绑定快捷键'.i18n,
      ).opacity(.4);
    } else {
      var view = HotKeyVirtualView(hotKey: _hotKey!);
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          view,
          SizedBox(height: 4, width: 4),
          Icon(
            Icons.close,
            size: 12,
          )
              .inkWell(onTap: () {
                _hotKey = null;
                widget.onHotKeyRecorded.call(null);
                foccusNode.unfocus();
                setState(() {});
              })
              .opacity(.4)
              .tooltip("删除".i18n),
        ],
      );
    }
    return child
        .paddingSymmetric(
          horizontal: 4,
        )
        .inkWell(onTap: () {
          foccusNode.requestFocus();
        })
        .focus(
            focusNode: foccusNode,
            onFocusChange: (focus) {
              if (focus) {
                this.log.dd(() => "add key listener");
                RawKeyboard.instance.addListener(_handleRawKeyEvent);
              } else {
                this.log.dd(() => "remove key listener");
                RawKeyboard.instance.removeListener(_handleRawKeyEvent);
              }
            })
        .onLifeCycle(onDispose: () {
          RawKeyboard.instance.removeListener(_handleRawKeyEvent);
        })
        .textFieldTapRegion(onTapOutside: (_) {
          RawKeyboard.instance.removeListener(_handleRawKeyEvent);
        });
  }
}
