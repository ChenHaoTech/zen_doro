import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/archive/stats_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

class TagSelectDialog extends StatelessWidget {
  final StatsController? statsController;

  TagSelectDialog({
    super.key,
    this.statsController,
  });

  final RxString _searchKey = RxString("");
  final RxBool _manager = RxBool(false);
  final _searchFocusNode = FocusNode();
  List<Tag> _result = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(Get.width * .2),
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearch().action({
              DismissIntent: SimpleCallbackAction<DismissIntent>(() {
                Get.back();
              }),
            }).simpleShortcuts({
              LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
                _searchFocusNode.nextFocus();
                _searchFocusNode.nextFocus();
              }
            }),
            Obx(() {
              var all = TagStore.find.all.whereToList((i) => i.value.fzfMath(_searchKey.value));
              _result = all;
              return ListView(
                shrinkWrap: true,
                children: all.mapToList(
                  (i) => _buildTagRow(i),
                ),
              ).simpleShortcuts({
                FnKeys.esc: () => Get.back(),
              });
            }).expand(),
          ],
        ),
      ).simpleShortcuts({
        FnActions.FocusSettingsSearch: () => _searchFocusNode.requestFocus(),
        FnKeys.cmdA: () => _selectAll(),
        FnKeys.cmdShiftA: () => _unSelectAll(),
      }),
    );
  }

  TextField _buildSearch() {
    return TextField(
      decoration: InputDecoration(
          hintText: "输入要搜索的标签关键字, 支持拼音搜索".i18n,
          suffixIcon: FnPopUpMenu(
            configs: [
              PopUpMenuConfig(Obx(() {
                return Text(_manager.value ? "退出管理".i18n : "管理".i18n);
              }), () {
                _manager.toggle();
              }),
              if (statsController != null)
                PopUpMenuConfig.textBtn("全选".i18n + " ${FnKeys.cmdA.toReadable()}", () {
                  _selectAll();
                }),
              if (statsController != null)
                PopUpMenuConfig.textBtn("全不选".i18n + " ${FnKeys.cmdShiftA.toReadable()}", () {
                  _unSelectAll();
                }),
            ],
            child: Icon(Icons.more_vert),
          ).focus(
            skipTraversal: true,
          )),
      focusNode: _searchFocusNode..requestFocus(),
      onChanged: (val) => _searchKey.value = val,
    );
  }

  void _unSelectAll() {
    statsController!.tags.removeWhere((e) => _result.contains(e));
  }

  void _selectAll() {
    var tags = statsController!.tags;
    var whereToList = _result.whereToList((e) => !tags.contains(e));
    statsController!.tags.addAll(whereToList);
  }

  Widget _buildTagRow(Tag tag) {
    var controller = statsController;
    return Obx(() {
      if (_manager.value == true || controller == null) {
        return ListTile(
          title: Row(
            children: [
              Text(tag.value.toString()),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.color_lens_rounded)),
              Builder(builder: (context) {
                return IconButton(
                    onPressed: () => TagStore.find.delete(tag.id),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: context.cs.error,
                    ));
              })
            ],
          ),
        );
      } else {
        return Obx(
          () => CheckboxListTile(
            title: Row(
              children: [
                Text(tag.value.toString()),
              ],
            ),
            value: controller.tags.contains(tag),
            onChanged: (bool? value) {
              controller.tags.toggle(tag);
            },
          ).inkWell(onTap: () => controller.tags.toggle(tag)),
        );
      }
    });
  }
}
