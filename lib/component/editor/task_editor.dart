import 'dart:math';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/fn_tabview.dart';
import 'package:flutter_pasteboard/component/misc/overlay_button_builder.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

enum RecomentStats { NONE, TAG, HISTORY }

enum RecomentAbility {
  TAG,
  HISTORY,
}

mixin TaskEditorMixin {
  final Rx<Tag?> _tag = Rx(null);
  final RxList<TimeBlock> _historys = RxList();
  final RxInt _curIx = 0.obs;
  final RxList<Tag> _tags = RxList();

  TextEditingController get taskEditController;

  void _onTagTap(Tag tag, int idx) {}

  void _onHistoryTap(TimeBlock tb, int idx) {}

  void _onChange(String value) {}

  void _acceptTag(Tag? tag) {
    if (tag != null) {
      tag = TagStore.find.touch(tag);
    }
    _tag.value = tag;
  }

  void _acceptHistory(
    TimeBlock tb, {
    bool replaceAll = false,
    String? replaceString,
  }) {
    fnassert(() => tb.isFocus, tb);
    if (tb.tags.isNotEmpty) {
      _acceptTag(tb.tags.first);
    }

    var title = tb.pomodoro.titleWithoutTag ?? "";
    var selection = taskEditController.selection;
    if (replaceAll) {
      fnassert(() => replaceString == null);
      taskEditController.text = title;
      taskEditController.selection = TextSelection(
        baseOffset: title.length,
        extentOffset: title.length,
      );
    } else {
      var originText = taskEditController.text;
      var offset = title.length;
      if (replaceString != null) {
        offset = offset - replaceString.length;
        // originText
        var findIdx = max(
          selection.baseOffset - replaceString.length,
          0,
        );
        fnassert(() => originText.contains(replaceString, findIdx), "${replaceString} => ${title}");
        var res = originText.replaceFirst(replaceString, title, findIdx);
        taskEditController.text = res;
      } else {
        taskEditController.text = originText + title;
      }
      taskEditController.selection = TextSelection(
        baseOffset: selection.baseOffset + offset,
        extentOffset: selection.baseOffset + offset,
      );
    }
    _onChange(taskEditController.text);
  }

  Widget _buildTagSuggest({
    bool autoScroll = false,
    bool reverse = false,
  }) {
    List<Widget> tagWidets = [];
    for (var i = 0; i < _tags.length; i++) {
      var e = _tags[i];
      if (e.value.trim().isBlankOrNull != false) {
        continue;
      }
      tagWidets.add(Builder(builder: (context) {
        return Obx(() {
          var selected = i == _curIx.value;
          if (selected && autoScroll) runOnNextFrame(() => Scrollable.ensureVisible(context));
          return _TagWidget(
            selected: selected,
            tag: e,
            onTap: () {
              _onTagTap(e, i);
              /*_setCurIdx(i);
              _onEnterKeyDown();*/
            },
          );
        });
      }));
    }
    if (tagWidets.isEmpty) return emptyWidget;
    // DebugUtils.log("task_editor:147 ${tagWidets.length}\n${StackTrace.current}");
    return Builder(builder: (context) {
      return ListView(
        shrinkWrap: true,
        reverse: reverse,
        children: tagWidets.mapToList((e) => e.paddingSymmetric(horizontal: 8, vertical: 4)),
      ).container(
        color: context.background,
      );
    });
  }

  Future<List<Tag>> _onUpdateTags(String hashHint) async {
    late List<Tag> list;
    if (hashHint.isEmpty) {
      list = await TagStore.find.recent();
    } else {
      list = await TagStore.find.search(hashHint.remove("#"));
    }
    var hashList = list;
    fnassert(() => !hashHint.startsWith("#"), hashHint);
    _tags.value = hashList;
    if (!hashHint.isEmpty && !hashList.any((i) => i.value == hashHint)) {
      _tags.add(Tag.empty(hashHint));
    }
    _tags.removeWhere((e) => e.value.isEmptyOrNull);
    return list;
  }

  Widget _buildHistorySuggest({
    bool autoScroll = false,
    bool reverse = false,
  }) {
    List<Widget> historyWidgets = [];
    for (var i = 0; i < _historys.length; i++) {
      var e = _historys[i];
      if (e.isRest) continue;
      if (e.pomodoro.title?.trim().isBlankOrNull != false) {
        continue;
      }
      historyWidgets.add(Builder(
        builder: (BuildContext context) {
          return Obx(() {
            var selected = i == _curIx.value;
            if (selected && autoScroll && context.findRenderObject() != null) Scrollable.ensureVisible(context);
            return _HistoryWidget(
              onTap: () {
                _onHistoryTap(e, i);
                /*_setCurIdx(i);
                _onEnterKeyDown();*/
              },
              tb: e,
              selected: selected,
            );
          });
        },
      ));
    }
    if (historyWidgets.isEmpty) return emptyWidget;

    return Builder(builder: (context) {
      return ListView(
        shrinkWrap: true,
        reverse: reverse,
        children: historyWidgets.mapToList((e) => e.paddingSymmetric(horizontal: 8, vertical: 4)),
      ).container(
        color: context.background,
      );
    });
  }

  Future<List<TimeBlock>> _fetchHistory(String text) async {
    List<TimeBlock> list;
    if (text.isEmptyOrNull) {
      list = await TimeBlockStore.find.getRecent(0, 50);
    } else {
      list = await TimeBlockStore.find.searchPromodoByContext(text);
    }
    return list;
  }

  void _setHistory(List<TimeBlock> list) {
    var unique = list.where((e) => e.isFocus).toList().unique(
          keyMapper: (e) => e.tryPromodo?.title,
        );
    _historys.value = unique;
  }
}

/**
 *
 * @author chenhao91
 * @date   2024/4/3
 */
class TaskEditor extends StatefulWidget {
  final FocusNode? focusNode;
  final bool autofocus;
  final TextEditingController controller;
  final Function(String val)? onChanged;
  final Function(Tag? tag) onTagUpdate;
  final void Function()? onEditingComplete;
  final void Function()? onCancel;
  final void Function(String val)? onSubmit;
  final RecomentStats initSuggestionStats;
  final List<RecomentAbility> recomentAbility;
  final bool autoScroll;
  final bool reverse;
  final Tag? initTag;

  const TaskEditor({
    Key? key,
    this.focusNode,
    required this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.reverse = true,
    this.autofocus = true,
    this.autoScroll = true,
    this.initSuggestionStats = RecomentStats.NONE,
    this.recomentAbility = const [RecomentAbility.TAG, RecomentAbility.HISTORY],
    this.onCancel,
    this.onSubmit,
    required this.onTagUpdate,
    this.initTag,
  }) : super(key: key);

  @override
  TaskEditorState createState() => TaskEditorState();
}

class TaskEditorState extends State<TaskEditor> with TaskEditorMixin {
  late FocusNode taskEditFocusNode = widget.focusNode ?? FocusNode();

  @override
  TextEditingController get taskEditController => widget.controller;

  void _setCurIdx(int idx) {
    if (_recommentStats.justValue == RecomentStats.TAG) {
      _curIx.value = clampInt(idx, 0, _tags.length - 1);
    } else if (_recommentStats.justValue == RecomentStats.HISTORY) {
      _curIx.value = clampInt(idx, 0, _historys.length - 1);
    } else {
      _curIx.value = 0;
    }
    // taskEditFocusNode.requestFocus();
  }

  int _historyIdx = -1;
  late final Rx<RecomentStats> _recommentStats = Rx(widget.recomentAbility.isNotEmpty ? widget.initSuggestionStats : RecomentStats.NONE);

  @override
  Widget build(BuildContext context) {
    if (widget.recomentAbility.isEmptyOrNull) return buildBody(context);
    return PortalTarget(
      anchor: Aligned(
        follower: widget.reverse ? Alignment.bottomLeft : Alignment.topLeft,
        target: widget.reverse ? Alignment.topLeft : Alignment.bottomLeft,
        widthFactor: 1,
        // heightFactor: 5,
      ),
      portalFollower: buildOverlayInner().boxConstraints(maxHeight: 240),
      child: buildBody(context),
    );
    // if (PlatformUtils.isMobile) {
    //   return ;
    // }
    return OverlayButtonBuilder(
      anchor: widget.reverse ? OverlayAnchor.dropUp : OverlayAnchor.dropDown,
      overlay: buildOverlay(),
      showOverlay: true,
      child: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Focus(
      onFocusChange: (focus) {
        if (!focus) markNone();
      },
      child: _buildTextEditor().action({
        DismissIntent: SimpleCallbackAction<DismissIntent>(() {
          markNone();
          Actions.invoke<DismissIntent>(
            context,
            const DismissIntent(),
          );
          widget.onCancel?.call();
        })
      }),
    );
  }

  Widget buildOverlay() {
    // return Text("fuck");
    return buildOverlayInner().easyTap(onTap: () {
      _recommentStats.value = RecomentStats.NONE;
    }).boxConstraints(maxHeight: Get.height * .8, maxWidth: Get.width * .8);
  }

  Widget buildOverlayInner() {
    return Obx(() {
      if (_recommentStats.value == RecomentStats.TAG && widget.recomentAbility.contains(RecomentAbility.TAG)) {
        return _buildTagSuggest(
          autoScroll: widget.autoScroll,
          reverse: widget.reverse,
        );
      } else if (_recommentStats.value == RecomentStats.HISTORY && widget.recomentAbility.contains(RecomentAbility.HISTORY)) {
        return _buildHistorySuggest(
          autoScroll: widget.autoScroll,
          reverse: widget.reverse,
        );
      } else {
        return emptyWidget;
      }
    }).textFieldTapRegion();
  }

  @override
  void _acceptHistory(TimeBlock tb, {bool replaceAll = false, String? replaceString}) {
    super._acceptHistory(tb, replaceAll: replaceAll, replaceString: replaceString);
    if (tb.tags.isNotEmpty) {
      _acceptTag(tb.tags.first);
    }
  }

  @override
  void _acceptTag(Tag? tag) {
    super._acceptTag(tag);
    widget.onTagUpdate.call(tag);
  }

  Widget _buildTextEditor() {
    return TextField(
            autofocus: widget.autofocus,
            maxLines: 1,
            controller: taskEditController,
            focusNode: taskEditFocusNode,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: '输入你想专注的事情//番茄钟'.i18n + "," + "按#选择标签".i18n,
              prefixIcon: Obx(() {
                var tag = _tag.value;
                if (tag == null) return Icon(Icons.tag).inkWell(onTap: () => markTagMode());
                return Chip(
                  backgroundColor: tag.color,
                  label: Text(
                    "${tag.value}",
                    style: context.defaultTextStyle.withColor(context.dynamicTxtColor(
                      tag.color,
                    )),
                  ),
                  deleteIconColor: context.dynamicTxtColor(
                    tag.color,
                  ),
                  onDeleted: () => _acceptTag(null),
                ).paddingOnly(left: 12, right: 4);
              }),
              border: InputBorder.none,
            ),
            onSubmitted: (val) {
              _onEnterKeyDown();
            },
            onEditingComplete: () {
              tryEndCompiete();
            },
            onTap: () {
              if (_recommentStats.justValue == RecomentStats.NONE) {
                markCommonMode();
              } else {
                markNone();
              }
            },
            onTapOutside: (_) {
              markNone();
            },
            onChanged: (val) {
              DebugUtils.decodeDebugMode(val);
              widget.onChanged?.call(val);
              _onContextChange();
            })
        .tooltip("${FnModifyString.adptiveMeta} ${FnModifyString.up}/${FnModifyString.down} switch history")
        .paddingSymmetric(
          horizontal: 12,
        )
        .action({}).focus(
      onKey: (node, event) {
        if (!event.isDownKeyEvent) return KeyEventResult.ignored;
        if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
          if (taskEditController.isAtStart) {
            _acceptTag(null);
            return KeyEventResult.handled;
          }
        }
        if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          _onUp(accept: event.onlyMetaPressedAdaptive);
          return (event.onlyMetaPressedAdaptive || event.onlyKey(LogicalKeyboardKey.arrowDown)) ? KeyEventResult.handled : KeyEventResult.ignored;
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          _onDown(accept: event.onlyMetaPressedAdaptive);
          return (event.onlyMetaPressedAdaptive || event.onlyKey(LogicalKeyboardKey.arrowDown)) ? KeyEventResult.handled : KeyEventResult.ignored;
        } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          runOnNextFrame(() {
            if (cursorChar() == " ") markCommonMode();
          });
        } else if (event.isKeyPressed(LogicalKeyboardKey.digit3) && RawKeyboard.instance.physicalKeysPressed.containsAny(FnKeys.shiftPhy)) {
          markTagMode();
        }
        return KeyEventResult.ignored;
      },
    );
  }

  void markNone() {
    _recommentStats.trigger(RecomentStats.NONE);
  }

  bool tryEndCompiete() {
    if (_recommentStats.value == RecomentStats.NONE ||
        (_historys.isEmpty && _recommentStats.value == RecomentStats.HISTORY) ||
        (_tags.isEmpty && _recommentStats.value == RecomentStats.TAG)) {
      widget.onEditingComplete?.call();
      widget.onSubmit?.call(taskEditController.text);
      return true;
    }
    return false;
  }

  void _onDown({
    bool accept = false,
  }) {
    var factor = (widget.reverse ? -1 : 1);
    if (accept) {
      _historyIdx = clampInt(_historyIdx + 1 * factor, 0, _historys.length - 1);
      var item = _historys.getNullable(_historyIdx);
      if (item != null) {
        _acceptHistory(item, replaceAll: true);
      }
    } else {
      _setCurIdx(_curIx.justValue + 1 * factor);
    }
  }

  void _onUp({
    bool accept = false,
  }) {
    var factor = (widget.reverse ? -1 : 1);
    if (accept) {
      _historyIdx = clampInt(_historyIdx - 1 * factor, 0, _historys.length - 1);
      var item = _historys.getNullable(_historyIdx);
      if (item != null) {
        _acceptHistory(item, replaceAll: true);
      }
    } else {
      _setCurIdx(_curIx.justValue - 1 * factor);
    }
  }

  void _onEnterKeyDown() {
    var idx = _curIx.value;
    if (_recommentStats.justValue == RecomentStats.TAG) {
      var tag = _tags.getNullable(idx);
      taskEditController.removeLastUntil((p0) => p0.startsWith("#"));
      if (tag == null) return;
      tag = TagStore.find.touch(tag);
      _acceptTag(tag);
      markCommonMode();
    } else if (_recommentStats.justValue == RecomentStats.HISTORY) {
      var history = _historys.getNullable(idx);
      if (history == null) return;
      _acceptHistory(history, replaceAll: true);
      _recommentStats.value = RecomentStats.NONE;
    }
  }

  void markTagMode() {
    runOnNextFrame(() {
      _recommentStats.value = RecomentStats.TAG;
      _onModeChange();
    });
  }

  void markCommonMode() {
    runOnNextFrame(() {
      _recommentStats.value = RecomentStats.HISTORY;
      _onModeChange();
    });
  }

  String cursorChar() {
    var textEditingValue = taskEditController.value;
    final selection = textEditingValue.selection;
    final text = textEditingValue.text;
    if (!selection.isCollapsed || selection.baseOffset <= 0) return "";
    return text.substring(selection.baseOffset - 1);
  }

  String extraTagHint() {
    fnassert(() => _recommentStats.justValue == RecomentStats.TAG);
    // 查询的推荐就是 #符号和当前光标后面的， 如果光标有选中什么文本, 那就不推荐
    var textEditingValue = taskEditController.value;
    final selection = textEditingValue.selection;
    final text = textEditingValue.text;
    final cursorPosition = selection.baseOffset;
    var idx = text.lastIndexOf("#");
    if (idx < 0 || idx > cursorPosition || idx >= text.length) return "";
    return text.substring(idx, cursorPosition);
  }

  void _onContextChange() async {
    final selection = taskEditController.selection;
    final text = taskEditController.text;
    if (text.isEmpty) {
      _recommentStats.value = RecomentStats.HISTORY;
    }
    if (text.isNotEmpty && _recommentStats.justValue == RecomentStats.NONE) {
      markCommonMode();
      return;
    }
    if (!selection.isCollapsed) {
      return;
    }
    _curIx.value = 0;
    if (_recommentStats.justValue == RecomentStats.NONE) return;

    await _onModeChange();
  }

  Future<void> _onModeChange() async {
    String text = taskEditController.text;
    if (_recommentStats.justValue == RecomentStats.TAG) {
      String hashHint = extraTagHint().remove("#").trim();
      List<Tag> list = await _onUpdateTags(hashHint);

      this.log.dd(() => "_onTaskContextChange(TAG):${text}, hashHint: ${hashHint}, ${_tags.lastValue}, now:${_tags.justValue}, list:${list}");
    } else if (_recommentStats.justValue == RecomentStats.HISTORY) {
      var list = await _fetchHistory(text);
      if (_recommentStats.justValue == RecomentStats.HISTORY) {
        _setHistory(list);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化 recent 数据
    if (widget.recomentAbility.contains(RecomentAbility.HISTORY)) {
      _fetchHistory(widget.controller.text).then(
        (value) => _setHistory(value),
      );
    }
    _tag.value = widget.initTag;
  }

  @override
  void _onTagTap(Tag tag, int i) {
    TagStore.find.touch(tag);
    _setCurIdx(i);
    _onEnterKeyDown();
  }

  @override
  void _onHistoryTap(TimeBlock tb, int i) {
    _setCurIdx(i);
    _onEnterKeyDown();
  }

  @override
  void _onChange(String value) {
    widget.onChanged?.call(value);
  }
}

class _TagWidget extends StatelessWidget {
  final bool selected;
  final Tag tag;
  final void Function()? onTap;
  final FocusNode? focusNode;

  const _TagWidget({
    super.key,
    this.selected = false,
    required this.tag,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var match = TagStore.find.all.any((e) => e.value == tag.value);
      var focusColor = context.onBackground.withOpacity(.1);
      return ListTile(
        focusNode: focusNode,
        title: Row(
          children: [
            Chip(
                backgroundColor: tag.color,
                label: Text(
                  match ? "${tag.value}" : "create \"${tag.value}\"",
                  style: context.defaultTextStyle.withColor(context.dynamicTxtColor(
                    tag.color,
                  )),
                )),
            Spacer(),
          ],
        ),
        selected: selected,
        onTap: onTap,
        leading: Icon(Icons.tag),
      ).container(
          boxShadow: selected
              ? [
                  buildBoxShadow(focusColor),
                ]
              : []);
    });
  }
}

class _HistoryWidget extends StatelessWidget {
  final bool selected;
  final TimeBlock tb;
  final FocusNode? focusNode;
  final void Function()? onTap;

  const _HistoryWidget({
    super.key,
    this.selected = false,
    required this.tb,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var pomodoro = tb.pomodoro;
      var title = (pomodoro.titleWithoutTag ?? "").trim();
      if (title.isEmptyOrNull) return emptyWidget;
      var focusColor = context.onBackground.withOpacity(.1);
      return ListTile(
        focusNode: focusNode,
        selected: selected,
        onTap: onTap,
        leading: Icon(Icons.history),
        title: Builder(builder: (context) {
          var tag = tb.tags.firstOrNull;
          return Row(
            children: [
              Text(
                title + " ",
                style: context.defaultTextStyle,
                overflow: TextOverflow.ellipsis,
              ).expand(),
              if (tag != null)
                Chip(
                    backgroundColor: tag.color,
                    label: Text(
                      "${tag.value}",
                      style: context.defaultTextStyle.withColor(context.dynamicTxtColor(
                        tag.color,
                      )),
                    )),
            ],
          );
        }),
        subtitle: Text(
          "${DateTimeFormat.relative(tb.progressEndTime ?? DateTime.now(), appendIfAfter: "ago".i18n)}",
          style: context.defaultTextStyle.withOpacity(selected ? .8 : .2),
        ),
      ).container(
          boxShadow: selected
              ? [
                  buildBoxShadow(focusColor),
                ]
              : []);
    });
  }
}

BoxShadow buildBoxShadow(Color focusColor) {
  return BoxShadow(
    color: focusColor.withOpacity(.05),
    spreadRadius: 3,
    blurRadius: .1,
    offset: Offset(0, 3), // 改变阴影的位置
  );
}

class TaskEditorSimple extends StatefulWidget {
  final TextEditingController controller;
  final Function(String val)? onChanged;
  final Function(Tag? tag) onTagUpdate;
  final bool autofocus;
  final FocusNode? focusNode;
  final Tag? initTag;

  const TaskEditorSimple({
    super.key,
    required this.controller,
    this.onChanged,
    required this.autofocus,
    required this.focusNode,
    required this.onTagUpdate,
    required this.initTag,
  });

  @override
  State<TaskEditorSimple> createState() => _TaskEditorSimpleState();
}

class _TaskEditorSimpleState extends State<TaskEditorSimple> with TaskEditorMixin {
  @override
  TextEditingController get taskEditController => widget.controller;
  late FocusNode taskEditFocusNode = widget.focusNode ?? FocusNode();
  final RxString _searchHistoryKey = RxString("");
  final RxInt idx = RxInt(0);
  final int allIdx = 0;
  final int tagIdx = 2;
  final int historyIdx = 1;

  void _ensureIdx(int size) {
    if (idx.justValue >= size) {
      idx.value = -1;
    }
  }

  @override
  void initState() {
    super.initState();
    _tag.value = widget.initTag;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        autofocus: widget.autofocus,
        maxLines: 1,
        controller: taskEditController,
        focusNode: taskEditFocusNode,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            hintText: 'enter you want to focus on'.i18n,
            border: InputBorder.none,
            prefixIcon: Obx(() {
              var tag = _tag.value;
              if (tag == null) return Icon(Icons.tag).inkWell(onTap: () => _requestSearch(initialIndex: tagIdx));
              return Chip(
                backgroundColor: tag.color,
                label: Text(
                  "${tag.value}",
                  style: context.defaultTextStyle.withColor(context.dynamicTxtColor(
                    tag.color,
                  )),
                ),
                deleteIconColor: context.dynamicTxtColor(
                  tag.color,
                ),
                onDeleted: () => _acceptTag(null),
              ).paddingOnly(left: 12, right: 4);
            }),
            suffixIcon: Icon(Icons.manage_search).inkWell(
              onTap: () {
                _requestSearch();
              },
            )),
        onSubmitted: (val) {
          _onChange(val);
        },
        onEditingComplete: () {
          _onChange(taskEditController.text);
        },
        onChanged: (val) {
          DebugUtils.decodeDebugMode(val);
          _onChange(val);
        });
  }

  void _requestSearch({
    int? initialIndex,
  }) {
    _ensureIdx(0);
    final textEditingController = TextEditingController(text: _searchHistoryKey.justValue);
    void _refresh(String val) async {
      _searchHistoryKey.justValue = val;
      var list = await _fetchHistory(val);
      _setHistory(list);
      _onUpdateTags(val);
    }

    _refresh(textEditingController.text);

    var innerWidget = Column(
      children: [
        TextField(
          controller: textEditingController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索...'.i18n,
            suffixIcon: Icon(Icons.search),
          ),
          onSubmitted: (val) => _refresh(val),
          onChanged: (val) => _refresh(val),
        ),
        Obx(() {
          return FnTabView(
            initialIndex: initialIndex ?? allIdx,
            tabBinding: [
              (
                Text("ALL".i18n),
                ListView(
                  children: [
                    ..._buildTags(),
                    ..._buildHistorys(),
                  ],
                )
              ),
              (
                Text("历史记录".i18n),
                ListView(
                  children: [..._buildHistorys()],
                )
              ),
              (
                Text("标签".i18n),
                ListView(
                  children: [
                    ..._buildTags(),
                  ],
                )
              ),
            ],
            onChange: (idx) => _ensureIdx(0),
          );
        }).focus().expand(),
      ],
    ).focus(onKey: (node, event) {
      if (!event.isDownKeyEvent) return KeyEventResult.ignored;
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        // idx.value = clampInt(idx.value, 0, max);
        return KeyEventResult.handled;
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        FocusManager.instance.primaryFocus?.nextFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
    if (PlatformUtils.isDesktop) {
      FnDialog.show(Dialog(
        insetPadding: EdgeInsets.all(32),
        child: innerWidget.paddingAll(12),
      ));
    } else {
      FnBottomSheet.bottomSheet(
        innerWidget,
      );
    }
  }

  List<Widget> _buildHistorys() {
    List<Widget> historyWidgets = [];
    for (var history in _historys) {
      if (!(history.tryPromodo?.title.isEmptyOrNull ?? true)) {
        historyWidgets.add(_HistoryWidget(
          tb: history,
          onTap: () {
            _onHistoryTap(history, -1);
            Get.back();
          },
        ));
      }
    }
    return historyWidgets;
  }

  List<Widget> _buildTags() {
    List<Widget> tagWidgets = [];
    for (var tag in _tags) {
      tagWidgets.add(_TagWidget(
        tag: tag,
        onTap: () {
          _onTagTap(tag, -1);
          Get.back();
        },
      ));
    }
    return tagWidgets;
  }

  @override
  void _onChange(String value) {
    widget.onChanged?.call(value);
  }

  @override
  void _onHistoryTap(TimeBlock tb, int idx) {
    _acceptHistory(tb, replaceAll: true);
  }

  @override
  void _acceptHistory(TimeBlock tb, {bool replaceAll = false, String? replaceString}) {
    super._acceptHistory(tb, replaceAll: replaceAll, replaceString: replaceString);
    if (tb.tags.isNotEmpty) {
      _acceptTag(tb.tags.first);
    }
  }

  @override
  void _acceptTag(Tag? tag) {
    super._acceptTag(tag);
    widget.onTagUpdate.call(tag);
  }

  @override
  void _onTagTap(Tag tag, int idx) {
    _acceptTag(tag);
    TagStore.find.touch(tag);
  }
}
