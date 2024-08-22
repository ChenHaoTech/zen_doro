import 'package:bot_toast/bot_toast.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/setting/setting_page_share.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/model/fn_state.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/misc/fn_check_chip.dart';

import 'package:flutter_pasteboard/component/short_cut/ShortProvider.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/fn_week_view.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/keyboard_widget.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/archive/stats_controller.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/widget/stats_card.dart';
import 'package:flutter_pasteboard/component/tag/tag_manager_widget.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:rich_clipboard/rich_clipboard.dart';
import 'package:ui_extension/ui_extension.dart';

import 'archive/fn_text_stats_view.dart';

class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  static bool get isShow {
    return Get.currentRoute == "/StatsPage";
  }

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

final RxBool _staticDebugMode = RxBool(false);

bool get staticDebugMode => _staticDebugMode.value;

class _StatsWidgetState extends State<StatsWidget> {
  StatsController get controller => StatsController.instance;

  @override
  void initState() {
    super.initState();
    _onInitAsync();
  }

  void _onInitAsync() async {
    var list = await controller.refreshList("init");
    if (list.isEmpty) {
      await controller.tryInitGuide();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var portal = Portal(
      child: Material(
        child: DefaultTabController(
          length: _tabBinding.length,
          child: Builder(builder: (context) {
            return Row(children: [
              // left filter
              _buildLeftCol(context).boxConstraints(
                maxWidth: 320,
              ),
              _buildRightBody().expand(),
            ]).simpleShortcuts({
              FnKeys.ctlTab: () {
                var controller = DefaultTabController.maybeOf(context);
                controller?.animateTo((controller.index + 1) % _tabBinding.length);
              },
              FnKeys.ctlshiftTab: () {
                var controller = DefaultTabController.maybeOf(context);
                controller?.animateTo((controller.index - 1) % _tabBinding.length);
              },
            });
          }),
        ),
      ).safeArea(),
    );
    return KeyboardData(
      keyboardWidget: statsShortWidgets(context),
      child: ShortcutRooter(
        shortBinder: {
          FnKeys.alt1: () {
            setState(() {
              var today = DateTime.now().onlyYmd();
              controller.startTime.value = today;
              controller.endTime.value = today.add(1.days);
              controller.refreshList();
            });
          },
          FnKeys.alt2: () {
            setState(() {
              var today = DateTime.now().onlyYmd();
              controller.startTime.value = today.subtract(2.days);
              controller.endTime.value = today.add(1.days);
              controller.refreshList();
            });
          },
          FnKeys.alt3: () {
            setState(() {
              var today = DateTime.now().onlyYmd();
              controller.startTime.value = today.firstWeekDay;
              controller.endTime.value = today.add(1.days);
              controller.refreshList();
            });
          },
          FnKeys.cmdShiftC: () => _copyAll(),
          if (kDebugMode) FnKeys.cmdShiftD: () => _staticDebugMode.toggle(),
          FnKeys.cmdN: () => controller.createNewOne(),
          FnKeys.cmdComma: () => showSettingDialog(),
          FnKeys.altS: () {
            FnDialog.show(TagSelectDialog(
              statsController: controller,
            ));
          },
        },
        child: portal,
        debug: "stats_widget",
      ),
    );
  }

  List<(/*title*/ Widget, /*body*/ Widget)> get _tabBinding => [
        // (
        //   Text("列表".i18n),
        //   FnDailyBook(
        //     key: UniqueKey(),
        //   ),
        // ),
        (
          Text("时序".i18n),
          FnWeekView(
            timeBlocks: controller.timeBlocks,
            startTime: controller.startTime.justValue,
            endTime: controller.endTime.justValue,
          )
        ),
        (
          Text("摘要".i18n),
          FnTextStatsView(
            key: UniqueKey(),
          )
        ),
      ];

  Widget _buildRightBody() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: FnStyle.appbarSize,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TabBar(
              labelColor: context.colorScheme.primary,
              dividerColor: context.colorScheme.primaryContainer,
              unselectedLabelColor: context.colorScheme.primary.withOpacity(.4),
              indicatorColor: context.colorScheme.primaryContainer,
              tabs: _tabBinding.mapToList(
                (e) => e.$1,
              ),
            )
                .tooltip(
                  FnKeys.ctlTab.toReadable(),
                )
                .expand(),
            FnPopUpMenu(
              configs: [
                // PopUpMenuConfig.textBtn("导出为excel".i18n, () {
                //   throw "未实现";
                // }),
                if (kDebugMode)
                  PopUpMenuConfig.textBtn("DEBUG".i18n + " ${FnKeys.cmdShiftD.toReadable()}", () async {
                    _staticDebugMode.toggle();
                  }),
                PopUpMenuConfig.textBtn("复制为纯文本".i18n + " ${FnKeys.cmdShiftC.toReadable()}", () async {
                  await _copyAll();
                }),
                if (kDebugMode)
                  PopUpMenuConfig.textBtn("删除全部", () {
                    setState(() {
                      var res = AppDatabase.get.delete(AppDatabase.get.timeBlockTb).go();
                      this.log.dd(() => "delete time block, res:${res}");
                    });
                  }),
                if (kAnyDebug)
                  PopUpMenuConfig.textBtn("DRIFT VIEW", () {
                    Get.to(DriftDbViewer(AppDatabase.get));
                  }),
              ],
              child: Icon(
                Icons.more_vert,
              ).opacity(.4),
            ),
            gap8,
          ],
        ).paddingOnly(
          top: 12,
        ),
      ),
      body: Builder(builder: (context) {
        return TabBarView(
          children: _tabBinding.mapToList(
            (e) => e.$2,
          ),
          physics: const NeverScrollableScrollPhysics(),
        );
      }),
    ).stack(supplier: (self) {
      return [
        self,
        Obx(() {
          var showGuideInfo = controller.showGuideInfo.value;
          if (!showGuideInfo) return emptyWidget;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "您完成的番茄钟会如上所示哦👆".i18n,
              ),
              Text(
                "我知道了",
                style: context.bodyMedium.copyWith(
                  color: context.primary,
                  decoration: TextDecoration.underline,
                ),
              ).inkWell(onTap: () => controller.markGuideEnd()),
            ],
          ).paddingOnly(left: 12, right: 12, top: 8, bottom: 8).material(elevation: 1).position(
                left: 24,
                bottom: 24,
              );
        }),
      ];
    });
  }

  Future<void> _copyAll() async {
    var allNotesInText = controller.timeBlocks.mapToList((i) => i.toMd()).join("\n");
    await RichClipboard.setData(RichClipboardData(text: allNotesInText));
    BotToast.showText(text: "已复制${controller.timeBlocks.length}个笔记内容");
    if (kDebugMode) FnDialog.showDefault(content: Text(allNotesInText), onConfirm: () {});
  }

  Widget _buildPromodoStatus() {
    TextStyle style = context.bodyMedium.copyWith(color: context.primary.withOpacity(.4));
    return Obx(() {
      switch ($zenService.state) {
        case PomodoroState.Rest:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                var left = $zenService.left.inMinutes.toString().padLeft(2, '0');
                var right = ($zenService.left.inSeconds % 60).toString().padLeft(2, '0');
                return Text(
                  "${left}:${right}",
                  style: style,
                );
              }),
              TextButton(
                  onPressed: () => $zenService.stopRest(),
                  child: Text(
                    "结束".i18n,
                  )),
            ],
          );
        case PomodoroState.Focus:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                var left = $zenService.left.inMinutes.toString().padLeft(2, '0');
                var right = ($zenService.left.inSeconds % 60).toString().padLeft(2, '0');
                return Text(
                  "${left}:${right}",
                  style: style,
                );
              }),
              TextButton(
                onPressed: () => $zenService.pause(),
                child: Text(
                  "暂停".i18n,
                ),
              ),
              TextButton(
                onPressed: () => $zenService.stopFocus(),
                child: Text(
                  "结束".i18n,
                  style: style,
                ),
              )
            ],
          );
        case PomodoroState.FocusPause:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                var left = $zenService.left.inMinutes.toString().padLeft(2, '0');
                var right = ($zenService.left.inSeconds % 60).toString().padLeft(2, '0');
                return Text(
                  "${left}:${right}",
                  style: style,
                );
              }),
              TextButton(
                child: Text("重新开始".i18n),
                onPressed: () => $zenService.resume(),
              )
            ],
          );
        case PomodoroState.Edit:
        case PomodoroState.FocusTimeEnd:
        case PomodoroState.Stop:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(builder: (_) {
                var minus = TimeRuleController.find.ensureFocus().minus;
                var left = minus.padLeft(2, "0");
                var right = "00";
                return Text(
                  "${left}:${right}",
                  style: style,
                );
              }),
              TextButton(
                child: Text(
                  "开始".i18n,
                ),
                onPressed: () async {
                  await $zenService.startFocus();
                },
              )
            ],
          );
        default:
          return emptyWidget;
      }
    });
  }

  Widget _buildLeftCol(BuildContext context) {
    return ListView(
      children: [
        Obx(
          () => CalendarDatePicker2(
              value: [controller.startTime.value, controller.endTime.value],
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
              ),
              onValueChanged: (List<DateTime?> datas) {
                var start = datas.getNullable(0);
                var end = datas.getNullable(1);
                if (start == null || end == null) {
                  return;
                }
                setState(() {
                  controller.startTime.value = start;
                  controller.endTime.value = end;
                  controller.refreshList("start_end_time");
                });
              }).material(),
        ),
        _buildFilterExt(),
        Obx(() {
          if (!staticDebugMode) return emptyWidget;
          var content = "${Get.currentRoute}\n" + controller.timeBlocks.mapToList((e) => e.uuid).join("\n");
          return Text(content).inkWell(onTap: () {
            Get.to(DriftDbViewer(AppDatabase.get));
          });
        }),
        gap4,
        Builder(builder: (context) {
          final RxBool _showOverlay = false.obs;
          final Rx<String> _filterStr = "".obs;
          return Row(
            children: [
              Text(
                "标签筛选".i18n,
                style: context.labelLarge,
              ).paddingSymmetric(
                horizontal: 12,
              ),
              Spacer(),
              // portalTarget(_showOverlay, _filterStr),
              // gap12,
              Icon(
                Icons.filter_alt_outlined,
                size: 16,
              ).opacity(.4).inkWell(onTap: () {
                FnDialog.show(TagSelectDialog(
                  statsController: controller,
                ));
              }).tooltip(FnKeys.altS.toReadable()),
              gap12,
            ],
          );
        }),
        gap4,
        SingleChildScrollView(
          child: Obx(() {
            return Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              runSpacing: 2,
              alignment: WrapAlignment.start,
              children: controller.tags.mapToList(
                (e) => FnPopUpMenu(
                  configs: [
                    PopUpMenuConfig.textBtn("删除".i18n, () {
                      FnDialog.showDefault(
                          title: "删除".i18n,
                          content: Text("删除 %s ?".i18n.fill([e.value])),
                          onConfirm: () {
                            TagStore.find.delete(e.id);
                            Get.back();
                          });
                    }),
                    PopUpMenuConfig.textBtn("重命名".i18n, () {
                      String value = e.value;
                      FnDialog.showDefault(
                          autoFocusConfirm: false,
                          title: "标签重命名".i18n,
                          content: TextField(
                            controller: TextEditingController(text: value),
                            autofocus: true,
                            onChanged: (val) => value = val,
                            onSubmitted: (val) {
                              TagStore.find.save(e.copyWith(value: value));
                              Get.back();
                            },
                          ),
                          onConfirm: () {
                            TagStore.find.save(e.copyWith(value: value));
                            Get.back();
                          });
                    }),
                  ],
                  child: Chip(
                    label: Text(e.value),
                    onDeleted: () {
                      controller.tags.removeWhere((i) => i.id == e.id);
                    },
                    deleteButtonTooltipMessage: "取消".i18n,
                  ),
                ),
              ),
            );
          }),
        ).paddingOnly(left: 12),
        gap4,
        Divider(),
        gap12,
        StatsCard(),
        gap12,
        // TagStatsCard(),
        gap12,
        // EmotionStatsCard(),
      ],
    );
  }

  PortalTarget portalTarget(RxBool _showOverlay, Rx<String> _filterStr) {
    return PortalTarget(
      anchor: Aligned(
        follower: Alignment.topLeft,
        target: Alignment.topRight,
      ),
      portalFollower: Obx(() {
        if (!_showOverlay.value) return emptyWidget;
        final match = TagStore.find.all.where((p0) => p0.value.contains(_filterStr.value));
        var focusNode = FocusNode();
        bool isOpenMenu = false;
        return Focus(
          focusNode: FocusNode()
            ..addListener(() {
              if (!focusNode.hasFocus && !isOpenMenu) {
                _showOverlay.value = false;
              }
            }),
          child: ListView(
            shrinkWrap: true,
            children: [
              TextField(
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: "搜索过滤标签".i18n,
                  border: InputBorder.none,
                  suffixIcon: FnPopUpMenu(
                    onOpened: () => isOpenMenu = true,
                    onCanceled: () => isOpenMenu = false,
                    onSelected: (i) => isOpenMenu = false,
                    configs: [
                      PopUpMenuConfig.textBtn("全选".i18n, () {
                        controller.tags.value = [...controller.tags.justValue, ...match].unique();
                      }),
                      PopUpMenuConfig.textBtn("全不选".i18n, () {
                        controller.tags.removeWhereExt((p0) => match.contains(p0));
                      }),
                    ],
                    child: Icon(
                      Icons.more_vert,
                    ),
                  ),
                  isDense: true,
                ),
                controller: TextEditingController(text: _filterStr.justValue),
                onChanged: (val) => _filterStr.value = val,
                autofocus: true,
                maxLines: 1,
              ),
              gap12,
              TextFieldTapRegion(
                child: Obx(() {
                  var selected = controller.tags;
                  return Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: match.mapToList((e) => Obx(() {
                          if (selected.contains(e)) {
                            return Chip(
                              label: Text(e.value),
                              deleteButtonTooltipMessage: "取消".i18n,
                              onDeleted: () {
                                controller.tags.removeWhere((i) => i.id == e.id);
                              },
                            );
                          } else {
                            return Chip(
                              label: Text(e.value),
                            ).inkWell(onTap: () => controller.tags.add(e));
                          }
                        })),
                  );
                }),
              ),
            ],
          ).paddingAll(8).card().simpleShortcuts({
            FnKeys.esc: () => _showOverlay.value = false,
            FnKeys.enter: () => controller.tags.toggle(match.firstOrNull),
          }),
        );
      }).boxConstraints(
        maxHeight: Get.height * .5,
        maxWidth: 400,
      ),
      child: Icon(
        size: 16,
        Icons.filter_alt_outlined,
      ).inkWell(onTap: () => _showOverlay.toggle()),
    );
  }

  Widget _buildFilterExt() {
    return Obx(() {
      return Row(
        children: [
          gap12,
          gap12,
        ],
      );
    });
  }
}
