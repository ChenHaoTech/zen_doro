import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/component/short_cut/hotkey_virtual_view.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/_fn_week_short_cut.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';

class KeyBoardWidget extends StatelessWidget {
  const KeyBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var datas = KeyboardData.of(context);
    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("跳转到现在".i18n),
            Spacer(),
            ShortcutVitualView(
              keySet: FnWeekViewKeys.focusNow,
            ),
          ],
        ),
        Text(
          "缩放".i18n,
          style: context.settingSubTitle,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("快捷缩放 1.5".i18n),
            Spacer(),
            ShortcutVitualView(
              keySet: FnKeys.shift1,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("快捷缩放 1.0".i18n),
            Spacer(),
            ShortcutVitualView(
              keySet: FnKeys.shift2,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("快捷缩放 0.6".i18n),
            Spacer(),
            ShortcutVitualView(
              keySet: FnKeys.shift3,
            ),
          ],
        ),
        Text(
          "快捷添加".i18n,
          style: context.settingSubTitle,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("添加休息".i18n),
            Spacer(),
            ShortcutVitualView(
              keySet: LogicalKeySet(LogicalKeyboardKey.control),
              appned: "click",
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("网格添加".i18n),
            Spacer(),
            ShortcutVitualView(
              keySet: LogicalKeySet(LogicalKeyboardKey.shift),
              appned: "click",
            ),
          ],
        ),
        // if (datas != null) ...datas.keyboardWidget,
        // ...otherShortsWidget(context),
      ],
    );
  }
}

class KeyboardData extends InheritedWidget {
  final List<Widget> keyboardWidget;

  const KeyboardData({super.key, required Widget child, required this.keyboardWidget}) : super(child: child);

  static KeyboardData? of(BuildContext context) {
    final KeyboardData? result = context.dependOnInheritedWidgetOfExactType<KeyboardData>();
    return result;
  }

  @override
  bool updateShouldNotify(KeyboardData old) {
    return old.keyboardWidget == this.keyboardWidget;
  }
}

List<Widget> statsShortWidgets(BuildContext context) => [
      Text(
        "快捷选择".i18n,
        style: context.settingSubTitle,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("选中今日".i18n),
          Spacer(),
          ShortcutVitualView(
            keySet: FnKeys.alt1,
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("选中近3天".i18n),
          Spacer(),
          ShortcutVitualView(
            keySet: FnKeys.alt2,
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("选中本周".i18n),
          Spacer(),
          ShortcutVitualView(
            keySet: FnKeys.alt3,
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("过滤标签".i18n),
          Spacer(),
          ShortcutVitualView(
            keySet: FnKeys.altS,
          ),
        ],
      ),
    ];

List<Widget> otherShortsWidget(BuildContext context) => [
      Text(
        "MISC".i18n,
        style: context.settingSubTitle,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("展示本页快捷键".i18n),
          Spacer(),
          ShortcutVitualView(
            keySet: FnKeys.cmdAltComma,
          ),
        ],
      ),
      // Row(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Text("跳转设置".i18n),
      //     Spacer(),
      //     ShortcutVitualView(
      //       keySet: FnKeys.cmdComma,
      //     ),
      //   ],
      // ),
      // Row(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Text("切换mini窗口".i18n),
      //     Spacer(),
      //     ShortcutVitualView(
      //       keySet: FnKeys.cmdI,
      //     ),
      //   ],
      // ),
    ];
