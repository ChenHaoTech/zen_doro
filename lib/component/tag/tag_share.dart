import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/fn_color_picker.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

void requestEditTag(Tag tag) async {
  final Rx<Tag> rx = Rx(tag);
  var editingController = TextEditingController(text: rx.justValue.value);
  await FnDialog.showDefault(
      title: "更新标签".i18n,
      content: Column(
        children: [
          Row(
            children: [
              gap12,
              Text("选择颜色".i18n),
              Spacer(),
              Obx(() => Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rx.value.color,
                    ),
                  )),
              gap12,
            ],
          ).inkWell(onTap: () {
            openColorPicker(
              selectedColor: rx.justValue.color,
              onSubmit: (c) => rx.value = rx.justValue.copyWith(colorValue: c?.value),
            );
          }),
          gap12,
          TextField(
            autofocus: true,
            controller: editingController,
          ),
        ],
      ),
      autoFocusConfirm: false,
      onConfirm: () {
        if (editingController.text.isEmpty) {
          FnNotification.toast("标签名不可以为空".i18n);
          return;
        }
        TagStore.find.touch(
          rx.justValue.copyWith(value: editingController.text),
        );
        Get.back();
      });
}
