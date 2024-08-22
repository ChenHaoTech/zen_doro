import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart' hide NumDurationExtensions;
import 'package:flutter_pasteboard/component/fn_getx/fn_obx_widget.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/short_cut/ShortProvider.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/short_cut/short_cut_view.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_card.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_function.dart';
import 'package:flutter_pasteboard/component/week_view/flutter_week_view.dart';
import 'package:flutter_pasteboard/component/week_view/src/utils/builders.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/notification_mics.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/_fn_week_short_cut.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/keyboard_widget.dart';
import 'package:flutter_pasteboard/service/data_change_listener.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/undo_controller.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:hovering/hovering.dart';
import 'package:ui_extension/ui_extension.dart';

/// The demo week view widget.
class FnWeekView extends StatefulWidget {
  final List<TimeBlock> timeBlocks;
  final DateTime? initTimes;
  final DateTime startTime;
  final DateTime endTime;
  final bool autofocus;

  const FnWeekView({
    super.key,
    required this.timeBlocks,
    this.initTimes,
    required this.startTime,
    required this.endTime,
    this.autofocus = true,
  });

  @override
  State<FnWeekView> createState() => FnWeekViewState();
}

class FnWeekViewState extends State<FnWeekView> with StateDisposeMixin, ZoomControllerListener, TimeBlockChangeStateMixin {
  Rx<String> _markDelete = Rx("");
  Rx<String> _markUpdate = Rx("");

  @override
  void whenUpsertBlockChange(TimeBlock newTb) {
    var hint = _list.replaceWhere((p0) => p0.uuid == newTb.uuid, newTb);
    _markUpdate.value = newTb.uuid;
    if (hint) {
      _dirtyTbRx.value = null;
      refresh();
    }
  }

  @override
  void whenDeleteTimeBlock(String uuid) {
    var hint = _list.removeWhereExt((p0) => p0.uuid == uuid);
    _markDelete.value = uuid;
    if (hint != 0) {
      _dirtyTbRx.value = null;
      refresh();
    }
  }

  late List<TimeBlock> _list = widget.timeBlocks;

  Color get restColr => Colors.lightGreen;
  late FocusNode _focusNode = FocusNode(debugLabel: "fn_weekview${widget.autofocus}");

  final Map<DateTime, List<TimeBlock>> _map = {};
  late DateTime _initTime = widget.initTimes ?? DateTime.now();
  final RxBool _showKeyboardOverlay = RxBool(false);
  (double, double) _showKeyboardOffset = (-10, -20);

  late final _weekViewController = WeekViewController()
    ..apply((it) {
      it.addListener(this);
      var scale = SettingService.instance.weekvieScale;
      scale.init.then((value) => it.updateZoomFactor(scale.value));
    });

  double get scale {
    var scale = SettingService.instance.weekvieScale;
    scale.rx.mark();
    return _weekViewController.zoomFactor;
  }

  void changeScale(double scale) {
    _weekViewController.updateZoomFactor(scale);
    SettingService.instance.weekvieScale.value = scale;
    requestShow(_hoverTime);
  }

  double get rawHeight => _key.currentState?.hourRowHeight ?? _hourHeight;

  double get hourPerViewPoint => (position?.viewportDimension ?? 1) / (position?.maxScrollExtent ?? 1) * 24;

  double get _hourHeight => 300;
  final Rx<TimeBlock?> _dirtyTbRx = Rx(null);

  final RxSet<String> markDelete = RxSet();
  final RxSet<String> markAdd = RxSet();

  void refresh([List<TimeBlock>? list]) {
    if (!mounted) return;
    // _overlay.value = null;
    // _offserMap.clear();
    var originDate = _map.keys.mapToList((e) => e.onlyYmd()).toSet();
    if (list != null) {
      _list = list;
    }
    var dirtyTb = _dirtyTbRx.justValue;
    list ??= [
      ..._list,
      if (dirtyTb != null && !_list.any((e) => e.uuid == dirtyTb.uuid)) dirtyTb,
    ];
    _map.clear();
    for (var tb in list) {
      if (tb.startTime == null) continue;
      _map.compute(tb.startTime!.onlyYmd(), (k, v) {
        v ??= RxList();
        v.add(tb);
        return v;
      });
    }
    if (_map.keys.toSet().any((e) => !originDate.contains(e.onlyYmd()))) {
      setState(() {});
    } else {
      _markDirty();
    }
  }

  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    refresh(_list);
    RawKeyboard.instance.addListener(_handelRawKey);

    _sub = $zenService.stateRx.listen((p0) {
      requestShow(DateTime.now());
    });

    if (_initTime.isToday) {
      runOnNextFrame(() => requestShow(DateTime.now()));
    }
  }

  void _handelRawKey(RawKeyEvent event) {
    _isShiftPress.value = event.isShiftPressed;
    _isCtrlPress.value = event.isControlPressed;
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
    RawKeyboard.instance.removeListener(_handelRawKey);
  }

  void _markDirty([void Function()? callback]) {
    if (!mounted) return;
    _key.currentState?.setState(callback ?? () {});
  }

  Future _update(TimeBlock tb) async {
    await $zenService.updateTimeBlock(tb, needSave: true);
    _setDirtylay(null);
  }

  Future _remove(TimeBlock tb) async {
    await $zenService.remove(tb);
    _setDirtylay(null);
  }

  final eventPadding = EdgeInsets.all(4);

  FlutterWeekViewEvent _buildEvent(TimeBlock tb) {
    if (tb.isFocus) {
      var promodo = tb.pomodoro;
      var backgroundColor = tb.color?.withOpacity(.6) ?? context.pomodoroContainerColor;
      return FlutterWeekViewEvent(
          extra: tb,
          margin: eventPadding,
          eventTextBuilder: (FlutterWeekViewEvent event, BuildContext context, DayView dayView, double height, double width) {
            return FnObxValue(() => defaultEventTextBuilder(context, dayView, height, width, tb), [_dirtyTbRx]);
          },
          title: (promodo.title.isEmptyOrNull)
              ? "${FnDateUtils.humanReadable(tb.startTime)} - ${FnDateUtils.humanReadable(tb.endTime)}"
              : promodo.title!,
          description: promodo.context ?? "",
          backgroundColor: backgroundColor,
          decoration: boxDecoration(backgroundColor),
          padding: eventPadding,
          start: tb.startTime!,
          end: tb.endTime ?? DateTime.now(),
          textStyle: context.bodyMedium);
    } else {
      fnassert(() => tb.isRest, tb);
      var backgroundColors = restColr.withOpacity(.8);
      return FlutterWeekViewEvent(
          extra: tb,
          margin: eventPadding,
          decoration: boxDecoration(backgroundColors),
          eventTextBuilder: (FlutterWeekViewEvent event, BuildContext context, DayView dayView, double height, double width) {
            return FnObxValue(() => defaultEventTextBuilder(context, dayView, height, width, tb), [_dirtyTbRx]);
          },
          title: "休息".i18n,
          backgroundColor: backgroundColors,
          padding: eventPadding,
          start: tb.startTime!,
          end: tb.endTime ?? DateTime.now(),
          textStyle: context.bodyMedium,
          description: '');
    }
  }

  BoxDecoration boxDecoration(Color backgroundColors) {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      boxShadow: [
        BoxShadow(
          color: backgroundColors,
          spreadRadius: 2,
          offset: Offset(0, 3), // 偏移量移量
        ),
      ],
    );
  }

  RichText _buildEventView(String firstLine, String? secondLine, String? thirdLine, TextStyle textStyle, double height, double width) {
    List<TextSpan> text = [
      TextSpan(
        text: firstLine,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      if (secondLine != null)
        TextSpan(
          text: secondLine,
        ),
      if (thirdLine != null)
        TextSpan(
          text: thirdLine,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: context.onBackground.withOpacity(.6),
          ),
        ),
    ];

    bool? exceedHeight;
    while (exceedHeight ?? true) {
      exceedHeight = DefaultBuilders.$exceedHeight(text, textStyle, height, width);
      if (exceedHeight == null || !exceedHeight) {
        if (exceedHeight == null) {
          text.clear();
        }
        break;
      }

      if (!DefaultBuilders.ellipsize(text)) {
        break;
      }
    }

    return RichText(
      text: TextSpan(
        children: text,
        style: textStyle,
      ),
    );
  }

  Widget defaultEventTextBuilder(BuildContext context, DayView dayView, double height, double width, TimeBlock tb) {
    var isDirty = tb.uuid == _dirtyTbRx.justValue?.uuid;
    if (isDirty) {
      tb = _dirtyTbRx.justValue!;
    }
    late Widget content;
    var progressSeconds = tb.progressSeconds;
    var durationSeconds = tb.durationSeconds;

    String diffToolTip2 = "";
    if (progressSeconds == durationSeconds) {
      diffToolTip2 = " (${progressSeconds.seconds.inMinutes.toString()}m)";
    } else {
      diffToolTip2 = " (${progressSeconds.seconds.inMinutes.toString()}/${durationSeconds.seconds.inMinutes.toString()}m)";
    }

    if (tb.isFocus) {
      var promodo = tb.pomodoro;
      String title = promodo.title ?? "";
      String description = promodo.context ?? "";
      String feedback = "";

      if (promodo.feedback != null) {
        feedback = promodo.feedback!;
      }

      var hhmm = FnDateUtils.hhmm;
      var firstLine = title + (isDirty ? "[未保存]".i18n : "");
      var secondLine = ' ${tb.startTime?.formate(hhmm) ?? ""}-${tb.endTime?.formate(hhmm) ?? ""}${diffToolTip2} ${feedback}\n\n';
      var thirdLine = description;
      content = _buildEventView(firstLine, secondLine, thirdLine, context.bodyMedium, height, width);
    } else {
      fnassert(() => tb.isRest);

      var hhmm = FnDateUtils.hhmm;
      var firstLine = "Rest".i18n + (isDirty ? "[未保存]".i18n : "");
      var secondLine = ' ${tb.startTime?.formate(hhmm) ?? ""}-${tb.endTime?.formate(hhmm) ?? ""}${diffToolTip2}\n\n';
      content = _buildEventView(firstLine, secondLine, null, context.bodyMedium, height, width);
    }
    var result = content.inkWell(
      enableFeedback: false,
      hoverColor: Colors.transparent,
      onSecondaryTapUp: (detail) {
        _handlePopUp(context, detail, tb);
      },
      onTapUp: (TapUpDetails detail) async {
        if (context.isMobile) {
          _handlePopUp(context, detail, tb);
        } else {
          _handleEdit(tb);
        }
      },
    );

    return Obx(() {
      if (_markUpdate.value == tb.uuid) {
        return result.animate().fadeIn(duration: .3.seconds);
      } else if (_markDelete.value == tb.uuid) {
        return result.animate().fadeOut(duration: 1.seconds);
      }
      return result;
    });
  }

  void _handlePopUp(BuildContext context, TapUpDetails detail, TimeBlock tb) {
    if (_dirtyTbRx.value?.uuid != tb.uuid) {
      _setDirtylay(null);
    }
    showPopUpMenu(context, detail, [
      (
        TimeBlockCardShow(
          tb: tb,
        ),
        () async {
          await requestEdit(tb);
        }
      ),
      (
        _buildEditBtn(),
        () async {
          await requestEdit(tb);
        }
      ),
      (_buildDeleteBtn(context), () => _remove(tb))
    ]);
  }

  void _handleEdit(TimeBlock tb) async {
    if (_dirtyTbRx.value != tb) {
      _setDirtylay(tb);
      await requestEdit(tb);
    } else {
      if (tb.uuid == _dirtyTbRx.value?.uuid) {
        await requestEdit(tb);
      } else {
        _setDirtylay(null);
      }
    }
  }

  Row _buildDeleteBtn(BuildContext context) {
    return Row(
      children: [
        Text("Delete".i18n,
            style: context.bodyMedium.copyWith(
              color: context.colorScheme.error,
            )),
        Spacer(),
        Icon(
          Icons.delete,
          color: context.colorScheme.error,
          size: 20,
        ).opacity(.6)
      ],
    );
  }

  Row _buildEditBtn() {
    return Row(
      children: [
        RawTipsTextWidget(
          "Edit".i18n,
          tips: 'right click',
        ),
        Spacer(),
        Icon(
          Icons.edit_note,
          size: 20,
        ).opacity(.6)
      ],
    );
  }

  List<DateTime> get _dates {
    List<DateTime> result = [];
    var endTime = widget.endTime;
    var startTime = widget.startTime;
    fnassert(() {
      return startTime.isBefore(endTime);
    }, "${startTime}, ${endTime}");
    DateTime curtime = startTime;
    while (curtime.isBefore(endTime)) {
      result.add(curtime.onlyYmd());
      curtime = curtime.add(1.days);
    }
    fnassert(() => !result.isEmpty, "${startTime}=> ${endTime}");
    return result;
  }

  List<FlutterWeekViewEvent> get _events {
    List<FlutterWeekViewEvent> res = [];
    for (var list in _map.values) {
      res.addAll(list.mapToList((e) => _buildEvent(e)));
    }
    return res;
  }

  DateTime tryRoundTimeToFit(DateTime origin) {
    var isShiftPressed = _isShiftPress.justValue;
    // 移动端 会自动对齐
    if (!isShiftPressed && !context.isMobile) {
      return origin;
    }
    // 如果 start 和 end 日期内和其他日期重叠了, scaffoldMessage 提示失败,然后放置失败
    var endTimes = _map[origin.onlyYmd()]?.mapToList((e) => e.endTime).whereNotNull().sorted((a, b) => a.compareTo(b)) ?? [];
    for (int i = endTimes.length - 1; i >= 0; i--) {
      DateTime endTime = endTimes[i];
      var diffDuration = origin.difference(endTime);
      // origin 更小点, 直接忽略
      if (diffDuration.isNegative) {
        continue;
      }
      // origin 更大点, 如果小于, 直接贴上去
      if (diffDuration <= 2.minutes) {
        return endTime;
      } else {
        var minute = ((origin.minute) / 5).ceil() * 5;
        return origin.copyWith(minute: minute);
      }
    }
    var minute = ((origin.minute) / 5).ceil() * 5;
    return origin.copyWith(minute: minute);
  }

  void _setDirtylay(
    TimeBlock? tb, {
    bool requestEdit = true,
  }) {
    var oldV = _dirtyTbRx.justValue;
    if (oldV?.uuid == tb?.uuid) {
      return;
    }
    _dirtyTbRx.value = tb;
    refresh();
  }

  final GlobalKey<WeekViewState> _key = GlobalKey();
  DateTime? _hoverTime = null;

  DateTime? get hoverTime => _hoverTime;
  TimeBlockType _blockType = TimeBlockType.FOCUS;
  RxBool _isShiftPress = false.obs;
  RxBool _isCtrlPress = false.obs;

  Widget defaultCurrentTimeIndicatorBuilder(
    DayViewStyle dayViewStyle,
    TopOffsetCalculator topOffsetCalculator,
    double hoursColumnWidth,
    bool isRtl, {
    HourMinute? customerHourMinute,
    Widget Function(Widget)? decorator,
  }) {
    var currentTimeRuleHeight = dayViewStyle.currentTimeRuleHeight * scale;

    final timeIndicatorHight = currentTimeRuleHeight;
    var content = Container(
      height: currentTimeRuleHeight,
      color: dayViewStyle.currentTimeRuleColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Obx(() => Text(
                  FnDateUtils.hhmm.format(FnDateUtils.now.value),
                  style: context.bodySmall.copyWith(
                    color: context.primary,
                  ),
                )),
          ),
        ],
      ),
    );

    return Obx(() {
      return Positioned(
        top: topOffsetCalculator(
              customerHourMinute ?? HourMinute.fromDateTime(dateTime: FnDateUtils.nowYmdHm.value),
            ) -
            timeIndicatorHight / 2,
        left: isRtl ? 0 : hoursColumnWidth,
        right: isRtl ? hoursColumnWidth : 0,
        child: decorator?.call(content) ?? content,
      );
    });
  }

  RxDouble _offset = RxDouble(0);

  ScrollPosition? get position => _key.currentState?.verticalScrollController?.position;

  Widget _builsScrollerNav(double height, double width) {
    if (_dates.length != 1) return emptyWidget;
    var date = _dates[0];
    return Obx(() {
      var minOffset = position?.minScrollExtent;
      var maxOffset = position?.maxScrollExtent;
      var viewPortSize = position?.viewportDimension ?? 1;
      var allSize = max((maxOffset ?? 1) - (minOffset ?? 1), 1) + viewPortSize;
      var todayOffset = FnDateUtils.now.value.difference(FnDateUtils.now.value.onlyYmd()).inMinutes / FnDateUtils.day_minutes;
      return GestureDetector(
        onTapDown: (TapDownDetails details) {
          var factor = clampDouble(details.localPosition.dx / width, .1, 1);
          // DebugUtils.log("fn_week_view:581:${factor} ${details.localPosition.dx / width} ${details.localPosition}:${width} \n${StackTrace.current}");
          requestShow(date.copyWith(hour: (factor * 24).toInt()));
        },
        child: Stack(
          children: [
            Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: context.onBackground.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8), // 圆角
                )),
            ..._list.mapToList((e) {
              if (e.startTime == null || e.endTime == null) return null;
              var offset = e.startTime!.difference(e.startTime!.onlyYmd()).inMinutes / FnDateUtils.day_minutes;
              // DebugUtils.log("fn_week_view:547 ${offset} \n${StackTrace.current}");
              var widgetFactor = e.progressEndTime!.difference(e.startTime!).inMinutes / FnDateUtils.day_minutes;
              return Positioned(
                  left: offset * width,
                  child: Container(
                    height: height,
                    width: clampDouble(widgetFactor * width, 2, width),
                    decoration: BoxDecoration(
                      color: e.color ?? context.pomodoroContainerColor,
                    ),
                  ));
            }).whereNotNull(),
            if (DateTime.now().isAtSameDayAs(date.onlyYmd()))
              Positioned(
                  left: todayOffset * width,
                  child: Container(
                    height: height,
                    width: 2,
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(8), // 圆角
                    ),
                  )),
            Positioned(
                left: _offset.value / allSize * width,
                child: Container(
                  height: height,
                  width: (viewPortSize / allSize) * width,
                  decoration: BoxDecoration(
                    color: context.onBackground.withOpacity(.3),
                    borderRadius: BorderRadius.circular(8), // 圆角
                  ),
                )),

            // debug
            if (kDebugMode) Obx(() => Text("${scale}")).position(top: 10),
          ],
        ),
      );
    });
  }

  final double _navigatorHeight = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, BoxConstraints contraints) {
        final Rx<TimeBlock?> _curDragTb = Rx(null);
        var weekView2 = GestureConfig(
          onTapUp: (event, details) {
            _handleEdit(event.extra as TimeBlock);
          },
          onSecondTap: (FlutterWeekViewEvent event, details) {
            _handlePopUp(context, details, event.extra as TimeBlock);
          },
          child: WeekView(
            key: _key,
            currentTimeIndicatorBuilder: defaultCurrentTimeIndicatorBuilder,
            hoverDateBuilder: (hoverDate) {
              _isShiftPress.mark();
              return tryRoundTimeToFit(hoverDate);
            },
            dayBarStyleBuilder: (DateTime date) => DayBarStyle.fromDate(date: date).copyWith(color: Colors.transparent),
            hoverWidget: (nowTime) {
              _hoverTime = nowTime;
              _focusNode.requestFocus();
              return _buildHoverCurrentWidget(nowTime);
            },
            controller: _weekViewController,
            // dayBarStyleBuilder: ,
            dayViewStyleBuilder: (date) => DayViewStyle.fromDate(date: date).copyWith(
              hourRowHeight: _hourHeight,
              backgroundColor: context.colorScheme.background,
            ),
            initialTime: _initTime,
            hoursColumnStyle: HoursColumnStyle(
              textStyle: context.defaultTextStyle.withOpacity(.7),
              color: context.colorScheme.background,
            ),
            style: WeekViewStyle(
              headerSize: _navigatorHeight,
              dayViewWidth: max(((contraints.maxWidth - 80) / _dates.length), contraints.maxHeight / 3),
              dayViewSeparatorWidth: 6,
              dayViewSeparatorColor: context.colorScheme.onBackground.withOpacity(.1),
              showHorizontalScrollbar: true,
            ),
            onBackgroundTappedDown: _onBackGroundClick,
            // onBackgroundDragStart: (DateTime dateTime) async {
            //   if (dateTime.isAfter(DateTime.now())) {
            //     FnNotification.showSnackBar(content: Text("努力开发中,暂不支持添加到未来...".i18n));
            //     return;
            //   }
            //   dateTime = tryRoundTimeToFit(dateTime);
            //   var promodo = TimeBlock.emptyPromodo(
            //     startTime: dateTime,
            //     endTime: dateTime.add(
            //       (SettingService.instance.defaultTimeBlockDurationInMinus.value).minutes,
            //     ),
            //   );
            //   _curDragTb.value = promodo;
            //   _update(promodo);
            // },
            // onBackgroundDragUpdate: (DateTime dateTime) async {
            //   if (_curDragTb.value == null) return;
            //   dateTime = roundTimeToFitGrid(dateTime);
            //   var promodo = _curDragTb.value!.copyWith(
            //     endTime: dateTime,
            //   );
            //   _update(promodo);
            // },
            dragAndDropOptions: DragAndDropOptions(
              startingGesture: context.isMobile ? DragStartingGesture.longPress : DragStartingGesture.tap,
              onEventDragged: (FlutterWeekViewEvent event, DateTime newStartTime) async {
                DateTime roundedTime = tryRoundTimeToFit(newStartTime).clamp(null, DateTime.now());
                event.shiftEventTo(roundedTime);
                var origin = (event.extra as TimeBlock);
                var diffDuration = roundedTime.difference(origin.startTime!);
                if (event.start == origin.startTime) return;
                var tb = (origin as TimeBlock)
                    .updateTime(startTime: event.start, endTime: origin.endTime == null ? null : origin.endTime!.add(diffDuration))
                    .correctDuration();
                await _update(tb);
                _markUndo(origin, debug: tb.toString());
              },
            ),
            userZoomable: true,
            resizeEventOptions: ResizeEventOptions(
              snapToGridGranularity: 1.minutes,
              minimumEventDuration: 5.minutes,
              onEventResized: (FlutterWeekViewEvent event, DateTime newEndTime) async {
                _dirtyTbRx.value = null;
                event.end = newEndTime;
                var origin = event.extra as TimeBlock;
                if (event.end == origin.endTime) return;
                var tb = (origin as TimeBlock).updateTime(startTime: event.start, endTime: event.end).correctDuration();
                fnassert(() => tb.endTime == newEndTime);
                await _update(tb);
                _markUndo(origin, debug: newEndTime.toString());
              },
              onEventResizing: (FlutterWeekViewEvent event, DateTime newEndTime) async {
                event.end = newEndTime;
                var origin = event.extra as TimeBlock;
                if (event.end == origin.endTime) return;
                var tb = (origin as TimeBlock).updateTime(startTime: event.start, endTime: event.end).correctDuration();
                _dirtyTbRx.value = tb;
              },
            ),
            dates: _dates,
            events: () => _events,
          ),
        );
        var weekView = DayBarWidgetSupplier(
          barSupplier: (DateTime date, double? height, double? width) {
            return _builsScrollerNav(_navigatorHeight, width ?? Get.width * .9);
          },
          child: weekView2
              .withNotified((not) {
                // ScrollPositionWithSingleContext().toString()
                _offset.value = position?.pixels ?? 0;
                var minOffset = position?.minScrollExtent;
                var maxOffset = position?.maxScrollExtent;
                // DebugUtils.log("fn_weekview:674:(${_offset.justValue},$minOffset,$maxOffset)${position} ${not}\n${StackTrace.current}");
              })
              .focus(
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                onKey: (_, RawKeyEvent event) {
                  var originValue = scale;
                  if (event.isShiftPressed && event.isKeyPressed(LogicalKeyboardKey.digit1)) {
                    changeScale(1);
                  } else if (event.isShiftPressed && event.isKeyPressed(LogicalKeyboardKey.digit2)) {
                    changeScale(.5);
                  } else if (event.isShiftPressed && event.isKeyPressed(LogicalKeyboardKey.digit3)) {
                    changeScale(.2);
                  } else if (event.isShiftPressed && event.isKeyPressed(LogicalKeyboardKey.digit4)) {
                    changeScale(.1);
                  }
                  if (originValue != scale) {
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
              )
              .simpleShortcuts(
                {
                  FnKeys.cmdS: () {
                    if (_dirtyTbRx.justValue != null) {
                      _update(_dirtyTbRx.justValue!);
                    }
                  },
                },
                isRoot: true,
              )
              .simpleShortcuts(
                {
                  FnWeekViewKeys.focusNow: () {
                    requestShow(DateTime.now());
                  },
                  FnKeys.cmdAltComma: () {
                    _showKeyboardOverlay.toggle();
                  }
                },
              ),
        );
        return weekView.stack(
            clipBehavior: Clip.none,
            supplier: (self) => [
                  self,
                  if (context.isDesktop)
                    _buildExtOverloayWithHover().position(
                      right: 12,
                      bottom: 12,
                    ),
                ]);
      },
    ).portalOverlay(Obx(() {
      if (!_showKeyboardOverlay.value || !PlatformUtils.isDesktop) return emptyWidget;
      return _buildHoverKeyboardWidgetDesktop();
    }),
        anchor:
            Aligned(follower: Alignment.bottomRight, target: Alignment.bottomRight, offset: Offset(_showKeyboardOffset.$1, _showKeyboardOffset.$2)));
  }

  void _markUndo(TimeBlock origin, {String? debug}) {
    FnUndoController.find.showUndo(
        promopt: "撤销时间修改".i18n + debugString(debug),
        onUndo: () {
          _update(origin);
        });
  }

  @override
  void onZoomFactorChanged(covariant ZoomController controller, ScaleUpdateDetails details) {
    SettingService.instance.weekvieScale.justValue = controller.scale;
  }

  @override
  void onZoomStart(covariant ZoomController controller, ScaleStartDetails details) {
    //pass
  }
}

extension _WidgetExt on FnWeekViewState {
  GestureDetector _buildHoverKeyboardWidgetDesktop() {
    return GestureDetector(
      child: KeyBoardWidget()
          .paddingOnly(top: 12)
          .boxConstraints(
            maxWidth: 200,
            maxHeight: 200,
          )
          .paddingSymmetric(horizontal: 12, vertical: 8)
          .material(elevation: 1),
      onTap: () => _showKeyboardOverlay.value = false,
      onPanUpdate: (DragUpdateDetails detail) {
        this.setState(() {
          var originX = _showKeyboardOffset.$1;
          var originY = _showKeyboardOffset.$2;
          var offset = detail.delta;
          _showKeyboardOffset = (originX + offset.dx, originY + offset.dy);
        });
      },
    );
  }

  Widget _buildExtOverloayWithHover() {
    var slider = buildScaleSlider();
    return HoverCrossFadeWidget(
      firstChild: Icon(
        Icons.settings_suggest_outlined,
        color: context.primary,
      ).opacity(.4),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.keyboard_alt_outlined,
                color: context.primary,
                size: 16,
              ),
              Spacer(),
              ShortcutTextWidget("快捷键".i18n, keySet: FnKeys.cmdAltComma),
            ],
          )
              .paddingSymmetric(
            horizontal: 24,
          )
              .inkWell(onTap: () {
            _showKeyboardOverlay.value = true;
          }),
          slider,
        ],
      )
          .paddingSymmetric(vertical: 4)
          .material(
            elevation: 4,
            radius: 8,
            color: context.background,
          )
          .boxConstraints(maxWidth: 240),
      duration: .2.seconds,
    );
  }

  Obx buildScaleSlider() {
    return Obx(() {
      return Slider(
          min: 0,
          max: 4,
          value: scale,
          onChanged: (val) {
            changeScale(val);
          }).opacity(.4).tooltip(kAnyDebug ? "${(scale + 0.5).toStringAsFixed(2)}" : "");
    });
  }

  Widget _buildHoverCurrentWidget(DateTime nowTime) {
    var opacity = .3;
    if (context.isMobile) return emptyWidget;
    return Obx(() {
      if (nowTime.isAfter(FnDateUtils.now.value)) {
        return Container(
          height: 2,
          color: context.primary,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: Row(
                  children: <Widget>[
                    Text(
                      "暂不支持添加到未来".i18n,
                      style: context.bodySmall.copyWith(
                        color: context.primary.withOpacity(.3),
                      ),
                    ),
                    gap4,
                    Text(
                      FnDateUtils.hhmm.format(nowTime),
                      style: context.bodySmall.copyWith(
                        color: context.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      var hourRowHeight = _key.currentState?.hourRowHeight ?? _hourHeight * _weekViewController.zoomFactor;
      if (_isCtrlPress.value) {
        _blockType = TimeBlockType.REST;
        var minutes = SettingService.instance.defaultRestMinus.value;
        var height = hourRowHeight * (minutes / 60) * .9;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gap4,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gap4,
                Text("${FnDateUtils.humanReadable(nowTime)} -> ${FnDateUtils.hhmm.format(nowTime.add(minutes.minutes))}"),
                gap2,
                Text(
                  "${minutes} min",
                ).opacity(.4),
                gap4,
              ],
            )
                .container(
                  padding: eventPadding,
                  decoration: boxDecoration(restColr.withOpacity(opacity)),
                )
                .sizedBox(
                  height: height,
                ),
          ],
        );
      }
      _blockType = TimeBlockType.FOCUS;
      var minutes = SettingService.instance.defaultFocusMinus.value;
      var height = hourRowHeight * (minutes / 60) * .9;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gap4,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gap4,
              Text("${FnDateUtils.humanReadable(nowTime)} -> ${FnDateUtils.hhmm.format(nowTime.add(minutes.minutes))}"),
              gap2,
              Text(
                "${minutes} min",
              ).opacity(.4),
              gap4,
            ],
          )
              .container(
                padding: eventPadding,
                decoration: boxDecoration(context.cs.primaryContainer.withOpacity(opacity)),
              )
              .sizedBox(
                height: height,
              ),
        ],
      );
    }).material(elevation: 2);
  }
}

extension FnWeekViewStateHelper on FnWeekViewState {
  void requestShow(DateTime? time) {
    if (mounted && time != null) {
      this.setState(() {
        _initTime = time.subtract((hourPerViewPoint / 3).hours).atDate(_initTime);
      });
    }
  }
}

extension EditExt on FnWeekViewState {
  Future<void> requestEdit(TimeBlock tb) async {
    await showTimeBlockCardEditor(
      tb: tb,
    );
    _setDirtylay(null);
  }
}

extension BackGroundExt on FnWeekViewState {
  void _onBackGroundClick(DateTime dateTime, details) async {
    if (_dirtyTbRx.value != null) {
      _setDirtylay(null);
      return;
    }
    _focusNode.requestFocus();
    dateTime = _hoverTime ?? tryRoundTimeToFit(dateTime);
    if (dateTime.isAfter(DateTime.now())) {
      FnNotification.showSnackBar(content: Text("努力开发中,暂不支持添加到未来...".i18n));
      return;
    }
    var emptyFocus = TimeBlock.emptyFocus(
      startTime: dateTime,
      endTime: dateTime.add(
        (SettingService.instance.defaultFocusMinus.value).minutes,
      ),
    );
    var emptyRest = TimeBlock.emptyCountDownRest(
      startTime: dateTime,
      endTime: dateTime.add(
        (SettingService.instance.defaultRestMinus.value).minutes,
      ),
    );
    late TimeBlock tb;
    if (_blockType == TimeBlockType.FOCUS) {
      tb = emptyFocus;
    } else {
      tb = emptyRest;
    }
    _setDirtylay(tb);

    // 手机端
    if (!context.isDesktop) {
      showPopUpMenu(context, details, [
        (
          Builder(builder: (context) {
            return Text("添加休息".i18n, style: context.defaultTextStyle.withColor(context.restColor));
          }),
          () async {
            _setDirtylay(emptyRest);
            requestEdit(emptyRest);
          }
        ),
        (
          Text("添加专注".i18n),
          () async {
            requestEdit(emptyFocus);
          }
        ),
        if (kDebugMode) (Text("直接添加专注".i18n), () => $zenService.updateTimeBlock(emptyFocus)),
      ]);
      // 桌面端
    }
  }
}
