import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingCheckList extends StatelessWidget {
  final String title;
  final RxObjectMixin<bool> value;
  final Function(bool value)? onChanged;

  const SettingCheckList({Key? key, required this.title, required this.value, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Obx(() {
        return Checkbox(
          visualDensity: VisualDensity(horizontal: 0),
          value: value.value,
          onChanged: (v) {
            value.value = v ?? false;
            onChanged?.call(v ?? false);
          },
        );
      }),
      onTap: () => value.value = !value.value,
    );
  }
}