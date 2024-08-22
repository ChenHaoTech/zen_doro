import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

abstract class FnActions {
// 加5分钟
  static final FnAction AddFiveMinutes = FnAction(
    "快捷加时间".i18n,
    key: "add_five_minutes_action",
    description: "当前专注时间加5分钟/当前休息时间加2分钟".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.equal),
  );

// 减5分钟
  static final FnAction SubtractFiveMinutes = FnAction(
    "快捷减时间".i18n,
    key: "subtract_five_minutes_action",
    description: "当前专注时间减5分钟/当前休息时间减2分钟".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.minus),
  );

  // 重置休息 cmdr
  static final FnAction ResetRest = FnAction(
    "重置休息".i18n,
    key: "reset_rest_action",
    description: "重置当前的休息时间".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyR),
  );

// 开始休息
  static final FnAction StartRest = FnAction(
    "开始休息".i18n,
    key: "start_rest_action",
    description: "从现在开始休息".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyR),
  );

// 聚焦到设置搜索框
  static final FnAction FocusSettingsSearch = FnAction(
    "聚焦到设置搜索框".i18n,
    key: "focus_settings_search_action",
    description: "将焦点移至设置搜索框".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyF),
  );

// 聚焦到下一个焦点
  static final FnAction FocusNext = FnAction(
    "聚焦到下一个焦点".i18n,
    key: "focus_next_action",
    description: "将焦点移至下一个可聚焦元素".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyE),
  );

// 聚焦到上一个焦点
  static final FnAction FocusPrevious = FnAction(
    "聚焦到上一个焦点".i18n,
    key: "focus_previous_action",
    description: "将焦点移至上一个可聚焦元素".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyE),
  );

  //暂停/开始 专注
  static final FnAction ToggleFocus = FnAction(
    "暂停/开始专注".i18n,
    key: "toggle_focus_action",
    description: "切换当前专注的暂停和开始状态".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.enter),
  );
  // 增加时间块, cmd+n
  static final FnAction AddTimeBlock = FnAction(
    "增加时间块".i18n,
    key: "add_time_block_action",
    description: "增加一个时间块".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyN),
  );

// 完成休息
  static final FnAction StopRest = FnAction(
    "完成休息".i18n,
    key: "end_rest_action",
    description: "结束当前的休息".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.enter),
  );

// 结束专注
  static final FnAction StopFocus = FnAction(
    "完成专注".i18n,
    key: "end_focus_action",
    description: "完成当前的专注".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.enter),
  );

// 下一个任务
  static final FnAction NextTask = FnAction(
    "下一个专注".i18n,
    key: "next_task_action",
    description: "切换到下一个专注".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowRight),
  );
  static final FnAction OpenSettingsPage = FnAction(
    "打开设置页".i18n,
    key: "open_settings_page_action",
    description: "打开应用的设置页面".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.comma),
  );
  // ctrl+opt+shift+downarr 下载
  static final FnAction Download = FnAction(
    "下载".i18n,
    key: "download_action",
    description: "主动下载".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowDown),
  );

  static final FnAction ToggleMiniWindow = FnAction(
    "切换mini窗口".i18n,
    key: "toggle_mini_window_action",
    description: "切换到mini窗口模式".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyI),
  );

// 关闭当前窗口
  static final FnAction CloseCurrentWindow = FnAction(
    "关闭当前窗口".i18n,
    key: "close_current_window_action",
    description: "关闭当前活动窗口".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyW),
  );

  // 开始专注, cmdenter
  static final FnAction StartFocus = FnAction(
    "开始专注".i18n,
    key: "start_focus_action",
    description: "开始当前的专注时间".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.enter),
  );

// 切换静音
  static final FnAction ToggleMute = FnAction(
    "切换静音".i18n,
    key: "toggle_mute_action",
    description: "切换当前的静音状态".i18n,
    keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyM),
  );

  // 打开混音调节窗口(f3)
  static final FnAction OpenMixAdjustmentWindow = FnAction(
    "打开混音调节窗口".i18n,
    key: "open_mix_adjustment_window_action",
    description: "打开混音调节窗口".i18n,
    keySet: LogicalKeySet(LogicalKeyboardKey.f3),
  );

// 放弃当前专注
  static final FnAction DiscardCurrentFocus = FnAction(
    "放弃当前专注//完成当前专注".i18n,
    key: "abandon_current_focus_action",
    description: "立即放弃当前的专注时间//完成当前专注".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.backspace),
  );

// 放弃当前休息
  static final FnAction DiscardCurrentRest = FnAction(
    "放弃当前休息//完成当前休息".i18n,
    key: "abandon_current_rest_action",
    description: "立即放弃当前的休息时间//完成当前休息".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.backspace),
  );

// 重置session
  static final FnAction ResetSession = FnAction(
    "重置session".i18n,
    key: "reset_session_action",
    description: "重置当前的会话状态".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.delete),
  );

  // 播放/暂停当前混音组合
  static final FnAction TogglePlayPauseMix = FnAction(
    "播放/暂停当前混音组合".i18n,
    key: "toggle_play_pause_mix_action",
    description: "切换当前混音组合的播放和暂停状态".i18n,
    keySet: LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.enter),
  );

  static void initKeys() {
    registerHotKey(FnActions.AddFiveMinutes);
    registerHotKey(FnActions.SubtractFiveMinutes);
    registerHotKey(FnActions.ResetRest);
    registerHotKey(FnActions.StartRest);
    registerHotKey(FnActions.FocusSettingsSearch);
    registerHotKey(FnActions.FocusNext);
    registerHotKey(FnActions.FocusPrevious);
    registerHotKey(FnActions.ToggleFocus);
    registerHotKey(FnActions.StopRest);
    registerHotKey(FnActions.StopFocus);
    registerHotKey(FnActions.NextTask);
    registerHotKey(FnActions.OpenSettingsPage);
    registerHotKey(FnActions.ToggleMiniWindow);
    registerHotKey(FnActions.CloseCurrentWindow);
    registerHotKey(FnActions.StartFocus);
    registerHotKey(FnActions.ToggleMute);
    registerHotKey(FnActions.DiscardCurrentFocus);
    registerHotKey(FnActions.AddTimeBlock);
    registerHotKey(FnActions.OpenMixAdjustmentWindow);
    registerHotKey(FnActions.DiscardCurrentRest);
    registerHotKey(FnActions.ResetSession);
    registerHotKey(FnActions.TogglePlayPauseMix);
  }

  static void registerHotKey(FnAction action) {
    // 假设的方法，用于注册快捷键与动作
    // 这里需要实现具体的快捷键注册逻辑，可能涉及到设置全局快捷键等
    // 例如: hotkeyManager.register(action.keySet, action.action);
    if (action.globalKeySet != null) {
      globalActions.add(action);
    } else {
      inappactions.add(action);
    }
  }
}

final List<FnAction> inappactions = [];
//todo 处理下全局快捷键的 自定义
final List<FnAction> globalActions = [];

// FnAction(title,descrition,void Function())
class FnAction {
  final String title;
  final String key;
  final String? description;
  LogicalKeySet? keySet;
  HotKey? globalKeySet;
  void Function()? action;

  FnAction(
    this.title, {
    this.description,
    this.action,
    required this.key,
    this.keySet,
    this.globalKeySet,
  });
}
