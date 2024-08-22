import 'dart:async';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/lock.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/data_change_listener.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/system_tray_service.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/service/undo_controller.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

export './model/fn_state.dart';

class PomodoroController extends GetxController with TimeBlockChangeGetxMixin {
  FnAudioService get _fnAudioService => FnAudioService.instance;
  TimeBlock? lastEndFocusTb;
  final Locker feedbackLocker = Locker();

  SettingService get _settingService => SettingService.instance;

  String get curTask => _settingService.lastTask.value;

  bool get isRest => $curTimeBlock.value.isRest && state.isRest;

  bool get isFocus => $curTimeBlock.value.isFocus && state.isFocus;

  Duration get left {
    var tb = $curTimeBlock.value;
    if (tb.isRest)
      return (tb.rest.leftSeconds ?? 0).seconds;
    else {
      return tb.pomodoro.leftSeconds.seconds;
    }
  }

  Duration get duration {
    var tb = $curTimeBlock.value;
    if (tb.isRest)
      return (tb.rest.durationSeconds ?? 0).seconds;
    else {
      return tb.pomodoro.durationSeconds.seconds;
    }
  }

  bool get needAudio {
    return state == PomodoroState.Focus;
  }

  RxDouble get volume => _fnAudioService.volume;

  final Rx<TimeBlock> $curTimeBlock = Rx<TimeBlock>(TimeBlock.emptyFocus());

  TimeBlock get curTimeBlock => $curTimeBlock.value;

  Future updateCurPromodo(
    FocusBlock Function(FocusBlock) mapper, {
    DateTime? startTime,
    DateTime? endTime,
    bool needSave = true,
  }) async {
    await updateTimeBlock(
        $curTimeBlock.justValue
            .updatePromodo(
              mapper: mapper,
            )
            .updateTime(
              startTime: startTime,
              endTime: endTime,
            ),
        needSave: needSave);
  }

  Future updateRest(
    RestBlock Function(RestBlock) mapper, {
    bool needSave = true,
  }) async {
    var value = $curTimeBlock.justValue.updateRest(mapper: mapper);
    await updateTimeBlock(value, needSave: needSave);
  }

  Future<TimeBlock> updateTimeBlock(
    TimeBlock value, {
    bool needSave = true,
  }) async {
    // DebugUtils.log("pomodoro_controller:106: ${value} \n${StackTrace.current}");
    this.log.dd(() => "修改 timeblock: ${value}(isdoing: ${value.isDoing}),needSave:${needSave}");
    var originTb = $curTimeBlock.justValue;

    if (value.isDoing) {
      this.log.dd(() => "结束时间在当前时间之后, 自动开始该时间块\n: ${value} }");
      if (value.uuid != originTb.uuid && (state.isFocus /*正在进行中*/ || state.isRest /*正在休息中*/)) {
        this.log.dd(() => "中断之前的番茄, ${$curTimeBlock.justValue}");
        await _stopInner(nextTb: value);
      }
      if (value.isRest && !state.isRest) {
        FnNotification.toast("开始休息".i18n);
        await startRest(value);
      } else if (value.isFocus && (!state.isFocus)) {
        fnassert(() => value.isFocus, value);
        FnNotification.toast("开始专注".i18n);
        await startFocus(value);
        _settingService.lastTask.value = value.pomodoro.title ?? "";
      } else {
        $curTimeBlock.value = value;
      }
      fnassert(() => $curTimeBlock.justValue.uuid == value.uuid);
    } else {
      fnassert(() => !value.isDoing, value);
      if (value.uuid == originTb.uuid) {
        if (value.isEnd) {
          this.log.dd(() => "对应的 timeblock 已经结束时间已经结束了, stopinner: ${value}");
          await _stopInner(nextTb: TimeBlock.emptyFocus());
        } else {
          $curTimeBlock.value = value;
        }
      } else {
        if (state.isIdle && value.isDoing) {
          $curTimeBlock.value = value;
        }
      }
    }
    // 无论如何, 有保存的先保存吧
    if (needSave && value.startTime != null) {
      TimeBlockStore.find.save(value.uuid == $curTimeBlock.justValue.uuid ? $curTimeBlock.justValue : value);
    }
    return $curTimeBlock.justValue;
  }

  final Rx<Duration> _idle = Rx(Duration(seconds: 0));

  Duration get idle => _idle.value;

  final Map<String, Timer> _timerMap = {};

  final Rx<PomodoroState> stateRx = Rx<PomodoroState>(PomodoroState.Edit);

  PomodoroState get state => stateRx.value;

  set state(value) {
    if (value != stateRx.justValue) {
      this.log.dd(() => "update state: ${stateRx.justValue}=> ${value}");
      stateRx.value = value;
    }
  }

  Future _markEndTime([bool isTimeOut = false]) async {
    var tb = $curTimeBlock.value;
    if (tb.startTime == null) {
      tb = tb.updateTime(startTime: DateTime.now());
    }
    var isPromodo = tb.isFocus;
    if (isPromodo) {
      tb = tb.updateTime(endTime: DateTime.now());
    } else {
      fnassert(() => tb.isRest);
      tb = tb.updateTime(endTime: DateTime.now());
    }
    await TimeBlockStore.find.save(tb);
  }

  int get restType => $curTimeBlock.value.rest.type;

  Future<bool> remove(TimeBlock timeBlock) async {
    var cur = $zenService.curTimeBlock;
    if (cur.uuid == timeBlock.uuid) {
      await $zenService._stopInner(nextTb: TimeBlock.emptyFocus(), needDelete: true);
    }
    var cnt = await TimeBlockStore.find.delete(timeBlock.uuid);
    if (cnt != 0) {
      FnUndoController.find.showUndo(
          promopt: timeBlock.isRest ? "删除了一个休息块".i18n : "删除了一个专注块".i18n,
          onUndo: () {
            updateTimeBlock(timeBlock);
          });
    }
    return cnt != 0;
  }

  Future _stopInner({bool? needDelete, required TimeBlock nextTb}) async {
    TimeBlock tb = await _stopInnerWIthoutDisk(nextTb);
    needDelete ??= nextTb.isFocus
        ? nextTb.pomodoro.progressSeconds < SettingService.instance.smallestLifeOfTask.value * 60
        : nextTb.rest.progressSeconds < SettingService.instance.smallestLifeOfRest.value * 60;
    if (needDelete) {
      await TimeBlockStore.find.delete(tb.uuid);
    } else {
      await TimeBlockStore.find.save(tb);
    }
  }

  Future<TimeBlock> _stopInnerWIthoutDisk(TimeBlock nextTb) async {
    if (kAnyDebug) {
      BotToast.showText(text: "[stopInner(${state})]");
    }
    _restore();
    await _fnAudioService.stop();
    $curTimeBlock.value = nextTb;
    var tb = $curTimeBlock.justValue.updateTime(endTime: DateTime.now());
    state = PomodoroState.Edit;
    return tb;
  }

  @override
  void onInit() {
    super.onInit();
    _tryContinueLast();
  }

  Future<double> _getConTinueFocusTime() async {
    var event = await TimeBlockStore.find.getRecent(0, 10);
    List<TimeBlock> restBlocks = [];
    DateTime? nextStart = null;
    var lastEnd = event.firstOrNull?.endTime;
    if (lastEnd != null && DateTime.now().difference(lastEnd).inMinutes > 30) {
      this.log.dd(() => "上一次的工作时间太久, 计算为没有专注");
      return 0;
    } else {
      for (var tb in event) {
        if (tb.isRest && tb.rest.progressSeconds > 60) {
          break;
        }
        if (nextStart != null && tb.endTime != null && nextStart.difference(tb.endTime!).inMinutes > 3) {
          break;
        }
        nextStart = tb.startTime;
        if (tb.isFocus) restBlocks.add(tb);
      }
      var sum = restBlocks.sum((e) => e.pomodoro.progressSeconds);
      return sum / 60;
    }
  }

  Future _tryContinueLast() async {
    var recent = await TimeBlockStore.find.getRecent(0, 10);
    var noEndTimeTb =
        recent.where((p0) => p0.isNotEnd).sorted((a, b) => b.startTime!.millisecondsSinceEpoch.compareTo(a.startTime!.millisecondsSinceEpoch));
    if (noEndTimeTb.isEmptyOrNull) return;
    var first = noEndTimeTb.first;
    this.log.dd(() => "上一个没有被结束的是:${first}, noEndTimeTb: ${noEndTimeTb}");

    // state.isIdle && !first.isPause && first.lastModifyTime != null
    this.log.dd(() => "状态: ${state.isIdle}, 上一个时间块没有暂停: ${!first.isPause}, 有最后修改时间: ${first.progressEndTime != null}");

    if (state.isIdle && !first.isPause && first.progressEndTime != null) {
      var dif = DateTime.now().difference(first.progressEndTime!);
      var maxDiff = SettingService.instance.sessionResumptionTime.value;
      if (dif.inMinutes <= maxDiff) {
        this.log.dd(() => "尝试重新开始该时间块:${first}");
        updateTimeBlock(first, needSave: true);
        noEndTimeTb.remove(first);
      } else {
        this.log.dd(() => "上次的修改时间超过了 ${maxDiff}了, diff:${dif}, 不重新开始计算");
      }
    }

    for (var tb in noEndTimeTb) {
      var endTime = tb.startTime!.add((tb.progressSeconds + tb.pauseSeconds).seconds);
      TimeBlockStore.find.save(tb.updateTime(endTime: endTime));
    }
  }

  @override
  void whenDeleteTimeBlock(String uuid) {
    if (curTimeBlock.uuid == uuid) {
      _stopInnerWIthoutDisk(TimeBlock.emptyFocus());
    }
  }

  @override
  void whenRemoteUpsertTimeBlock(TimeBlock newTb) {
    //todo 循环保存咋办?
    updateTimeBlock(newTb);
  }
}

extension DesktopExt on PomodoroController {
  void _notifyAdaptive() {
    if (!_settingService.canNotify.value) return;
    SystemSound.play(SystemSoundType.alert);

    // alert
    var unit = TimeRuleController.find.nextCurPomodoroUnit();
    var minutes = curTimeBlock.progressSeconds ~/ 60;
    var title2 = this.isRest ? "已经休息 %s min了//提示用户该休息了".i18n.fill([minutes]) : "已经专注了 %s min了//提示用户该结束专注了".i18n.fill([minutes]);
    var context2 = unit.isRest ? "开始休息吧//可爱".i18n : "开始新的专注吧//积极".i18n;
    this.log.dd(() => "展示通知 ${title2}\n${context2}");
    //todo 测试移动端
    if (PlatformUtils.isMobile || PlatformUtils.isMac) {
      NativeNotificationService2.instance.show(
        title: title2,
        context: context2,
      );
    } else if (PlatformUtils.isDesktop) {
      NativeNotificationService1.instance.show(
        title: title2,
        context: context2,
      );
    }
  }

  void _setSystemTray(String title) async {
    if (!PlatformUtils.isDesktop) return;
    SystemTrayService.instance.title.value = title;
  }

  Future _windowActionOnTimeEnd({
    int recurTime = 0,
  }) async {
    if (!_settingService.canNotify.value) return;
    if (!PlatformUtils.isDesktop) return;
    FocusEndAction type = FocusEndAction.of(_settingService.promodoEndAction.justValue);
    switch (type) {
      case FocusEndAction.POP:
        await $windowService.requestWindowShow(top: false);
      case FocusEndAction.POP_TOP:
        await $windowService.requestWindowShow(top: true);
      default:
        await $windowService.requestWindowShow();
    }
    this.log.dd(() => "on time end, type:${type.name}, recurTime:${recurTime}");
    if (!(await $windowService.isFocus())) {
      if (recurTime >= 5) {
        return;
      }
      await Future.delayed(100.milliseconds);
      if (await $windowService.isFocus()) return;
      _windowActionOnTimeEnd(recurTime: recurTime + 1);
    }
  }
}

extension PomodoroTimerExt on PomodoroController {
  void _clearIfNeed(String uuid) {
    _timerMap.removeWhere((key, value) {
      var notMatch = key != uuid;
      if (notMatch) value.cancel();
      return notMatch;
    });
  }

  void _restore({bool onlyStopTimer = false}) {
    _timerMap.values.forEach((e) => e.cancel());
    _timerMap.clear();
    if (!onlyStopTimer) {
      //todo 跟随 state 走
      _setSystemTray("");
    }
  }

  _setCountDownTimer({
    required void Function() onTimeOut,
    void Function()? onPeriodic,
  }) {
    var originTb = $curTimeBlock.justValue;
    var invoker = StackTrace.current.invoker;
    _restore();
    bool markTimeOut = false;
    // 每隔一秒 刷新下 title
    var timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (originTb.uuid != $curTimeBlock.justValue.uuid) {
        _restore();
        return;
      }
      _clearIfNeed(originTb.uuid);
      // 和当前时间相比 过去了多久
      var leftSeconds = $curTimeBlock.justValue.leftSeconds;
      var progressSeconds = $curTimeBlock.justValue.progressSeconds;
      String title;
      if (leftSeconds < 0) {
        title = "[over time] ".i18n + FnDateUtils.formatDuration_hh_mm(progressSeconds.seconds);
      } else {
        title = FnDateUtils.formatDuration_hh_mm(leftSeconds.seconds);
      }
      _setSystemTray(title);
      if (left.inSeconds > 0) {
        markTimeOut = false;
      }
      if (left.inSeconds <= 0 && markTimeOut == false) {
        markTimeOut = true;
        onTimeOut.call();
      } else {
        onPeriodic?.call();
      }
    });
    fnassert(() => _timerMap[originTb.uuid] == null);
    _timerMap[originTb.uuid] = timer;
  }

  void _setUpRestTimer(TimeBlock tb) {
    _restore();
    fnassert(() => !state.isFocus);
    fnassert(() => $curTimeBlock.value.startTime != null, $curTimeBlock.justValue);
    fnassert(() => state.isRest);
    fnassert(() => tb.isRest, tb);
    var res = tb.rest;
    var restType = res.type;
    if (restType == RestType.COUNT_DOWN.code) {
      _setCountDownTimer(onTimeOut: () async {
        var tb = _ensureOpsOnRest();
        TimeBlockStore.find.save(tb);
        if (!state.isRest || tb.uuid != $curTimeBlock.justValue.uuid) {
          _restore();
          return;
        }
        await _windowActionOnTimeEnd();
        _notifyAdaptive();
      }, onPeriodic: () {
        if (!isRest) {
          _restore();
          return;
        }
        _ensureOpsOnRest();
      });
    } else {
      var timer = Timer.periodic(1.seconds, (timer) {
        if (!isRest) {
          _restore();
          return;
        }
        _setSystemTray(FnDateUtils.formatDuration_hh_mm($curTimeBlock.justValue.rest.progressSeconds.seconds));
        _ensureOpsOnRest();
        _clearIfNeed(tb.uuid);
      });
      fnassert(() => _timerMap[tb.uuid] == null);
      _timerMap[tb.uuid] = timer;
    }
  }

  TimeBlock _ensureOpsOnRest() {
    tryAlertOnOverTime();
    var tb = $curTimeBlock.value;
    $curTimeBlock.value = tb.correctProgressTime(DateTime.now()).correctEndTime();
    ;
    state = tb.leftSeconds < 0 ? PomodoroState.RestTimeEnd : PomodoroState.Rest;
    if (tb.progressSeconds % 60 == 0) TimeBlockStore.find.save(tb);
    return tb;
  }
}

extension PomodoraPatternExt on PomodoroController {
  Future<void> _acceptUnit(PomodoroUnit unit) async {
    if (unit.isFocus) {}
  }
}

extension RestPomodoroControllerExt on PomodoroController {
  Future stopRest({
    bool needDelete = false,
  }) async {
    _restore();
    var tb = $curTimeBlock.justValue;
    fnassert(() => tb.isRest, tb);
    await _markEndTime();
    state = PomodoroState.Edit;
    TimeRuleController.find.next();
    if (needDelete) {
      TimeBlockStore.find.delete(tb.uuid);
    }
  }

  void switchRestType(RestType restType) async {
    var tb = $curTimeBlock.justValue;
    fnassert(() => tb.isRest);
    if (tb.rest.type == restType.code) {
      this.log.dd(() => "rest 状态不需要修改, ${restType}");
      return;
    }
    $curTimeBlock.value = tb.switchRestType(restType);
    if (state == PomodoroState.Rest) {
      _setUpRestTimer($curTimeBlock.justValue);
    }
    await TimeBlockStore.find.save($curTimeBlock.value);
  }

  Future resetRest() async {
    _fnAudioService.stop();
    var tb = $curTimeBlock.justValue;
    //todo 可能没有必要 _restore
    _restore();
    fnassert(() => tb.isRest);
    $curTimeBlock.value = tb.updateRest(mapper: (rest) {
      return rest.copyWith(progressSeconds: 0);
    }).updateTime(
      startTime: DateTime.now(),
    );
    await TimeBlockStore.find.save($curTimeBlock.justValue);
    state = PomodoroState.Rest;
    _setUpRestTimer($curTimeBlock.value);
  }

  Future startRest([TimeBlock? ensureTb]) async {
    if (this.isFocus) {
      await stopFocus(needfeedback: false);
    }
    _fnAudioService.stop();
    if (ensureTb != null) {
      $curTimeBlock.value = ensureTb;
    }
    var tb = $curTimeBlock.justValue;
    fnassert(() => tb.isRest, tb);
    _restore();
    if (tb.startTime == null) {
      $curTimeBlock.value = tb.copyWith(startTime: DateTime.now());
    }

    if (this.isRest) return;
    state = PomodoroState.Rest;

    if ($curTimeBlock.justValue.endTime == null) {
      // 为空的情况下, 会进行动态计算
      var focusMinus = await _getConTinueFocusTime();
      // focusMinus = 460000;
      var factor = _settingService.smartRestFactor.value;
      var needRestMinus = focusMinus / factor;
      var minRestMinus = _settingService.smallestLifeOfRest.value * 1.0;
      needRestMinus = clampDouble(needRestMinus, minRestMinus, _settingService.biggestLifeOfRest.value * 1.0);
      $curTimeBlock.value = $curTimeBlock.justValue.updateRest(mapper: (r) {
        var needSeconds = (needRestMinus * 60) ~/ 30 * 30;
        return r.copyWith(durationSeconds: (needSeconds).toInt());
      });
      var holder = _settingService.showComputeRestTips;
      if (holder.value && needRestMinus > minRestMinus) {
        FnNotification.showTextSnackBar(
            text: "你已经连续专注了%s分钟,为您安排休息%smin".i18n.fill([
              focusMinus.toInt(),
              $curTimeBlock.value.durationSeconds ~/ 60,
            ]),
            action: (
              "不再提示".i18n,
              () {
                holder.value = false;
              }
            ));
      }
    }
    $curTimeBlock.value = $curTimeBlock.justValue.correctProgressTime(DateTime.now()).correctEndTime();
    ;
    await TimeBlockStore.find.save($curTimeBlock.justValue);

    _setUpRestTimer($curTimeBlock.value);

    // var targetSeconds = max(tb.durationSeconds, tb.progressSeconds);
    // if ((targetSeconds / 60).toInt() < needRestMinus.toInt()) {
    //   _requesTimeRestChange(needRestMinus.toInt(), focusMinus);
    // }
  }
}

extension FocusPomodoroControllerExt on PomodoroController {
  Future startFocus([TimeBlock? tb]) async {
    fnassert(() => tb?.startTime?.isAfter(DateTime.now()) != true, [tb]);
    if (state.isRest) {
      await stopRest();
    }
    if (tb != null) {
      $curTimeBlock.value = tb;
    }
    if (this.isFocus) return;
    if ($curTimeBlock.value.durationSeconds ~/ 60 < 1) {
      FnNotification.toast("时间太短啦".i18n);
      return;
    }

    fnassert(() => $curTimeBlock.justValue.isFocus, [tb, $curTimeBlock, state]);

    _fnAudioService.start();

    state = PomodoroState.Focus;
    _restore();

    if ($curTimeBlock.justValue.startTime == null) {
      this.log.dd(() => "从当前时间开始: ${$curTimeBlock.justValue}");
      $curTimeBlock.value = $curTimeBlock.justValue.updateTime(
        startTime: DateTime.now(),
      );
    }
    $curTimeBlock.value = $curTimeBlock.justValue.correctProgressTime(DateTime.now()).correctEndTime();
    // fnassert˚(() => $curTimeBlock.value.isNotEnd, $curTimeBlock.value);
    TimeBlockStore.find.save($curTimeBlock.justValue);

    /*update last task*/
    _settingService.lastTask.value = $curTimeBlock.justValue.pomodoro.title ?? "";
    fnassert(() => $curTimeBlock.justValue.isFocus, $curTimeBlock.justValue);
    this.log.i("start:${$curTimeBlock.justValue}");

    _setCountDownTimer(onTimeOut: () async {
      var tb = _ensureOpsOnFocus();
      TimeBlockStore.find.save(tb);
      await _windowActionOnTimeEnd();
      _notifyAdaptive();
    }, onPeriodic: () {
      _ensureOpsOnFocus();
    });
  }

  pause() async {
    _fnAudioService.pause();

    _restore(onlyStopTimer: true);
    fnassert(() => state == PomodoroState.Focus || state == PomodoroState.FocusTimeEnd, state);
    state = PomodoroState.FocusPause;

    /*修改_curTimeBlock 修改状态, 暂停*/
    var tb = $curTimeBlock.value;
    fnassert(() => tb.isFocus);
    $curTimeBlock.value = tb.updatePromodo(
        mapper: (p) => p.copyWith(logs: [
              ...p.logs,
              ActionLog(
                type: ActionLogType.PAUSE.code,
                time: DateTime.now(),
              ).toJsonStr(),
            ]));
    TimeBlockStore.find.save($curTimeBlock.justValue);
  }

  Future discardFocus({
    TimeBlock? requestTb,
  }) async {
    _restore();
    state = PomodoroState.Edit;
    var tb = requestTb ?? $curTimeBlock.justValue;
    FnUndoController.find.showUndo(
        promopt: "discard this focus".i18n,
        onUndo: () {
          updateTimeBlock(tb);
        });
    await TimeBlockStore.find.delete(tb.uuid);
    await _fnAudioService.stop();
  }

  Future discardRest() async {
    _restore();
    state = PomodoroState.Edit;
    var tb = $curTimeBlock.justValue;
    FnUndoController.find.showUndo(
        promopt: "放弃当前休息//结束当前休息".i18n,
        onUndo: () {
          updateTimeBlock(tb);
        });
    await TimeBlockStore.find.delete(tb.uuid);
    await _fnAudioService.stop();
  }

  Future stopFocus({
    bool needfeedback = true,
  }) async {
    _restore();
    await _fnAudioService.stop();

    var tb = $curTimeBlock.value;
    fnassert(() => tb.isFocus);
    /*修改_curTimeBlock, stop log and end-time*/
    $curTimeBlock.value = tb
        .updatePromodo(
          mapper: (p) => p.copyWith(logs: [
            ...p.logs,
            ActionLog(
              type: ActionLogType.STOP.code,
              time: DateTime.now(),
            ).toJsonStr(),
          ]),
        )
        .updateTime(
          endTime: DateTime.now(),
        );
    /*重置*/
    await _markEndTime();
    state = PomodoroState.Stop;
    TimeRuleController.find.next();
    lastEndFocusTb = $curTimeBlock.justValue;
    fnassert(() => lastEndFocusTb!.endTime != null);
    if (needfeedback) {
      state = PomodoroState.FocusFeedBack;
      feedbackLocker.lock();
      await feedbackLocker.wait();
    }
  }

  resume() async {
    fnassert(() => state == PomodoroState.FocusPause);
    state = PomodoroState.Focus;
    // $fnassert(() => state == PlayerState.paused || state == PlayerState.completed);
    await _fnAudioService.resume();

    /*修改_curTimeBlock*/
    var tb = $curTimeBlock.value;
    fnassert(() => tb.isFocus);
    $curTimeBlock.value = tb.updatePromodo(
        mapper: (p) => p.copyWith(logs: [
              ...p.logs,
              ActionLog(
                type: ActionLogType.RESUME.code,
                time: DateTime.now(),
              ).toJsonStr(),
            ]));
    TimeBlockStore.find.save($curTimeBlock.justValue);

    /*定时器开启*/
    var $hint = 0;
    _setCountDownTimer(onTimeOut: () async {
      var tb = _ensureOpsOnFocus();
      TimeBlockStore.find.save(tb);
      await _windowActionOnTimeEnd();
      _notifyAdaptive();
      /*自动休息*/
    }, onPeriodic: () {
      _ensureOpsOnFocus();
    });
  }

  TimeBlock _ensureOpsOnFocus() {
    tryAlertOnOverTime();
    var tb = $curTimeBlock.value;
    if (tb.startTime == null) {
      tb = tb.updateTime(startTime: DateTime.now());
    }
    $curTimeBlock.value = tb.correctProgressTime(DateTime.now()).correctEndTime();
    state = tb.leftSeconds < 0 ? PomodoroState.FocusTimeEnd : PomodoroState.Focus;
    if (tb.progressSeconds % 60 == 0) TimeBlockStore.find.save(tb);
    return tb;
  }
}

extension RestSmartExt on PomodoroController {
  void _requesTimeRestChange(int needRestMin, int continueFocus) async {
    void _submit() {
      $zenService.updateRest((p0) => p0.copyWith(
            durationSeconds: needRestMin * 60,
          ));
      Get.back();
    }

    var focusNode = FocusNode();
    var timer = Timer.periodic(1.seconds, (timer) {
      focusNode.requestFocus();
    });

    await FnDialog.showDefault(
      autoFocusConfirm: false,
      confirmWidget: ElevatedButton(
          autofocus: true,
          focusNode: focusNode,
          onPressed: () {
            _submit();
          },
          child: Text("Apply")),
      title: "你需要更多的休息".i18n,
      content: Builder(builder: (context) {
        var hintStyle = context.defaultTextStyle.copyWith(
          color: context.primary,
          fontWeight: FontWeight.bold,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "你已经专注了 %s min啦, 多休息一会吧//可爱".i18n.fill([continueFocus]),
              textAlign: TextAlign.center,
            ).paddingSymmetric(horizontal: 12).boxConstraints(
                  maxWidth: Get.width / 4,
                ),
            SizedBox(height: 8.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "Rest "),
                  TextSpan(text: needRestMin.toString(), style: hintStyle.copyWith(fontSize: (hintStyle.fontSize ?? 32) + 3)),
                  TextSpan(text: " min"),
                ],
                style: hintStyle,
              ),
            ),
          ],
        );
      }),
    );
    timer.cancel();
  }
}

extension OverTimeExt on PomodoroController {
  void tryAlertOnOverTime() {
    var leftSeconds = this.curTimeBlock.leftSeconds;
    if (leftSeconds >= 0) return;
    var overTimeReminderMinus = _settingService.overtimeReminder.value;
    var hint = leftSeconds.abs() % (overTimeReminderMinus * 60) == 0;
    if (hint) {
      this.log.dd(() => "超时: ${overTimeReminderMinus} * n 分钟啦");
      _notifyAdaptive();
      // } else {
      //   this.log.dd(() => "没有命中对应的规则: ${leftSeconds}(${left}), ${overTimeReminderMinus}");
    }
  }
}
