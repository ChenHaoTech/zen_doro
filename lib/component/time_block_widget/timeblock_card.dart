import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:duration/duration.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/extends_text_widget/my_special_text_span_builder.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/short_cut/short_cut_view.dart';
import 'package:flutter_pasteboard/component/tag/tag_share.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_edit_extension.dart';
import 'package:flutter_pasteboard/component/timer/feedback_const.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/data_change_listener.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

Widget _buildExtendText(
  String text, {
  TextStyle? style,
}) {
  return ExtendedText(
    text,
    overflow: TextOverflow.ellipsis,
    specialTextSpanBuilder: MySpecialTextSpanBuilder(
      showAtBackground: true,
      textStyle: style,
    ),
    style: style,
  );
}

class TimeBlockCard extends StatefulWidget {
  final TimeBlock timeBlock;
  final bool initEdit;
  final Function(TimeBlock) onSubmit;
  final Function(TimeBlock) onDelete;
  final Function(bool edit)? onEditStateChange;
  final bool autofocus;

  final bool autoNextfocusDuration;
  final bool debug;
  final bool readOnly;

  TimeBlockCard({
    super.key,
    required this.timeBlock,
    required this.onSubmit,
    this.initEdit = false,
    required this.onDelete,
    this.debug = false,
    this.onEditStateChange,
    this.autofocus = true,
    this.autoNextfocusDuration = false,
    this.readOnly = false,
  });

  @override
  State<TimeBlockCard> createState() => _TimeBlockCardState();
}

class _TimeBlockCardState extends State<TimeBlockCard> with TimeBlockChangeStateMixin implements ITimeBlockEditor {
  late bool _edit = widget.initEdit && !widget.readOnly;
  late final __rx = Get.touch(() => Rx(widget.timeBlock), tag: widget.timeBlock.uuid);

  @override
  Rx<TimeBlock> get tbRx => __rx;
  late TimeBlock _origin = widget.timeBlock;

  late final FocusNode _titleFocusNode = FocusNode();
  late final FocusNode _contextFocusNode = FocusNode();
  late final FocusNode _durationFocus = FocusNode();
  late final FocusNode _timeEditorFocus = FocusNode();

  List<FocusNode> get _focusNodeList => [
        if (widget.timeBlock.isFocus) _titleFocusNode,
        _timeEditorFocus,
        _durationFocus,
        if (widget.timeBlock.isFocus) _contextFocusNode,
      ];

  void _updateEditState(bool edit) {
    if (!widget.readOnly) {
      setState(() {
        _edit = edit;
      });
    }
    widget.onEditStateChange?.call(edit);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly) {
      return TimeBlockCardShow(
        tb: widget.timeBlock,
      );
    }
    var inner = (TimeBlock e) {
      Widget widget;
      if (!_edit)
        widget = TimeBlockCardShow(
          tb: e,
          dirty: _origin != tbRx.justValue,
        ).inkWell(
            onTap: () {
              _updateEditState(true);
            },
            hoverColor: Colors.transparent);
      else {
        widget = e.isRest ? _buildEditorForRest() : _buildEditorForFocus();
      }
      return widget.paddingSymmetric(horizontal: 8, vertical: 8);
    }(_origin);
    return inner
            .inkWell(
                onTap: () {
                  _updateEditState(!_edit);
                },
                hoverColor: Colors.transparent)
            .action({
      DismissIntent: SimpleCallbackAction<DismissIntent>(() {
        _updateEditState(false);
      }),
    }).simpleShortcuts({
      FnKeys.cmdS: () {
        _submit();
      },
      FnKeys.cmdBackSpace: () {
        widget.onDelete.call(tbRx.justValue);
      },
      FnActions.FocusNext: () {
        _focusNodeList.next();
      },
      FnActions.FocusPrevious: () {
        _focusNodeList.reversed.next();
      },
    }, isRoot: true) /*.material(
            color: widget.timeBlock.isRest
                ? context.restContainerColor.withOpacity(.3)
                : (widget.timeBlock.color ?? context.pomodoroContainerColor).withOpacity(.3))*/
        ;
  }

  Widget _buildEditorForRest() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gap8,
        buildStartTime(
            autofocus: widget.autofocus,
            focusNode: _timeEditorFocus,
            onEditingComplete: () {
              if (widget.autoNextfocusDuration) {
                _durationFocus.requestFocus();
              }
            }),
        gap8,
        buildPlanDuration(focusNode: _durationFocus),
        gap16,
        _buildBottomBtn(),
      ],
    );
  }

  Widget _buildEditorForFocus() {
    var title = tbRx.value.pomodoro.title?.trim().takeIf((it) => !it.isBlankOrNull);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTitle(title, focusNode: _titleFocusNode, autofocus: widget.autofocus),
        gap8,
        buildStartTime(
            focusNode: _timeEditorFocus,
            onEditingComplete: () {
              if (widget.autoNextfocusDuration) {
                _durationFocus.requestFocus();
              }
            }),
        gap8,
        buildPlanDuration(focusNode: _durationFocus),
        gap16,
        buildFeedbackEditor().center(),
        gap16,
        buildContextEditor(focusNode: _contextFocusNode),
        gap16,
        _buildBottomBtn()
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
      children: [
        if (_edit)
          OutlinedButton(
                  onPressed: () {
                    _updateEditState(false);
                  },
                  child: Icon(Icons.close))
              .guideToolTip(FnKeys.esc)
              .paddingOnly(right: 4),
        Obx(() {
          var isCur = $zenService.curTimeBlock.uuid == tbRx.value.uuid && !$zenService.state.isIdle;
          return FilledButton(
            onPressed: () {
              if (isCur) {
                $zenService.remove(tbRx.justValue);
              } else {
                widget.onDelete.call(tbRx.justValue);
              }
            },
            child: Icon(
              Icons.delete_outline,
            ).guideToolTip(FnKeys.cmdBackSpace),
          ).paddingOnly(
            right: 4,
          );
        }),
        ElevatedButton(
          onPressed: () {
            _submit();
          },
          child: ShortcutTextWidget(
            "SAVE".i18n,
            keySet: FnKeys.cmdS,
          ),
        ).expand(),
      ],
    );
  }

  void _submit() {
    setState(() {
      _updateEditState(false);
      widget.onSubmit.call(tbRx.value);
    });
  }

  @override
  void whenDeleteTimeBlock(String uuid) {
    // pass
  }

  @override
  void whenUpsertBlockChange(TimeBlock newTb) {
    if (!this._edit && widget.timeBlock.uuid == newTb.uuid) {
      if (mounted)
        setState(() {
          tbRx.value = newTb;
          _origin = newTb;
        });
    }
  }
}

class TimeBlockCardShow extends StatefulWidget {
  final TimeBlock tb;
  final bool dirty;

  const TimeBlockCardShow({
    super.key,
    required this.tb,
    this.dirty = false,
  });

  @override
  State<TimeBlockCardShow> createState() => _TimeBlockCardShowState();
}

class _TimeBlockCardShowState extends State<TimeBlockCardShow> {
  Widget _buildShower(TimeBlock e) {
    if (e.isRest) {
      return _buildShowerForRest(e);
    }
    return _buildShowerForFocus(e);
  }

  final padding = EdgeInsets.symmetric(horizontal: 0, vertical: 0);

  Widget _buildShowerForRest(TimeBlock e) {
    var row = Row(
      children: [
        Builder(builder: (context) {
          return Text(
            "REST".i18n,
            style: context.defaultTextStyle.copyWith(fontWeight: FontWeight.bold),
          );
        }),
        gap4,
        Text("${e.startTime?.formate(FnDateUtils.hhmm) ?? "--"} - ${e.endTime?.formate(FnDateUtils.hhmm) ?? "--"}"),
        Spacer(),
        Text(
          prettyDuration(abbreviated: true, e.rest.progressSeconds.seconds),
          style: context.bodySmall.copyWith(color: context.primary),
        ),
      ],
    ).stack(supplier: (self) {
      var factor = 60 * 25;
      return [
        _buildTimerIndicator(e, factor).position(right: -10, top: 0, bottom: 0),
        self,
      ];
    });
    return ListTile(
      contentPadding: padding,
      title: row,
    );
  }

  ListTile _buildShowerForFocus(TimeBlock e) {
    var pomodo = e.pomodoro;
    var indicatorSize = 8.0;
    return ListTile(
      contentPadding: padding,
      title: Obx(() => Row(
            children: [
              Obx(() {
                var text = (pomodo.titleWithoutTag ?? "未指定任务".i18n) + (widget.dirty ? "*" : "");
                return _buildExtendText(text.trim());
              }).expand(),
              ...pomodo.tags.mapToList((e) => TagStore.find.id2tag[e]).whereNotNull().mapToList((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: indicatorSize,
                      width: indicatorSize,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: e.color),
                    ),
                    gap4,
                    Text(
                      e.value,
                      style: context.bodySmall,
                    ),
                  ],
                )
                    .paddingSymmetric(
                      horizontal: 8,
                      vertical: 4,
                    )
                    .material(color: context.onBackground.withOpacity(.1))
                    .onContextTap(() {
                  requestEditTag(e);
                }).paddingSymmetric(horizontal: 2);
              })
            ],
          )),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!pomodo.context.isEmptyOrNull) Text(pomodo.context?.trim() ?? "").paddingOnly(bottom: 8),
          gap8,
          Row(
            children: [
              Text(pomodo.feedback ?? unknow_feedbackEmoji),
              Text("${e.startTime?.formate(FnDateUtils.hhmm) ?? "--"} - ${e.endTime?.formate(FnDateUtils.hhmm) ?? "--"}"),
              Spacer(),
              Text(
                prettyDuration(abbreviated: true, pomodo.progressSeconds.seconds),
                style: context.bodySmall.copyWith(color: context.primary),
              )
            ],
          ).stack(supplier: (self) {
            var factor = 60 * 25;
            return [
              _buildTimerIndicator(e, factor).position(right: -10, top: 0, bottom: 0),
              self,
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildTimerIndicator(TimeBlock e, int factor) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // DebugUtils.log("timeblock_card:399 :${constraints}\n${StackTrace.current}");
        return Container(
          width: ((e.progressSeconds / (factor)) * 60).clamp(0, 200),
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: e.color?.withOpacity(.3),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildShower(widget.tb);
  }
}
