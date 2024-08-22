import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/theme/padding_constants.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/component/setting/setting_checklist.dart';
import 'package:flutter_pasteboard/component/setting/setting_mics_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  SettingService get controller => SettingService.instance;
  Widget? _curNavigator = null;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildLeftNavigator().expand(flex: 1),
        _buildRightBody().expand(flex: 3),
      ],
    ).paddingSymmetric(horizontal: 24, vertical: 12).safeArea();
  }

  late final List<Widget> _navigators = [
    Text(
      "核心".i18n,
      style: context.titleLarge,
    ),
    Text(
      "快捷键".i18n,
      style: context.titleLarge,
    ),
  ];

  Widget _buildLeftNavigator() {
    List<Widget> childs = [];
    for (int i = 0; i < _navigators.length; i++) {
      Widget navigator = _navigators[i];
      var child = navigator.inkWell(onTap: () {
        setState(() {
          _curNavigator = navigator;
        });
      });
      childs.add(child);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: childs,
    );
  }

  Widget _buildRightBody() {
    return ListView(
      children: [
        Builder(builder: (context) {
          var navigator = _navigators[0];
          if (navigator == _curNavigator) Scrollable.ensureVisible(context);
          return navigator;
        }),
        SettingCheckList(
          title: '自动开始休息'.i18n,
          value: controller.autoRest.rx,
        ),
        SettingCheckList(
          title: '休息后自动启动番茄'.i18n,
          value: controller.autoFocus.rx,
        ),
        Divider(),
        PromodoEndSetWidget(),
        PromodoFlowSetWidget(controller: controller),
        gap24,
        Builder(builder: (context) {
          var navigator = _navigators[1];
          if (navigator == _curNavigator) Scrollable.ensureVisible(context);
          return navigator;
        }),
        ShortCutSetWidget().paddingSymmetric(horizontal: 4),
      ],
    ).easyTap(
      onTap: () => Focus.maybeOf(context)?.requestFocus(),
    );
  }
}
