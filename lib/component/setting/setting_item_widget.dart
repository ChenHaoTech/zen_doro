import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/fn_getx/fn_obx_widget.dart';
import 'package:flutter_pasteboard/component/setting/flutter_settings_ui.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class SettingItemWidget extends AbstractSettingsTile {
  final String settingKey;
  final String title;
  final String? description;
  final SettingType type;
  final IconData? icon;
  final FocusNode? focusNode;

  const SettingItemWidget({
    super.key,
    this.icon,
    required this.settingKey,
    required this.title,
    this.description,
    required this.type,
    this.focusNode,
  });

  SettingService get service => SettingService.instance;

  @override
  Widget build(BuildContext context) {
    return SearchSettingSection(searchKeys: [
      title,
      if (description != null) description!,
      settingKey,
    ], child: buildTile());
  }

  SettingHolder get holder => SettingService.instance.values[settingKey]!;

  Widget buildTile() {
    switch (type) {
      case SettingType.num:
        fnassert(() => holder.justValue is int);
        return SettingsTile(
          title: buildTitle(),
          description: _buildDesc(),
          leading: icon == null ? null : Icon(icon),
          trailing: TextField(
            focusNode: focusNode,
            controller: TextEditingController(text: holder.justValue.toString()),
            decoration: InputDecoration(
              hintText: holder.justValue.toString(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.singleLineFormatter,
            ],
            onChanged: (val) {
              var num = int.tryParse(val);
              if (num != null) {
                holder.value = num;
              }
            },
            // 其他 TextField 配置...
          ).intrinsicWidth().boxConstraints(minWidth: 48),
        );
      case SettingType.double:
        fnassert(() => holder.justValue is double);
        return SettingsTile(
          title: buildTitle(),
          description: _buildDesc(),
          leading: icon == null ? null : Icon(icon),
          trailing: TextField(
            focusNode: focusNode,
            controller: TextEditingController(text: holder.justValue.toString()),
            decoration: InputDecoration(
              hintText: holder.justValue.toString(),
            ),
            inputFormatters: [
              // 限制小数点后最多2位
              DecimalTextInputFormatter(decimalRange: 2),
              FilteringTextInputFormatter.singleLineFormatter,
            ],
            // 其他 TextField 配置...
            onChanged: (val) {
              var num = double.tryParse(val);
              if (num != null) {
                holder.value = num;
              }
            },
          ).intrinsicWidth().boxConstraints(minWidth: 48),
        );
      case SettingType.shortcut:
      // 根据需要自定义 shortcut 类型的 UI 组件
      // ...
      case SettingType.bool:
        fnassert(() => holder.justValue is bool);
        return Obx(() => SettingsTile.switchTile(
              title: buildTitle(),
              description: _buildDesc(),
              leading: icon == null ? null : Icon(icon),
              onToggle: (bool value) {
                holder.value = value;
              },
              onPressed: (_) => holder.value = !holder.value,
              initialValue: holder.value,
            ));
      case SettingType.custom:
      case SettingType.unknow:
      default:
        return Container(); // 对未知类型不做任何显示
    }
  }

  Widget? _buildDesc() => description != null ? Obx(() => Text(description!.fill([holder.value]))) : null;

  Widget buildTitle() => Obx(() => Text(title.fill([holder.value])));
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == oldValue.text) {
      return newValue;
    }

    final newText = newValue.text;
    if (!newText.contains('.')) {
      return newValue;
    }

    final parts = newText.split('.');
    if (parts.length - 1 > decimalRange) {
      return oldValue;
    }

    return newValue;
  }
}

mixin SettingCustomeWidget {
  Widget buildForPomodoroEndAction() {
    return Text("buildFor");
  }
}

// todo 实现递归
class SearchSettingSection extends AbstractSettingsSection {
  const SearchSettingSection({
    required this.child,
    this.searchKeys = const [],
    super.key,
  });

  final List<String> searchKeys;

  final Widget child;

  static SearchSettingSection? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<SearchSettingSection>();
  }

  @override
  Widget build(BuildContext context) {
    return FnObxValue(() {
      var searchKey = SettingController.find.searchKey.justValue;
      if (searchKey.isEmpty || searchKeys.any((e) => e.fzfMath(searchKey))) {
        return child;
      }
      return emptyWidget;
    }, [SettingController.find.searchKey]);
  }
}

class SettingController extends GetxController {
  final RxString searchKey = RxString("");

  static SettingController get find => Get.find();
}

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingController());
  }
}
