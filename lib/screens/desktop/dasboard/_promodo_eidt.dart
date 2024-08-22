import 'dart:async';

import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/editor/task_editor.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_timer_extension.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class PomodoroEditDashboardDesktop extends StatefulWidget {
  const PomodoroEditDashboardDesktop({super.key});

  @override
  State<PomodoroEditDashboardDesktop> createState() => _PomodoroEditDashboardDesktopState();
}

class _PomodoroEditDashboardDesktopState extends State<PomodoroEditDashboardDesktop> implements ITimeBlockOnEdit {
  final FocusNode timeFocusNode = FocusNode(debugLabel: "timeFocusNode");
  final FocusNode taskEditFocusNode = FocusNode(debugLabel: "taskEditFocusNode");

  List<FocusNode> get _focusNodeList => [
        timeFocusNode,
        taskEditFocusNode,
      ];
  final timeEditController = TextEditingController();

  final Rx<TimeBlock> _tbRx = Get.touch(() => Rx<TimeBlock>(TimeBlock.emptyFocus()), tag: "edit_tb");

  Rx<TimeBlock> get tbRx => _tbRx;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = initTb(tbChange: (tb) {
      // DebugUtils.log("_promodo_eidt:48: ${tb} \n${StackTrace.current}");
      timeEditController.text = (tb.durationSeconds ~/ 60).toString();
      var lastEndFocusTb = $zenService.lastEndFocusTb;
      var pomodoro = lastEndFocusTb?.tryPromodo;
      // todo 配置是否使用上一次的任务
      tbRx.value = tbRx.justValue.updateFocus(
        title: pomodoro?.title,
        tag: pomodoro?.tags.firstOrNull?.fnmap((val) => TagStore.find.id2tag[val]),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  //todo 下一个任务
  late final taskEditController = TextEditingController(text: $zenService.curTask);
  final textStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 120,
  );

  late final _short = {
    FnActions.StartFocus: () => start(),
    FnActions.StartRest: () => startRest(),
    FnKeys.cmdT: () => timeFocusNode.requestFocus(),
    FnActions.FocusNext: () => _focusNodeList.next(),
    FnActions.FocusPrevious: () {
      _focusNodeList.reversed.next();
    },
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    runOnNextFrame(() => taskEditFocusNode.requestFocus());
    return LayoutBuilder(builder: (context, contraits) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          debugStrWidget(() => tbRx.value),
          debugTb(),
          Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Spacer(
                flex: 12,
              ),
              TextField(
                focusNode: timeFocusNode,
                cursorColor: context.primary,
                cursorHeight: 120,
                controller: timeEditController,
                onChanged: (val) {
                  var minus = int.tryParse(val);
                  if (minus == null) return;
                  tbRx.value = tbRx.justValue.updatePromodo(mapper: (p) => p.copyWith(durationSeconds: minus * 60));
                },
                keyboardType: TextInputType.number,
                textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.center,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatterWithAutoClear(),
                ],
                decoration: InputDecoration(
                  hintText: '25',
                  fillColor: Colors.transparent,
                  hintStyle: textStyle,
                  border: InputBorder.none,
                ),
                onEditingComplete: () => taskEditFocusNode.requestFocus(),
                style: textStyle,
              ).intrinsicWidth().material().hero("timer"),
              Text(
                "min",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Spacer(
                flex: 10,
              ),
            ],
          ).center(),
          gap12,
          TaskEditor(
            initSuggestionStats: RecomentStats.NONE,
            autofocus: true,
            initTag: tbRx.justValue.tags.firstOrNull,
            focusNode: taskEditFocusNode,
            controller: taskEditController,
            onEditingComplete: () => start(),
            onChanged: (val) {
              tbRx.value = tbRx.justValue.updateFocus(title: val);
            },
            onTagUpdate: (Tag? tag) {
              tbRx.value = tbRx.justValue.updateFocus(
                tag: tag,
                isDeleteTag: tag == null,
              );
              // DebugUtils.log("_promodo_eidt:146: ${tag},${tbRx.value} \n${StackTrace.current}");
            },
          ),
          gap24,
          SizedBox(
            height: Get.height / 4,
            child: buildBtnOnEdit(context),
          ),
        ],
      ).simpleShortcuts(_short);
    });
  }
}
