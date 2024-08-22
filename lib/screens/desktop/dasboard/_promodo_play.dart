import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/editor/task_editor.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/timer/focus_countdown_widget.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_edit_time.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_timer_extension.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class PomodoroPlayDashboardDesktop extends StatefulWidget {
  const PomodoroPlayDashboardDesktop({super.key});

  @override
  State<PomodoroPlayDashboardDesktop> createState() => _PomodoroPlayDashboardDesktopState();
}

class _PomodoroPlayDashboardDesktopState extends State<PomodoroPlayDashboardDesktop> with ITimeBlockOnFocus, FastUpdateTime {
  final titleFocusNode = FocusNode();

  final _contextFocusNode = FocusNode();

  List<FocusNode> get focusNodeList => [
        _contextFocusNode,
        titleFocusNode,
      ];

  FocusBlock? get promodo {
    var tb = $zenService.curTimeBlock;
    if (tb.isRest) return null;
    return tb.pomodoro;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        debugTb(),
        _buildEditorOrTitle(),
        gap12,
        _buildClockBody(context).expand(flex: 3),
        gap12,
        buildBtnOnFocus(context),
        buildDesc().expand(flex: 1),
      ],
    ).simpleShortcuts(_short, debug: "_promodo_play");
  }

  late final _short = {
    FnActions.FocusNext: () => focusNodeList.next(),
    FnActions.FocusPrevious: () => focusNodeList.reversed.next(),
    FnActions.StartRest: () async {
      await $zenService.stopFocus();
      await $zenService.startRest();
    },
    FnActions.NextTask: () => nextFocus(),
    FnActions.StopFocus: () {
      $zenService.stopFocus();
    },
    FnActions.DiscardCurrentFocus: () {
      $zenService.discardFocus();
    },
    FnActions.ToggleFocus: () => togglePause(),
    FnKeys.cmdAdd: () {
      FnAudioService.instance.volume.value += 0.1;
    },
    FnKeys.cmdMinus: () {
      FnAudioService.instance.volume.value -= 0.1;
    },
    FnKeys.cmdT: () {
      showEditTime($zenService.$curTimeBlock);
    },
    FnActions.SubtractFiveMinutes: () {
      subDuration(5);
    },
    FnActions.AddFiveMinutes: () {
      addDuration(5);
    },
  };

  Widget buildDesc() {
    if (promodo == null) {
      return Text("休息中...".i18n);
    }
    return TextField(
      controller: TextEditingController(text: tbRx.justValue.tryPromodo?.context ?? ""),
      onChanged: (value) => $zenService.updateCurPromodo((p0) => p0.copyWith(context: value)),
      cursorHeight: 16,
      autofocus: PlatformUtils.isDesktop,
      minLines: 3,
      focusNode: _contextFocusNode,
      maxLines: 20,
      // expands: true,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        hintStyle: context.bodyMedium.copyWith(
          color: context.bodyMedium.color?.withOpacity(.3),
        ),
        hintText: "当下感悟".i18n,
        border: InputBorder.none,
      ),
    ).paddingOnly(left: 12, right: 12, bottom: 12, top: 4);
  }

  Widget _buildClockBody(BuildContext context) {
    var style = context.bodyLarge.copyWith(
      fontSize: 48.0,
      fontWeight: FontWeight.w900,
    );
    var focusCountDownWidget = FocusCountDownWidget(
      timeStyle: style,
      tbRx: $zenService.$curTimeBlock,
    );
    return Obx(() => CircleTimerWrapper(
          strokeWidth: 24,
          child: focusCountDownWidget,
          percent: 1 - $zenService.left.inSeconds / $zenService.duration.inSeconds,
        ));
  }

  Widget _buildEditorOrTitle() {
    var tb = $zenService.curTimeBlock;
    if (!tb.isFocus) return emptyWidget;
    var _promodo = tb.pomodoro;
    return _buildEditor(_promodo, autoFocus: false);
  }

  Widget _buildEditor(
    FocusBlock promodo, {
    bool autoFocus = false,
  }) {
    var textEditingController = TextEditingController(
      text: promodo.title ?? "",
    );
    void __submit() {
      $zenService.updateCurPromodo(
        (p0) => p0.copyWith(title: textEditingController.text),
      );
      runOnNextFrame(() => _contextFocusNode.requestFocus());
    }

    return TaskEditor(
      autofocus: autoFocus,
      focusNode: titleFocusNode,
      reverse: false,
      initTag: tbRx.justValue.tags.firstOrNull,
      recomentAbility: [RecomentAbility.TAG, RecomentAbility.HISTORY],
      controller: textEditingController,
      onEditingComplete: () {
        __submit();
      },
      onChanged: (val) {
        tbRx.value = tbRx.justValue.updateFocus(title: val);
      },
      onTagUpdate: (Tag? tag) {
        tbRx.value = tbRx.justValue.updateFocus(
          tag: tag,
          isDeleteTag: tag == null,
        );
      },
    ).simpleShortcuts({
      FnKeys.cmdS: () => __submit(),
      FnKeys.cmdEnter: () => __submit(),
    }, isRoot: true);
  }

  @override
  Rx<TimeBlock> get tbRx => $zenService.$curTimeBlock;
}
