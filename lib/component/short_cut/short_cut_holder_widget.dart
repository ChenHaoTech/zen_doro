import 'package:flutter/cupertino.dart';
import 'package:flutter_pasteboard/misc/function.dart';

class ShortcutHolder extends StatefulWidget {
  final Widget Function() builder;

  const ShortcutHolder(this.builder, {super.key});

  @override
  State<ShortcutHolder> createState() => ShortcutHolderState();
}

class ShortcutHolderState extends State<ShortcutHolder> {
  static ShortcutHolderState? _state;
  late ShortcutDisplayState? _displayState;
  late List<Disposer> disposers = [];

  @override
  Widget build(BuildContext context) {
    var originThis = _state;
    _state = this;

    var origin = ShortcutDisplayState._curState;
    ShortcutDisplayState._curState = _displayState;
    var child = widget.builder.call();
    ShortcutDisplayState._curState = origin;

    _state = originThis;
    return child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _displayState = ShortcutDisplayState.maybeOf(context);
  }

  @override
  void dispose() {
    super.dispose();
    disposers.forEach((e) => e.dispose());
  }
}

class ShortcutDisplay extends StatefulWidget {
  final Widget child;

  const ShortcutDisplay({super.key, required this.child});

  @override
  State<ShortcutDisplay> createState() => ShortcutDisplayState();
}

class ShortcutDisplayState extends State<ShortcutDisplay> {
  final Map<LogicalKeySet, ShortCutInfo> shortcutInfos = {};
  static ShortcutDisplayState? _curState;

  Disposer addShortcutInfos(Map<LogicalKeySet, ShortCutInfo> maps) {
    shortcutInfos.addAll(maps);
    return Disposer(() => shortcutInfos.removeWhere((key, value) => maps[key] != null && maps[key] == value));
  }

  static ShortcutDisplayState get curState {
    fnassert(() => _curState != null);
    return _curState!;
  }

  static ShortcutDisplayState? maybeOf(BuildContext context) {
    var state = context.findRootAncestorStateOfType<ShortcutDisplayState>();
    return state;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ShortCutInfo {
  String desc;

  ShortCutInfo(this.desc);
}

extension ShortcutInfoExt on LogicalKeySet {
  LogicalKeySet desc(String value) {
    var dispose = ShortcutDisplayState.curState.addShortcutInfos({
      this: ShortCutInfo(value),
    });
    ShortcutHolderState._state!.disposers.add(dispose);
    return this;
  }
}
