import 'dart:ui';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/fn_tabview.dart';
import 'package:flutter_pasteboard/component/time_block_widget/time_block_list_widget.dart';
import 'package:flutter_pasteboard/component/week_start_from.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/fn_week_view.dart';
import 'package:flutter_pasteboard/screens/mobile/controller/pomodoro_home_controller.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class TimeBlockListViewMobile extends StatefulWidget {
  const TimeBlockListViewMobile({super.key});

  @override
  State<TimeBlockListViewMobile> createState() => _TimeBlockListViewMobileState();
}

class _TimeBlockListViewMobileState extends State<TimeBlockListViewMobile> {
  late PomodoroHomeController controller = Get.find();
  late DateTime _datetime = DateTime.now();

  DateTime get minDate => DateTime.now().subtract(60.days);

  DateTime get maxDate => DateTime.now().add(1.days).onlyYmd();

  @override
  Widget build(BuildContext context) {
    late void Function()? disposer;
    return Column(
      children: [
        HorizontalWeekCalendar(
          key: ValueKey(_datetime),
          showTopNavbar: false,
          onDateChange: (date) {
            setState(() {
              _datetime = date;
            });
          },
          minDate: minDate,
          initialDate: _datetime,
          maxDate: maxDate,
        ).paddingSymmetric(horizontal: 12),
        GetBuilder<PomodoroHomeController>(
          init: controller,
          builder: (controller) {
            var vm = controller.timeBlockModel.value;
            if (vm != null) {
              return TabBarView(
                children: [
                  _buildTabView(),
                  _buildTimeBlockLine(),
                ],
              );
            }
            return _buildTabView();
          },
        ).expand(),
      ],
    );
  }

  Widget _buildMobileToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FnPopUpMenu(configs: [
          PopUpMenuConfig.raw(Obx(() {
            return Slider(
                min: 0.3,
                max: 2,
                value: clampDouble((_weekViewKey.currentState?.scale ?? 0), 0.3, 2),
                onChanged: (val) {
                  _weekViewKey.currentState?.changeScale(val);
                }).opacity(.4).tooltip(kAnyDebug ? "${((_weekViewKey.currentState?.scale ?? 0) + 0.5).toStringAsFixed(2)}" : "");
          })),
        ]),
        Row(
          children: <Widget>[
            IconButton(
                    onPressed: () {
                      setState(() {
                        _datetime = FnDateUtils.findMax([_datetime.onlyYmd().subtract(1.days), minDate.add(1.seconds)])!;
                      });
                    },
                    icon: Icon(Icons.chevron_left_outlined))
                .opacity(.5),
            Text("${FnDateUtils.humanReadable(_datetime.onlyYmd())}"),
            IconButton(
                    onPressed: () {
                      setState(() {
                        _datetime = FnDateUtils.findMin([_datetime.onlyYmd().add(1.days), maxDate.subtract(1.seconds)])!;
                      });
                    },
                    icon: Icon(Icons.chevron_right_outlined))
                .opacity(.5),
          ],
        ),
        if (_datetime.onlyYmd() != DateTime.now().onlyYmd())
          TextButton(
            onPressed: () {
              setState(() {
                _datetime = DateTime.now().onlyYmd();
              });
            },
            child: Text("今天".i18n),
          ),
        if (_datetime.onlyYmd() == DateTime.now().onlyYmd() && _weekViewKey.currentState?.hoverTime != DateTime.now())
          TextButton(
            onPressed: () {
              _weekViewKey.currentState?.requestShow(DateTime.now());
            },
            child: Text("现在".i18n),
          ),
      ],
    ).material(color: context.background, elevation: 4).paddingSymmetric(horizontal: 24);
  }

  final GlobalKey<TimeBlockTimeLineState> _tbskey = GlobalKey();
  final GlobalKey<FnWeekViewState> _weekViewKey = GlobalKey();

  Widget _buildTabView() {
    return StreamBuilder(
        stream: _search(),
        builder: (BuildContext context, AsyncSnapshot<List<TimeBlock>> snapshot) {
          List<TimeBlock>? tbs = snapshot.data;
          if (tbs == null) return emptyWidget;
          List<TimeBlock> list = tbs.whereToList((e) => e.startTime != null);
          if (_weekViewKey.currentContext != null) {
            runOnNextFrame(() => _weekViewKey.currentState?.refresh(list));
          }
          return FnWeekView(
            key: _weekViewKey,
            autofocus: false,
            timeBlocks: list,
            startTime: _datetime.onlyYmd(),
            endTime: _datetime.onlyYmd().add(1.days),
          ).stack(
              supplier: (self) => [
                    self.paddingOnly(bottom: 48),
                    _buildMobileToolbar().position(
                      bottom: 12,
                      left: 0,
                      right: 0,
                    ),
                  ]);
        });
  }

  StreamBuilder<List<TimeBlock>> _buildTimeBlockLine() {
    return StreamBuilder(
        stream: _search(),
        builder: (BuildContext context, AsyncSnapshot<List<TimeBlock>> snapshot) {
          List<TimeBlock>? tbs = snapshot.data;
          if (tbs == null) return emptyWidget;
          List<TimeBlock> list = tbs.whereToList((e) => e.startTime != null);
          if (_tbskey.currentContext != null) {
            runOnNextFrame(() => _tbskey.currentState?.updateList(list));
          }
          return TimeBlockTimeLine(
            tbs: tbs,
            key: _tbskey,
            minTime: _datetime.onlyYmd(),
            maxTime: _datetime.onlyYmd().add(1.days),
          );
        });
  }

  Stream<List<TimeBlock>> _search() {
    // 模拟输出一波 stream
    // return Stream.fromIterable([GuideData.guideTimeBlock]);
    return TimeBlockStore.find
        .queryPromodoByTime(startTime: _datetime.onlyYmd(), endTime: _datetime.onlyYmd().add(1.days))
        .watch()
        .distinct((a, b) => a.deepEqual(b, (i) => i.uniqueKey));
  }
}
