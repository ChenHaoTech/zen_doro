import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_edit_extension.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:ui_extension/ui_extension.dart';

enum TimeBlockEditorMobileMode {
  all,
  editTimeForPlan,
  editTimeOnPlaying,
  edit,
  editContext,
}

class TimeBlockEditorMobile extends StatefulWidget {
  final TimeBlock tb;
  final Function(TimeBlock tb) onSubmit;
  final Function()? onCancel;
  final Function(TimeBlock tb)? onDelete;
  final TimeBlockEditorMobileMode mode;

  const TimeBlockEditorMobile({
    super.key,
    required this.onSubmit,
    this.onDelete,
    required this.tb,
    this.mode = TimeBlockEditorMobileMode.all,
    this.onCancel,
  });

  @override
  State<TimeBlockEditorMobile> createState() => _TimeBlockEditorMobileState();
}

class _TimeBlockEditorMobileState extends State<TimeBlockEditorMobile> with KeyBoardArrowMixin implements ITimeBlockEditor {
  late final FocusNode _titleFocusNode = FocusNode(debugLabel: "_titleFocusNode");
  late final FocusNode _contextFocusNode = FocusNode(debugLabel: "_contextFocusNode");
  late final FocusNode _durationFocus = FocusNode(debugLabel: "_durationFocus");
  late final FocusNode _progressFocus = FocusNode(debugLabel: "_progressFocus");
  late final FocusNode _timeEditorFocus = FocusNode(debugLabel: "_timeEditorFocus");
  late final FocusNode _timeEditorFocusAll = FocusNode(debugLabel: "_timeEditorFocusAll");
  late final TextEditingController contextEditController = TextEditingController();
  final RxBool _focus = RxBool(false);

  @override
  List<FocusNode> get focusNodeList => [
        if (widget.tb.isFocus) _titleFocusNode,
        _timeEditorFocus,
        _progressFocus,
        _durationFocus,
        if (widget.tb.isFocus) _contextFocusNode,
      ];

  @override
  void initState() {
    super.initState();
    if (widget.tb.startTime == null) {
      tbRx.value = tbRx.justValue.updateTime(startTime: DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: DraggableScrollableSheet(
          initialChildSize: 1,
          minChildSize: 0.4,
          maxChildSize: 1,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: widget.tb.isFocus ? _buildForFocus() : _buildForRest(),
            );
          }),
      onFocusChange: (focus) => _focus.value = focus,
    );
  }

  Widget _buildSubBtnAdaptive() {
    return Obx(() {
      return _focus.value ? emptyWidget : _buildSubBtn().paddingOnly(bottom: 12).center();
    });
  }

  bool get autoScroll => !PlatformUtils.isMobile ? false : true;

  Widget _buildForRest() {
    return KeyboardActions(
      autoScroll: autoScroll,
      config: KeyboardActionsConfig(keyboardBarColor: context.background, actions: [
        KeyboardActionsItem(
            focusNode: _timeEditorFocusAll,
            displayActionBar: false,
            displayArrows: false,
            displayDoneButton: false,
            footerBuilder: (context) {
              return buildToolbar(Row(
                children: [
                  ...updateStartTimeBtns,
                  Spacer(),
                  ...arrowBtns,
                  ..._actionBtns,
                ],
              ));
            }),
        KeyboardActionsItem(
            focusNode: _durationFocus,
            displayActionBar: false,
            displayArrows: false,
            displayDoneButton: false,
            footerBuilder: (context) {
              return buildToolbar(Row(
                children: [
                  ...updateDurationTimeBtns,
                  Spacer(),
                  ...arrowBtns,
                  ..._actionBtns,
                ],
              ));
            }),
        KeyboardActionsItem(
            focusNode: _progressFocus,
            displayActionBar: false,
            displayArrows: false,
            displayDoneButton: false,
            footerBuilder: (context) {
              return buildToolbar(Row(
                children: [
                  Spacer(),
                  ...arrowBtns,
                  ..._actionBtns,
                ],
              ));
            }),
      ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          debugTb(),
          _buildtopBar(),
          buildStartTime(
              autofocus: true,
              focusNode: _timeEditorFocus,
              onEditingComplete: () {
                _durationFocus.requestFocus();
              }).focus(focusNode: _timeEditorFocusAll),
          gap8,
          buildProgressDuration(focusNode: _progressFocus),
          _buildSubBtnAdaptive(),
        ],
      ),
    );
  }

  late final textEditingController = TextEditingController(text: tbRx.value.tryPromodo?.title);

  List<Widget> get _actionBtns => [
        _buildSubBtn(),
      ];

  ElevatedButton _buildSubBtn() {
    return ElevatedButton(
        onPressed: () {
          widget.onSubmit.call(tbRx.justValue);
        },
        child: Text("提交".i18n));
  }

  Widget _buildForFocus() {
    return KeyboardActions(
      autoScroll: autoScroll,
      config: KeyboardActionsConfig(keyboardBarColor: context.background, actions: [
        KeyboardActionsItem(
            displayActionBar: false,
            displayArrows: false,
            displayDoneButton: false,
            focusNode: _titleFocusNode,
            footerBuilder: (context) {
              var row = Row(
                children: [
                  Spacer(),
                  ...arrowBtns,
                  ..._actionBtns,
                ],
              );
              return buildToolbar(row);
            }),
        KeyboardActionsItem(
            focusNode: _timeEditorFocusAll,
            displayActionBar: false,
            displayArrows: false,
            displayDoneButton: false,
            footerBuilder: (context) {
              return buildToolbar(Row(
                children: [
                  ...updateStartTimeBtns,
                  Spacer(),
                  ...arrowBtns,
                  ..._actionBtns,
                ],
              ));
            }),
        KeyboardActionsItem(
            focusNode: _durationFocus,
            displayActionBar: false,
            displayArrows: false,
            displayDoneButton: false,
            footerBuilder: (context) {
              return buildToolbar(Row(
                children: [
                  ...updateDurationTimeBtns,
                  Spacer(),
                  ...arrowBtns,
                  ..._actionBtns,
                ],
              ));
            }),
        KeyboardActionsItem(
            focusNode: _contextFocusNode,
            displayActionBar: false,
            displayArrows: false,
            displayDoneButton: false,
            footerBuilder: (context) {
              return buildToolbar(Row(
                children: [
                  gap4,
                  Icon(
                    Icons.access_time_rounded,
                  ).inkWell(onTap: () {
                    contextEditController.insertTextAtCursor("${DateTime.now().formate(FnDateUtils.hhmm)} ");
                  }),
                  Spacer(),
                  ...arrowBtns,
                  ..._actionBtns,
                ],
              ));
            }),
      ]),
      child: Builder(builder: (context) {
        var children = _buildOnMode();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      }),
    );
  }

  List<Widget> _buildOnMode() {
    return [
      debugTb(),
      _buildtopBar(),
      if (widget.mode == TimeBlockEditorMobileMode.all) ...[
        buildTitleRaw(
          reverse: false,
          focusNode: _titleFocusNode,
          autofocus: true,
          textEditingController: textEditingController,
        ),
        buildStartTime(
            autofocus: false,
            focusNode: _timeEditorFocus,
            onEditingComplete: () {
              _progressFocus.requestFocus();
            }).focus(focusNode: _timeEditorFocusAll),
        buildProgressDuration(focusNode: _progressFocus),
        buildFeedbackEditor().center(),
        buildContextEditor(
          focusNode: _contextFocusNode,
          controller: contextEditController,
          autofocus: false,
        ),
      ],
      if (widget.mode == TimeBlockEditorMobileMode.editContext) ...[
        buildContextEditor(
          focusNode: _contextFocusNode,
          controller: contextEditController,
          autofocus: true,
        ),
      ],
      if (widget.mode == TimeBlockEditorMobileMode.edit) ...[
        buildTitleRaw(
          reverse: false,
          focusNode: _titleFocusNode,
          autofocus: true,
          textEditingController: textEditingController,
        ),
        buildStartTime(
            autofocus: true,
            focusNode: _timeEditorFocus,
            onEditingComplete: () {
              _durationFocus.requestFocus();
            }).focus(focusNode: _timeEditorFocusAll),
        buildPlanDuration(focusNode: _durationFocus),
      ],
      if (widget.mode == TimeBlockEditorMobileMode.editTimeForPlan) ...[
        buildStartTime(
            autofocus: true,
            focusNode: _timeEditorFocus,
            onEditingComplete: () {
              _durationFocus.requestFocus();
            }).focus(focusNode: _timeEditorFocusAll),
        buildPlanDuration(focusNode: _durationFocus),
      ],
      if (widget.mode == TimeBlockEditorMobileMode.editTimeOnPlaying) ...[
        buildStartTime(
            autofocus: true,
            focusNode: _timeEditorFocus,
            onEditingComplete: () {
              _durationFocus.requestFocus();
            }).focus(focusNode: _timeEditorFocusAll),
        gap8,
        buildPlanDuration(focusNode: _durationFocus),
      ],
      _buildSubBtnAdaptive(),
    ];
  }

  Widget _buildtopBar() {
    return Row(
      children: [
        gap12,
        Icon(
          Icons.keyboard_arrow_down_outlined,
        ).inkWell(onTap: () {
          widget.onCancel?.call();
        }),
        Builder(builder: (_) {
          if (widget.tb.isRest) return Text("休息".i18n);
          return emptyWidget;
        }).expand(),
        if (widget.onDelete != null)
          Icon(
            Icons.delete_rounded,
            color: context.cs.error,
          ).inkWell(onTap: () {
            widget.onDelete!.call(tbRx.justValue);
          }),
        gap12,
      ],
    ).paddingOnly(bottom: 4);
  }

  late final Rx<TimeBlock> _rx = Get.touch(() => Rx(widget.tb), tag: widget.tb.uuid);

  @override
  Rx<TimeBlock> get tbRx => _rx;
}

abstract mixin class KeyBoardArrowMixin {
  List<FocusNode> get focusNodeList;

  KeyboardActionsItem buildSimpleKAI({
    required FocusNode focusNode,
    Widget? child,
  }) {
    return KeyboardActionsItem(
        displayActionBar: false,
        displayArrows: false,
        displayDoneButton: false,
        focusNode: focusNode,
        footerBuilder: child == null
            ? null
            : (context) {
                return buildToolbar(child!);
              });
  }

  List<Widget> get arrowBtns => [
        Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.keyboard_arrow_up),
            tooltip: 'Previous',
            iconSize: IconTheme.of(context).size!,
            color: IconTheme.of(context).color,
            disabledColor: Theme.of(context).disabledColor,
            onPressed: () => focusNodeList.reversed.next(),
          );
        }),
        Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            tooltip: 'Next',
            iconSize: IconTheme.of(context).size!,
            color: IconTheme.of(context).color,
            disabledColor: Theme.of(context).disabledColor,
            onPressed: () => focusNodeList.next(),
          );
        }),
      ];

  final size = Size.fromHeight(48);

  PreferredSize buildToolbar(Widget row) {
    return PreferredSize(
        preferredSize: size,
        child: row
            .swipeDetector(onSwipeDown: (_) {
              //todo 测试
              Get.back();
            })
            .textFieldTapRegion()
            .paddingSymmetric(horizontal: 12));
  }

  Widget buildTagBtn(void Function() onPressed) {
    return Builder(builder: (context) {
      return TextButton.icon(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: context.primary,
            ),
            borderRadius: BorderRadius.circular(10.0), // 圆角的大小
          ),
        ),
        onPressed: onPressed,
        icon: Icon(
          Icons.tag,
          size: 20,
        ),
        label: Text("Add Tag".i18n),
      );
    });
  }
}
