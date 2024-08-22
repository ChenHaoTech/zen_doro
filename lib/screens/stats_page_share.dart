import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/fn_getx/fn_obx_widget.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/stats/stats_card_text.dart';
import 'package:flutter_pasteboard/component/stats/stats_enum.dart';
import 'package:flutter_pasteboard/component/stats/table_stats_card.dart';
import 'package:flutter_pasteboard/component/stats/table_stats_card2.dart';
import 'package:flutter_pasteboard/component/time_block_widget/time_block_list_widget.dart';
import 'package:flutter_pasteboard/component/timer/feedback_const.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/feedback_utils.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class StatsPageAdaptive extends StatefulWidget {
  const StatsPageAdaptive({super.key});

  @override
  State<StatsPageAdaptive> createState() => _StatsPageAdaptiveState();
}

class StatsModel {
  DateTime _startTime = DateTime.now().onlyYmd();
  DateTime _endTime = DateTime.now().onlyYmd().add(1.days);
  DateTimeSelectorType _dateTimeSelectorType = DateTimeSelectorType.day;
}

class _StatsPageAdaptiveState extends State<StatsPageAdaptive> with StatsMixin {
  bool _debug = kDebugMode;

  RxObjectMixin<double> get _widgetFactor => SettingService.instance.dashboardFactor.rx;
  StatsModel _model = Get.touch(() => StatsModel(), tag: "StatsModel");

  Stream<List<TimeBlock>> _searchStream() {
    this.log.dd(() => "search ${_model._startTime}=>${_model._endTime}");
    return TimeBlockStore.find.queryPromodoByTime(startTime: _model._startTime, endTime: _model._endTime).watch().distinct(
      (a, b) {
        var deepEqual = a.deepEqual(b, (i) => i.uuid);
        return deepEqual;
      },
    );
  }

  final GlobalKey<TimeBlockTimeLineState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) return _buildMobile();
    return _buildDeskTop();
  }

  Widget _buildMobile() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.arrow_back_ios).opacity(.6),
              ),
              TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: context.focusColor,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                splashBorderRadius: BorderRadius.circular(32),
                tabs: [
                  Text("统计".i18n),
                  Text("列表".i18n),
                ],
              ).expand(),
              FnPopUpMenu(configs: [
                if (kDebugMode)
                  PopUpMenuConfig.textBtn("DB VIEW", () {
                    routes.to(() => DriftDbViewer(AppDatabase.get));
                  }),
                PopUpMenuConfig.textBtn("反馈".i18n, () {
                  FeedbackUtils.instance.show(context);
                }),
              ]),
            ],
          ),
        ),
        bottomNavigationBar: _buildPeriodSelector(
          startTime: _model._startTime,
          endTime: _model._endTime,
        ),
        body: StreamBuilder(
            stream: _searchStream(),
            builder: (context, snp) {
              List<TimeBlock>? data = snp.data;
              if (data == null) return emptyWidget;
              if (_key.currentContext != null) {
                runOnNextFrame(() => _key.currentState?.updateList(data));
              }
              return TabBarView(
                children: [
                  ListView(
                    children: [
                      _buildTimePicker(),
                      ..._statsViewWidgets(data),
                    ],
                  ),
                  TimeBlockTimeLine(
                    tbs: data,
                    showDayBar: _model._dateTimeSelectorType != DateTimeSelectorType.day,
                    key: _key,
                    minTime: _model._startTime,
                    maxTime: _model._endTime,
                  ),
                ],
              );
            }),
      ).safeArea().container(color: context.background),
    );
  }

  Widget _buildDeskTop() {
    return Column(
      children: [
        gap12,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimePicker(),
            _buildPeriodSelector(
              startTime: _model._startTime,
              endTime: _model._endTime,
            ),
          ],
        ),
        Divider(),
        StreamBuilder(
            stream: _searchStream(),
            builder: (context, snp) {
              List<TimeBlock>? data = snp.data;
              if (data == null) return emptyWidget;
              if (_key.currentContext != null) {
                runOnNextFrame(() => _key.currentState?.updateList(data));
              }
              return FnObxValue(() {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsView(data).expand(flex: (_widgetFactor.justValue * 100).toInt()),
                    TimeBlockTimeLine(
                      tbs: data,
                      key: _key,
                      showDayBar: _model._dateTimeSelectorType != DateTimeSelectorType.day,
                      minTime: _model._startTime,
                      maxTime: _model._endTime,
                    ).expand(flex: ((1 - _widgetFactor.justValue) * 100).toInt()),
                  ],
                );
              }, [_widgetFactor]);
            }).expand(),
      ],
    ).focus(autofocus: true);
  }

  Widget _buildStatsView(List<TimeBlock> timeblocks) {
    return ListView(
      shrinkWrap: true,
      children: _statsViewWidgets(timeblocks),
    );
  }

  List<Widget> _statsViewWidgets(List<TimeBlock> timeblocks) {
    return [
      TextStatsCard(
        key: UniqueKey(),
        timeBlocks: timeblocks,
      ).paddingSymmetric(vertical: 20).card().paddingSymmetric(horizontal: 4),
      TableStatsCard(
        minTime: _model._startTime,
        maxTime: _model._endTime.subtract(1.seconds),
        key: UniqueKey(),
        colorSupplier: (tagValue) => TagStore.find.value2tag[tagValue]?.color,
        timeBlocks: timeblocks,
        title: 'Tag'.i18n,
        keyMapper: (key) {
          var takeIf = key.takeIf((it) => !it.trim().isEmptyOrNull);
          return Text(
            takeIf ?? "No tagValue".i18n,
            overflow: TextOverflow.ellipsis,
          ).opacity(takeIf == null ? .4 : 1);
        },
        groupByFunction: TimeBlockListUtils.groupByTag,
      ).paddingSymmetric(vertical: 20).card().paddingSymmetric(horizontal: 4),
      TableStatsCard(
        minTime: _model._startTime,
        maxTime: _model._endTime.subtract(1.seconds),
        key: UniqueKey(),
        timeBlocks: timeblocks,
        title: "Emotion".i18n,
        colorSupplier: (emoji) => feedbackEmojisColor[emoji],
        keyMapper: (key) {
          var takeIf = key.takeIf((it) => !it.trim().isEmptyOrNull);
          if (takeIf != null) {
            return Text(
              takeIf,
              overflow: TextOverflow.ellipsis,
            );
          }
          return Text(
            takeIf ?? unknow_feedbackEmoji,
            overflow: TextOverflow.ellipsis,
          ).opacity(.4);
        },
        groupByFunction: TimeBlockListUtils.groupByFeedback,
      ).paddingSymmetric(vertical: 20).card().paddingSymmetric(horizontal: 4),
      TableStatsCard2(
        key: UniqueKey(),
        timeBlocks: timeblocks,
        title: 'Task'.i18n,
        keyMapper: (key) {
          var takeIf = key.takeIf((it) => !it.trim().isEmptyOrNull);
          if (takeIf != null) {
            return Text(
              takeIf,
              overflow: TextOverflow.ellipsis,
            );
          }
          return Text(
            takeIf ?? "未指定".i18n,
            overflow: TextOverflow.ellipsis,
          ).opacity(.4);
        },
        groupByFunction: TimeBlockListUtils.groupByTask,
      ).paddingSymmetric(vertical: 20).card().paddingSymmetric(horizontal: 4),
      // if (_debug)
      //   Text("len: ${timeblocks.length}\n${timeblocks.mapToList(
      //         (e) => e.tryPromodo?.toJsonStr() ?? "",
      //       ).join("\n")}")
    ];
  }

  void _updatePeriod({
    bool requestPre = false,
  }) {
    var startTime = _model._startTime.onlyYmd();
    switch (_model._dateTimeSelectorType) {
      case DateTimeSelectorType.week:
        if (requestPre) {
          startTime = startTime.previousWeek;
        } else {
          startTime = startTime.nextWeek;
        }
        _model._startTime = startTime.firstWeekDay;
        _model._endTime = startTime.lastWeekDay;
      case DateTimeSelectorType.month:
        if (requestPre) {
          startTime = startTime.previousMonth;
        } else {
          startTime = startTime.nextMonth;
        }

        _model._startTime = startTime.firstMonthDay;
        _model._endTime = startTime.lastMonthDay;
      case DateTimeSelectorType.day:
      default:
        if (requestPre) {
          startTime = startTime.previousDay;
        } else {
          startTime = startTime.nextDay;
        }
        _model._startTime = startTime;
        _model._endTime = _model._startTime.add(1.days);
    }
  }

  Widget _buildPeriodSelector({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                _updatePeriod(requestPre: true);
              });
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 16,
            )),
        buildTitle(startTime, endTime),
        IconButton(
            onPressed: () {
              setState(() {
                _updatePeriod(requestPre: false);
              });
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 16,
            )),
      ],
    ).material();
  }

  Widget _buildTimePicker() {
    return SegmentedButton<DateTimeSelectorType>(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      segments: const <ButtonSegment<DateTimeSelectorType>>[
        ButtonSegment<DateTimeSelectorType>(value: DateTimeSelectorType.day, label: Text('Day')),
        ButtonSegment<DateTimeSelectorType>(value: DateTimeSelectorType.week, label: Text('Week')),
        ButtonSegment<DateTimeSelectorType>(
          value: DateTimeSelectorType.month,
          label: Text('Month'),
        ),
      ],
      selected: <DateTimeSelectorType>{_model._dateTimeSelectorType},
      onSelectionChanged: (Set<DateTimeSelectorType> newSelection) {
        setState(() {
          _model._dateTimeSelectorType = newSelection.first;
          switch (_model._dateTimeSelectorType) {
            case DateTimeSelectorType.week:
              _model._startTime = DateTime.now().onlyYmd().firstWeekDay;
              _model._endTime = DateTime.now().onlyYmd().lastWeekDay;
            case DateTimeSelectorType.month:
              _model._startTime = DateTime.now().onlyYmd().firstMonthDay;
              _model._endTime = DateTime.now().onlyYmd().lastMonthDay;
            case DateTimeSelectorType.day:
            default:
              _model._startTime = DateTime.now().onlyYmd();
              _model._endTime = _model._startTime.add(1.days);
          }
        });
      },
    ).paddingSymmetric(horizontal: 12);
  }

  @override
  DateTimeSelectorType get dateTimeSelectorType => _model._dateTimeSelectorType;
}

abstract mixin class StatsMixin {
  DateTimeSelectorType get dateTimeSelectorType;

  Text buildTitle(DateTime startTime, DateTime endTime) {
    if (dateTimeSelectorType == DateTimeSelectorType.day) {
      fnassert(() => endTime.difference(startTime).inDays <= 1, [endTime, startTime]);
      return Text(FnDateUtils.humanReadable(startTime));
    }
    var format = FnDateUtils.mmd_notime;
    if (startTime.year != FnDateUtils.now.value.year) {
      format = FnDateUtils.ymmd_notime;
    }
    return Text("${startTime.formate(format)} > ${endTime.formate(format)}");
  }
}
