import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/setting/src/tiles/settings_tile.dart';
import 'package:flutter_pasteboard/model/model_share.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/component/short_cut/hotkey_recorder.dart';
import 'package:flutter_pasteboard/component/setting/setting_function.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';

class ShortCutSetWidget extends StatelessWidget {
  const ShortCutSetWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          return SettingsTile(
            title: Text("显示/隐藏窗口".i18n),
            description: Text("通过快捷键切换窗口的显示或隐藏状态".i18n),
            trailing: FnHotKeyRecorder(
              initalHotKey: $hotKeySerice.winActiveHotkey.hotkey,
              onHotKeyRecorded: (HotKey? value) {
                if (value == null) {
                  $hotKeySerice.winActiveHotkey.hotkey = value;
                  return;
                }
                if (value.modifiers.isEmptyOrNull) {
                  return;
                }
                $hotKeySerice.winActiveHotkey.hotkey = value;
              },
            ),
          );
        }),
        Builder(builder: (context) {
          return SettingsTile(
              title: Text("[取消]置顶窗口".i18n),
              description: Text("通过快捷键取消窗口的置顶状态".i18n),
              trailing: FnHotKeyRecorder(
                initalHotKey: $hotKeySerice.winTopHotkey.hotkey,
                onHotKeyRecorded: (HotKey? value) {
                  if (value == null) {
                    $hotKeySerice.winTopHotkey.hotkey = value;
                    return;
                  }
                  if (value.modifiers.isEmptyOrNull) {
                    return;
                  }
                  $hotKeySerice.winTopHotkey.hotkey = value;
                },
              ));
        }),
      ],
    );
  }
}

class PromodoEndSetWidget extends StatelessWidget {
  PromodoEndSetWidget({
    super.key,
  });

  final SettingService controller = SettingService.instance;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("番茄完成后行为".i18n),
      trailing: buildDropdownMenu(
        controller.promodoEndAction.value,
        [
          (
            "弹出窗口".i18n,
            FocusEndAction.POP.code,
          ),
          (
            "仅置顶".i18n,
            FocusEndAction.POP_TOP.code,
          ),
        ],
        (value) => controller.promodoEndAction.value = value,
      ),
    );
  }
}

class PromodoFlowSetWidget extends StatelessWidget {
  PromodoFlowSetWidget({
    super.key,
    required this.controller,
  });

  final SettingService controller;
  late final Rx<List<String>> ruleRx = Rx($parseRule(controller.promodoProfile.value));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("番茄工作流".i18n),
      isThreeLine: true,
      subtitle: _buildBuilder(),
    );
  }

  Builder _buildBuilder() {
    return Builder(builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Obx(() {
          //   var rule = ruleRx.value;
          //   if (rule.isEmptyOrNull) {
          //     return Text(
          //       "不可识别".i18n,
          //       style: context.bodyMedium.copyWith(
          //         color: context.cs.error,
          //       ),
          //     );
          //   }
          //   return Wrap(
          //     spacing: 4,
          //     runSpacing: 2,
          //     children: rule.mapToList((i) {
          //       if (i.startsWith(TimeRuleController.restChar)) {
          //         return Text(
          //           "休息%s".i18n.fill([i.remove(TimeRuleController.restChar)]),
          //           style: context.bodyMedium.copyWith(
          //             color: context.bodyMedium.color!.withOpacity(.4),
          //           ),
          //         );
          //       } else if (i.startsWith(TimeRuleController.promodoChar)) {
          //         return Text(
          //           "专注%s".i18n.fill([i.remove(TimeRuleController.promodoChar)]),
          //           style: context.bodyMedium.copyWith(
          //             color: context.primary,
          //           ),
          //         );
          //       }
          //       return Text(
          //         "不可识别".i18n,
          //         style: context.bodyMedium.copyWith(
          //           color: context.cs.error,
          //         ),
          //       );
          //     }),
          //   );
          // }),
        ],
      );
    });
  }
}
