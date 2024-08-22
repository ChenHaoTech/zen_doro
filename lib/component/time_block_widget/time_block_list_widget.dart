import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/tag/tag_share.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_card.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_function.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/mobile/timeblock/timeblock_edit_mobile.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ui_extension/ui_extension.dart';

class TimeBlockTimeLine extends StatefulWidget {
  final List<TimeBlock> tbs;
  final DateTime minTime;
  final DateTime maxTime;
  final bool showDayBar;

  const TimeBlockTimeLine({
    super.key,
    required this.tbs,
    required this.minTime,
    required this.maxTime,
    this.showDayBar = false,
  });

  @override
  State<TimeBlockTimeLine> createState() => TimeBlockTimeLineState();
}

class TimeBlockTimeLineState extends State<TimeBlockTimeLine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
          length: tag2Tbs.length,
          child: Column(
            children: [
              if (kDebugMode) Text("${_minTime()} ${_maxTime()}"),
              gap8,
              Row(
                children: [
                  TabBar(
                    // indicatorPadding: EdgeInsets.only(left: 30, right: 30),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: context.cs.secondaryContainer,
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    splashBorderRadius: BorderRadius.circular(50),
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    // indicator: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.redAccent),
                    tabs: tags
                        .mapToList(
                          (e) {
                            var tag = TagStore.find.id2tag[e];
                            var child = Text(tag?.value.fnmap((val) => "#${val}") ?? e).paddingSymmetric(horizontal: 8);
                            if (tag != null) {
                              child = child.onContextTap(() {
                                requestEditTag(tag);
                              });
                            }
                            var tab = Tab(
                              height: 32,
                              child: child,
                            );
                            return tab;
                          },
                        )
                        .whereNotNull()
                        .toList(),
                  ).expand(),
                  // FnPopUpMenu(
                  //   configs: [
                  //     PopUpMenuConfig.textBtn("txt", () {}),
                  //   ],
                  //   child: Icon(Icons.menu_open).paddingSymmetric(horizontal: 4),
                  // ),
                  gap12,
                ],
              ).boxConstraints(
                maxHeight: 32,
              ),
              gap4,
              TabBarView(children: tags.mapToList((e) => _buildTimeBlockLine(tag2Tbs[e] ?? []))).expand(),
              gap4,
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTimeBlockCardEditor();
        },
        tooltip: '新建专注块'.i18n + " ${FnActions.AddTimeBlock.keySet?.toReadable() ?? ""}",
        child: const Icon(Icons.add),
      ),
    );
  }

  late final List<TimeBlock> allList = widget.tbs;

  Color get indicatorColor => context.cs.tertiaryContainer;

  Color get lineColor => context.cs.primaryContainer.withOpacity(.2);

  Color get onIndicatorColor => context.cs.onTertiaryContainer;
  final Map<String, RxBool> _dirtys = {};

  Widget _buildTimeBlockLine(List<TimeBlock> timeblocks) {
    var list = timeblocks;
    list.sort((a, b) => a.startTime!.compareTo(b.startTime!));
    List<Widget> children = [];
    for (int i = 0; i < list.length; i++) {
      var e = list[i];
      fnassert(() => e.startTime != null, e);
      var last = list.getNullable(i - 1);
      if (last == null) {
        var startTime = e.startTime;
        if (widget.showDayBar) children.add(_buildTitle(startTime));
        if (e.startTime != _minTime()) {
          children.add(_buildAddLine(
            isFirst: true,
            maxTime: e.startTime!,
            minTime: _minTime(),
          ));
        }
      } else {
        if (!last.startTime!.isAtSameDayAs(e.startTime!)) {
          var dateTime = e.startTime;
          if (widget.showDayBar) children.add(_buildTitle(dateTime));
        }

        var findNextFreeTime = manager.findFreeTime(last.progressEndTime!, e.startTime!, 1.minutes);
        if (findNextFreeTime.isNotEmpty) {
          // if (e.startTime!.difference(last.endTime ?? _maxTime()).inMinutes >= 1) {
          for (var ti in findNextFreeTime) {
            Widget addLine = _buildAddLine(
                    maxTime: ti.end,
                    minTime: ti
                        .start) /*.ignorePointer().inkWell(
                  onTap: () => DebugUtils.log(
                      "time_block_list_widget:143: ${last.maxEndTime}, ${e.startTime} ${findNextFreeTime}\n ${manager.freeTimes} \n${StackTrace.current}"),
                )*/
                ;
            children.add(addLine.paddingSymmetric(vertical: 4));
          }
        }
      }
      final RxBool _edit = _dirtys.putIfAbsent(e.uuid, () => RxBool(false));
      var tbLine = TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: e.startTime == e.startTime!.onlyYmd(),
          afterLineStyle: LineStyle(color: lineColor),
          beforeLineStyle: LineStyle(color: lineColor),
          indicatorStyle: _buildIndicator(e),
          endChild: Obx(() {
            return TimeBlockCard(
              readOnly: PlatformUtils.isMobile,
              initEdit: _edit.value,
              key: UniqueKey(),
              onEditStateChange: (val) {
                _edit.value = val;
              },
              timeBlock: e,
              onSubmit: (tb) {
                $zenService.updateTimeBlock(tb, needSave: true);
              },
              onDelete: (tb) {
                $zenService.remove(tb);
              },
            ).paddingSymmetric(horizontal: 8, vertical: 4).inkWell(onTap: () {
              _updateTb(e);
            }, onSecondaryTapUp: (TapUpDetails detail) async {
              showPopUpMenu(context, detail, [
                (Text("Edit".i18n), () => _edit.trigger(true)),
                (
                  Text(
                    "Delete",
                    style: context.bodyMedium.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                  () => $zenService.remove(e)
                ),
                if (kDebugMode) (Text("Mobile Edit".i18n), () => _updateTb(e)),
              ]);
            });
          }));
      children.add(tbLine);
    }
    children.add(_buildAddLine(
      isLast: true,
      maxTime: FnDateUtils.min(_maxTime(), DateTime.now()),
      minTime: list.lastOrNull?.progressEndTime ?? _minTime(),
    ));

    // 底部空白
    children.add(SizedBox(
      height: Get.height / 4,
    ));

    return ListView(
      shrinkWrap: true,
      children: children,
    );
  }

  Widget _buildTitle(DateTime? startTime) {
    DebugUtils.log("time_block_list_widget:226:${widget.showDayBar} \n${StackTrace.current}");
    return ListTile(
      title: Text(
        FnDateUtils.humanReadable(startTime!.onlyYmd()),
        style: context.titleLarge,
      ),
    ).material(color: context.cs.tertiaryContainer.withOpacity(.6));
  }

  void _updateTb(TimeBlock e) {
    FnBottomSheet.bottomSheet(TimeBlockEditorMobile(
      onSubmit: (tb) {
        $zenService.updateTimeBlock(tb);
        Get.back();
      },
      onCancel: () => Get.back(),
      onDelete: (tb) {
        $zenService.remove(tb);
        Get.back();
      },
      tb: e,
    ));
  }

  final indicatorWidget = 4.0;

  IndicatorStyle _buildIndicator(TimeBlock tb) {
    return IndicatorStyle(width: 0);
    return IndicatorStyle(
        width: indicatorWidget,
        height: 80 * clampDouble((tb.progressSeconds / 60 / 25), .2, 2),
        indicator: Container(
          color: tb.isRest ? context.restColor : (tb.color?.withLightness(.4) ?? context.pomodoroContainerColor),
        ));
  }

  final Map<String, Rx<TimeBlockType?>> _editMap = {};

  Widget _buildAddLineMobile({
    bool isFirst = false,
    bool isLast = false,
    required DateTime minTime,
    required DateTime maxTime,
  }) {
    void _requestUpdate(bool isRest) {
      FnBottomSheet.bottomSheet(TimeBlockEditorMobile(
        onSubmit: (tb) {
          var newTb = tb.correctEndTime();
          $zenService.updateTimeBlock(newTb);
          Get.back();
        },
        onCancel: () => Get.back(),
        onDelete: (tb) {
          $zenService.remove(tb);
          Get.back();
        },
        tb: !isRest
            ? TimeBlock.emptyFocus(
                startTime: minTime,
                endTime: minTime.add(SettingService.instance.defaultFocusMinus.value.minutes),
                minutes: SettingService.instance.defaultFocusMinus.value,
              )
            : TimeBlock.emptyCountDownRest(
                startTime: minTime,
                endTime: minTime.add(SettingService.instance.defaultRestMinus.value.minutes),
                minutes: SettingService.instance.defaultRestMinus.value,
              ),
      ));
    }

    final height = 28.0;
    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      afterLineStyle: LineStyle(color: lineColor),
      beforeLineStyle: LineStyle(color: lineColor),
      indicatorStyle: _buildAddLineIndicator(height),
      endChild: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            gap12,
            _buildAddLineRow(maxTime, minTime).expand(),
            Builder(builder: (context) {
              return FnPopUpMenu(
                configs: [
                  PopUpMenuConfig.textBtn("新建休息块".i18n, () {
                    _requestUpdate(true);
                  }, style: context.bodyLarge.withColor(context.restColor)),
                  PopUpMenuConfig.textBtn("新建专注块".i18n, () {
                    _requestUpdate(false);
                  }),
                ],
                child: Icon(Icons.keyboard_arrow_down).opacity(.3),
              );
            }),
            gap12,
          ],
        ).center(),
      ).material(elevation: 4),
    ).inkWell(onTap: () {
      _requestUpdate(false);
    });
  }

  IndicatorStyle _buildAddLineIndicator(double height) {
    return IndicatorStyle(
      drawGap: true,
      indicatorXY: 0,
      height: height,
      width: indicatorWidget,
      indicator: Container(
        color: lineColor,
      ),
    );
  }

  Widget _buildAddLine({
    bool isFirst = false,
    bool isLast = false,
    required DateTime minTime,
    required DateTime maxTime,
  }) {
    minTime = minTime.isBefore(maxTime) ? minTime : maxTime;
    maxTime = minTime.isAfter(maxTime) ? minTime : maxTime;
    if (maxTime.difference(minTime).inSeconds < 60) return emptyWidget;
    var key = "${minTime}_${maxTime}";
    final _edit = _editMap.putIfAbsent(key, () => Rx(null));
    fnassert(() => minTime.isBefore(maxTime) || minTime == maxTime, [minTime, maxTime]);
    final height = 28.0;
    if (context.isMobile) {
      return _buildAddLineMobile(
        minTime: minTime,
        maxTime: maxTime,
        isFirst: isFirst,
        isLast: isLast,
      );
    }
    var addLine = TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      afterLineStyle: LineStyle(color: lineColor),
      beforeLineStyle: LineStyle(color: lineColor),
      indicatorStyle: _buildAddLineIndicator(height),
      endChild: Obx(
        () {
          var type = _edit.value;
          var uuid = newUuid();
          var sizedBox = SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                gap12,
                _buildAddLineRow(maxTime, minTime).expand(),
                Builder(builder: (context) {
                  return FnPopUpMenu(
                    configs: [
                      PopUpMenuConfig.textBtn("新建休息块".i18n, () {
                        _edit.trigger(TimeBlockType.REST);
                      }, style: context.bodyLarge.withColor(context.restColor)),
                      PopUpMenuConfig.textBtn("新建专注块".i18n, () {
                        _edit.trigger(TimeBlockType.FOCUS);
                      }),
                    ],
                    child: Icon(Icons.keyboard_arrow_down).opacity(.3),
                  );
                }),
                gap12,
              ],
            ).center(),
          ).material(elevation: 4);
          if (type != null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                sizedBox,
                TimeBlockCard(
                  key: ValueKey(uuid),
                  initEdit: true,
                  timeBlock: _edit.value == TimeBlockType.FOCUS
                      ? TimeBlock.emptyFocus(
                          startTime: minTime,
                          endTime: minTime.add(SettingService.instance.defaultFocusMinus.value.minutes),
                          minutes: SettingService.instance.defaultFocusMinus.value,
                        ).copyWith(uuid: uuid)
                      : TimeBlock.emptyCountDownRest(
                          startTime: minTime,
                          endTime: minTime.add(SettingService.instance.defaultRestMinus.value.minutes),
                          minutes: SettingService.instance.defaultRestMinus.value,
                        ).copyWith(uuid: uuid),
                  onSubmit: (val) {
                    _edit.value = null;
                    $zenService.updateTimeBlock(val);
                  },
                  onDelete: (tb) {
                    $zenService.remove(tb);
                    _edit.value = null;
                  },
                ).paddingSymmetric(horizontal: 8, vertical: 4).inkWell(
                      onSecondaryTapUp: (detail) => showPopUpMenu(context, detail, [
                        (
                          Text(
                            "Delete",
                            style: context.bodyMedium.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                          () => _edit.trigger(null),
                        ),
                      ]),
                    ),
              ],
            );
          }
          return sizedBox;
        },
        // [_edit],
        // debug: "lib/component/time_block/time_block_list_widget.dart:392 :${key}",
      ),
    ).inkWell(onTap: () {
      _edit.trigger(TimeBlockType.FOCUS);
    });
    return addLine;
  }

  Widget _buildAddLineRow(DateTime maxTime, DateTime minTime) {
    return Builder(builder: (context) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${prettyDuration(abbreviated: true, maxTime.difference(minTime), tersity: DurationTersity.minute)}"),
          Text(
            "·",
            style: context.defaultTextStyle.withColor(context.primary),
          ).paddingSymmetric(horizontal: 8),
          Text(
            "${minTime.smartFormate(DateTime.now())} -> ${maxTime.smartFormate(minTime)}",
            overflow: TextOverflow.ellipsis,
          ).expand(),
        ],
      ).opacity(.6);
    });
  }

  DateTime _maxTime() => widget.maxTime;

  DateTime _minTime() => widget.minTime;

  final Map<String, List<TimeBlock>> tag2Tbs = {};
  late final List<String> tags = [];

  late final TimeManager manager = TimeManager(minTime: widget.minTime, maxTime: widget.maxTime);

  @override
  void initState() {
    super.initState();
    updateList();
  }

  void updateList([
    List<TimeBlock>? newList,
  ]) {
    if (newList != null) {
      allList.clear();
      allList.addAll(newList);
    }
    _editMap.clear();
    tag2Tbs.clear();
    tags.clear();
    manager.clear();
    List<TimeBlock> _noTagTbs = [];
    for (var tb in allList) {
      if (tb.startTime != null && tb.progressEndTime != null) {
        manager.addInterval(TimeInterval(tb.startTime!, tb.progressEndTime!));
      }
      if (tb.isRest) {
        continue;
      } else {
        var promodo = tb.pomodoro;
        var tags = promodo.tags;
        for (var tag in tags) {
          tag2Tbs.compute(tag, (key, value) {
            value = value == null ? [] : value;
            value.add(tb);
            return value;
          });
        }
        if (TagStore.find.id2Name(tags).isEmptyOrNull) {
          _noTagTbs.add(tb);
        }
      }
    }
    final allKey = "All".i18n;
    var notagKey = "无标签".i18n;
    manager.buildFreeTimes();
    tags.addAll([allKey, ...tag2Tbs.keys.toList(), if (!_noTagTbs.isEmptyOrNull) notagKey]);
    tag2Tbs[allKey] = allList;
    if (!_noTagTbs.isEmptyOrNull) tag2Tbs[notagKey] = _noTagTbs;
    if (this.mounted) setState(() {});
  }
}

class TimeInterval {
  DateTime start;
  DateTime end;

  TimeInterval(this.start, this.end);

  @override
  String toString() => '(${start.toIso8601String()}, ${end.toIso8601String()})';
}

class TimeManager {
  TimeManager({required DateTime minTime, required DateTime maxTime})
      : _earliestTime = minTime,
        _latestTime = maxTime;

  void clear() {
    freeTimes.clear();
    intervals.clear();
  }

  List<TimeInterval> intervals = [];
  List<TimeInterval> freeTimes = [];
  final DateTime _earliestTime;
  final DateTime _latestTime;

  // 添加时间区间
  void addInterval(TimeInterval interval) {
    intervals.add(interval);
  }

  // 构建空闲时间段
  void buildFreeTimes() {
    freeTimes.clear();
    intervals.sort((a, b) => a.start.compareTo(b.start));
    DateTime lastEndTime = _earliestTime;

    for (var interval in intervals) {
      if (interval.start.isAfter(lastEndTime)) {
        freeTimes.add(TimeInterval(lastEndTime, interval.start));
      }
      if (interval.end.isAfter(lastEndTime)) {
        lastEndTime = interval.end;
      }
    }

    if (lastEndTime.isBefore(_latestTime)) {
      freeTimes.add(TimeInterval(lastEndTime, _latestTime));
    }
  }

  // 查询空闲时间段
  List<TimeInterval> findFreeTime(DateTime startTime, DateTime endTime, Duration minDuration) {
    List<TimeInterval> result = [];
    for (var freeTime in freeTimes) {
      if (freeTime.start.isBefore(endTime) && freeTime.end.isAfter(startTime)) {
        DateTime freeStart = freeTime.start.isBefore(startTime) ? startTime : freeTime.start;
        DateTime freeEnd = freeTime.end.isAfter(endTime) ? endTime : freeTime.end;
        if (freeEnd.difference(freeStart).inSeconds > minDuration.inSeconds) {
          result.add(TimeInterval(freeStart, freeEnd));
        }
      }
    }
    return result;
  }

  List<TimeInterval> findNextFreeTimes(DateTime time) {
    List<TimeInterval> result = [];
    for (var freeTime in freeTimes) {
      if (freeTime.start.isAfter(time)) {
        result.add(freeTime);
      }
    }
    return result;
  }
}
