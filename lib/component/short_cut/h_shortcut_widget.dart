import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/lifecycle/lifecycle_mixin.dart';
import 'package:flutter_pasteboard/component/short_cut/ShortProvider.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:ui_extension/ui_extension.dart';


// EasyShorcutsWidget 扩展 .shortcuts
extension EasyShorcutsWidgetExt on Widget {
  // .shortcuts

  Widget simpleShortcuts(
    Map<dynamic, void Function()> map, {
    FocusNode? focusNode,
    String? debug,
    KeyEventResult Function(FocusNode node, RawKeyEvent event)? onKey,
    bool isRoot = false,
  }) {
    Map<LogicalKeySet, void Function()> actualMap = {};
    // 遍历map, 如果key是LogicalKeySet, 直接加入actualMap,
    // 如果 key是FnAction, 加入 FnAction.keySet(前提是keySet不为空)

// 遍历原始map
    map.forEach((key, value) {
      // 检查key的类型
      if (key is LogicalKeySet) {
        // 如果key是LogicalKeySet类型，直接加入actualMap
        actualMap[key] = value;
      } else if (key is FnAction) {
        // 如果key是FnAction类型，检查keySet是否不为空
        if (key.keySet != null) {
          // 如果keySet不为空，加入actualMap
          actualMap[key.keySet!] = value;
        }
      } else {
        throw "不支持的类型";
      }
    });

    return FnShortcuts(
      focusNode: focusNode,
      map: actualMap,
      debug: debug,
      onKey: onKey,
      isRoot: isRoot,
      child: this,
    );
  }
}

class FnShortcuts extends StatefulWidget {
  final Widget child;
  final bool isRoot;
  final FocusNode? focusNode;
  final Map<LogicalKeySet, void Function()> map;
  final String? debug;
  final KeyEventResult Function(FocusNode node, RawKeyEvent event)? onKey;

  const FnShortcuts({
    super.key,
    required this.child,
    required this.map,
    this.onKey,
    this.focusNode,
    this.debug,
    this.isRoot = false,
  });

  @override
  State<FnShortcuts> createState() => _FnShortcutsState();
}

class _FnShortcutsState extends State<FnShortcuts> with LifecycleStatefulMixin {
  ShortcutRooterState? _wrapperState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.isRoot) {
      _wrapperState = ShortcutRooterState.maybeOf(context);
      if (widget.debug != null) {
        this.log.dd(() =>
            "[${widget.debug}] find ShortcutRooterState: ${_wrapperState}[${_wrapperState?.widget.debug}], key:${widget.onKey}, map:${widget.map}");
      }
      _tryClear();
      _tryInit();
    }
  }

  void _tryInit() {
    var onKey = widget.onKey;
    if (onKey != null) {
      var onKeys = _wrapperState?.onKeys;
      if (onKeys != null && !onKeys.contains(onKey)) {
        onKeys.add(onKey);
      }
    }
    _wrapperState?.update(
      (p0) {
        p0.addAll(widget.map);
        return p0;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tryClear();
  }

  void _tryClear() {
    _wrapperState?.onKeys.removeWhere((element) => element == widget.onKey);
    _wrapperState?.update((p0) {
      p0.removeWhere((key, value) => widget.map[key] != null && widget.map[key] == value);
      return p0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.map.isEmpty || _wrapperState != null) {
      if (widget.focusNode != null) {
        return widget.child.focus(focusNode: widget.focusNode);
      } else {
        return widget.child;
      }
    }
    _tryInit();
    var focusScope = FocusScope(
      debugLabel: "_FnShortcutsState",
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.isMetaPressed) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            // ignore: invalid_use_of_visible_for_testing_member
            RawKeyboard.instance.clearKeysPressed();
          });
        }
        var result = widget.onKey?.call(node, event);
        return result ?? KeyEventResult.ignored;
      },
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        shortcuts: Map.from(widget.map.map((key, value) => MapEntry(key, FunctionIntent(value)))),
        actions: <Type, Action<Intent>>{
          FunctionIntent: FunctionAction<FunctionIntent>(
            (FunctionIntent intent) => intent.callback.call(),
          ),
        },
        child: widget.child,
      ),
    );
    if (widget.isRoot) return ShortcutRooter(child: focusScope);
    return focusScope;
  }

  @override
  void whenHide() {
    _tryClear();
  }

  @override
  void whenShow() {
    _tryInit();
  }
}

class FunctionIntent extends Intent {
  final void Function() callback;

  FunctionIntent(this.callback);
}

class FunctionAction<T extends Intent> extends Action<T> {
  final void Function(T intent) consumer;

  FunctionAction(this.consumer);

  @override
  Object? invoke(T intent) {
    consumer.call(intent);
    return true;
  }
}