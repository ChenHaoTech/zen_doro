import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/short_cut/short_cut_view.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_edit_extension.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class TimeBlockEditorForDialog extends StatefulWidget {
  TimeBlockEditorForDialog({Key? key, required this.timeBlock, required this.onSubmit, required this.onDelete}) : super(key: key);

  final TimeBlock timeBlock;
  final Function(TimeBlock tb) onSubmit;
  final Function(TimeBlock tb) onDelete;

  @override
  State<TimeBlockEditorForDialog> createState() => _TimeBlockEditorForDialogState();
}

class _TimeBlockEditorForDialogState extends State<TimeBlockEditorForDialog> implements ITimeBlockEditor {
  late final FocusNode _titleFocusNode = FocusNode();
  late final FocusNode _contextFocusNode = FocusNode();
  late final FocusNode _durationFocus = FocusNode();
  late final FocusNode _timeEditorFocus = FocusNode();

  List<FocusNode> get _focusNodeList => [
        if (tbRx.justValue.isFocus) _titleFocusNode,
        _timeEditorFocus,
        _durationFocus,
        if (tbRx.justValue.isFocus) _contextFocusNode,
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CloseButton(
              onPressed: () => Get.back(),
            ),
            debugStrWidget(() => tbRx.justValue.toString()).expand(),
            TextButton(
                onPressed: () {
                  _updateType();
                },
                child: Obx(() => Text(tbRx.value.isFocus ? "转化为休息".i18n : "转化为专注".i18n))).guideToolTip(FnKeys.cmdShiftC),
          ],
        ),
        tbRx.justValue.isFocus ? _buildEditorForFocus() : _buildEditorForRest(),
        gap12,
        _buildBottomBtn(),
      ],
    ).simpleShortcuts({
      FnKeys.cmdS: () {
        $zenService.updateTimeBlock(tbRx.value);
      },
      FnKeys.cmdEnter: () {
        widget.onSubmit.call(tbRx.value);
      },
      FnKeys.cmdShiftC: () => _updateType(),
      FnKeys.cmdBackSpace: () {
        widget.onDelete.call(tbRx.justValue);
      },
      FnActions.FocusNext: () {
        _focusNodeList.next();
      },
      FnActions.FocusPrevious: () {
        _focusNodeList.reversed.next();
      },
    }, isRoot: true);
  }

  void _updateType() {
    setState(() {
      var origin = tbRx.justValue;
      var isFocus = tbRx.justValue.isFocus;
      tbRx.justValue =
          isFocus ? (widget.timeBlock.whenRest() ?? TimeBlock.emptyCountDownRest()) : (widget.timeBlock.whenFocus() ?? TimeBlock.emptyFocus());
      tbRx.justValue = tbRx.justValue.updateTime(startTime: origin.startTime, endTime: origin.endTime);
    });
    _focusNodeList.ensureFocus();
  }

  Widget _buildEditorForRest() {
    return Column(
      key: ValueKey(_rx.justValue.uuid),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gap8,
        buildStartTime(
            autofocus: true,
            focusNode: _timeEditorFocus,
            onEditingComplete: () {
              _durationFocus.requestFocus();
            }),
        gap8,
        buildProgressDuration(focusNode: _durationFocus),
      ],
    );
  }

  Widget _buildEditorForFocus() {
    var title = tbRx.value.pomodoro.title?.trim().takeIf((it) => !it.isBlankOrNull);
    return Column(
      key: ValueKey(_rx.justValue.uuid),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTitle(title, focusNode: _titleFocusNode, autofocus: true),
        gap8,
        buildStartTime(
            autofocus: true,
            focusNode: _timeEditorFocus,
            onEditingComplete: () {
              _durationFocus.requestFocus();
            }),
        gap8,
        buildProgressDuration(focusNode: _durationFocus),
        gap16,
        buildFeedbackEditor().center(),
        gap16,
        buildContextEditor(focusNode: _contextFocusNode),
      ],
    ).simpleShortcuts({
      FnKeys.alt1: () {
        updateFeedback(0);
      },
      FnKeys.alt2: () {
        updateFeedback(1);
      },
      FnKeys.alt3: () {
        updateFeedback(2);
      },
    });
  }

  Row _buildBottomBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Obx(() {
          var uuid = tbRx.value.uuid;
          onQuery(tb) => OutlinedButton(
                onPressed: () {
                  var isCur = $zenService.curTimeBlock.uuid == uuid && !$zenService.state.isIdle;
                  if (isCur) {
                    $zenService.remove(tbRx.justValue);
                  } else {
                    widget.onDelete.call(tbRx.justValue);
                  }
                },
                child: ShortcutTextWidget(
                  "删除".i18n,
                  keySet: FnKeys.cmdBackSpace,
                ),
              );
          onUnQuery() => OutlinedButton(
                onPressed: () {
                  Get.back();
                },
                child: ShortcutTextWidget(
                  "取消".i18n,
                  keySet: FnKeys.esc,
                ),
              );
          return TimeBlockGetterWidget(uuid: uuid, onQuery: onQuery, onUnQuery: onUnQuery);
        }),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit.call(tbRx.value);
          },
          child: ShortcutTextWidget(
            "提交".i18n,
            keySet: FnKeys.cmdEnter,
          ),
        ),
      ],
    );
  }

  @override
  late final _rx = Get.touch(() => Rx(widget.timeBlock), tag: widget.timeBlock.uuid);

  @override
  Rx<TimeBlock> get tbRx => _rx;
}

class TimeBlockGetterWidget extends StatelessWidget {
  const TimeBlockGetterWidget({
    super.key,
    required this.uuid,
    required this.onQuery,
    required this.onUnQuery,
  });

  final String uuid;
  final Widget Function(TimeBlock tb) onQuery;
  final Widget Function() onUnQuery;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: TimeBlockStore.find.query([uuid]),
        builder: (BuildContext context, AsyncSnapshot<List<TimeBlock>> snapshot) {
          var tb = snapshot.data?.where((e) => e.uuid == uuid).firstOrNull;
          if (tb != null) {
            return onQuery(tb);
          } else {
            return onUnQuery();
          }
        });
  }
}
