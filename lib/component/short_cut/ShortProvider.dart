import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';

class ShortcutRooter extends StatefulWidget {
  final Map<LogicalKeySet, void Function()>? shortBinder;
  final Widget child;
  final String? debug;

  const ShortcutRooter({
    super.key,
    this.shortBinder,
    required this.child,
    this.debug,
  });

  @override
  State<ShortcutRooter> createState() => ShortcutRooterState();
}

class ShortcutRooterState extends State<ShortcutRooter> {
  late Map<LogicalKeySet, void Function()> shortBinder = widget.shortBinder ?? {};
  late final List<KeyEventResult Function(FocusNode node, RawKeyEvent event)> onKeys = [];

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.isMetaPressed) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            // ignore: invalid_use_of_visible_for_testing_member
            RawKeyboard.instance.clearKeysPressed();
          });
        }
        var result = onKeys.mapToList((i) => i.call(node, event)).where((e) => e != KeyEventResult.ignored).firstOrNull;
        return result ?? KeyEventResult.ignored;
      },
      child: FocusableActionDetector(
        shortcuts: Map.from(shortBinder.map((key, value) => MapEntry(key, FunctionIntent(value)))),
        actions: <Type, Action<Intent>>{
          FunctionIntent: FunctionAction<FunctionIntent>(
            (FunctionIntent intent) => intent.callback.call(),
          ),
        },
        child: widget.child,
      ),
    );
  }

  static ShortcutRooterState? maybeOf(BuildContext context) {
    var state = context.findRootAncestorStateOfType<ShortcutRooterState>();
    return state;
  }

  bool _dirty = false;

  void update(Map<LogicalKeySet, void Function()> Function(Map<LogicalKeySet, void Function()>) mapper, [String? debug]) {
    // var origin = this.shortBinder.keys.toString();
    var _shortBinder = this.shortBinder;
    var origin = _shortBinder.entries.toSet();
    this.shortBinder = mapper.call(_shortBinder);
    var now = this.shortBinder.entries.toSet();
    if (!origin.deepEqual(now)) {
      _dirty = true;
      runOnNextFrame(() {
        if (!mounted || !_dirty) {
          return;
        }
        setState(() {});
      });
    }
  }
}
