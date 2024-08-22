import 'dart:math';

import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/editor/duration_editor.dart';
import 'package:flutter_pasteboard/component/editor/time_eidtor.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/short_cut/short_cut_view.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/mobile/timeblock/timeblock_edit_mobile.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class EditTbTimeWidget extends StatefulWidget {
  const EditTbTimeWidget({
    super.key,
    required this.tbRx,
  });

  final Rx<TimeBlock> tbRx;

  @override
  State<EditTbTimeWidget> createState() => _EditTbTimeWidgetState();
}

class _EditTbTimeWidgetState extends State<EditTbTimeWidget> {
  Rx<TimeBlock> get tbRx => widget.tbRx;

  @override
  void initState() {
    super.initState();
    if (widget.tbRx.justValue.startTime == null) {
      _updateStarTime(DateTime.now());
    }
  }

  Widget _buildShortLabel(String text, LogicalKeyboardKey key) {
    var textStyle = context.defaultTextStyle;
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(
            text: text,
          ),
          if (PlatformUtils.isDesktop)
            TextSpan(
                text: " [ " + key.toReadable() + " ]",
                style: textStyle.copyWith(
                  color: context.primary,
                )),
        ],
      ),
    );
  }

  void _updateStarTime(DateTime? startTime) {
    if (startTime == null) return;
    startTime = FnDateUtils.min(startTime, DateTime.now());
    tbRx.value = tbRx.justValue
        .updateTime(
          startTime: startTime,
        )
        .correctProgressTime()
        .correctDuration();
  }

  void _updateDuration(int seconds) {
    seconds = max(seconds, 0);
    tbRx.value = tbRx.justValue.updateTime(durationSeconds: seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(FnDateUtils.humanReadable(tbRx.value.startTime!)),
              gap4,
              Icon(
                FnIcons.text_right,
                size: 12,
              ),
              gap4,
              Text(FnDateUtils.humanReadable(FnDateUtils.max(tbRx.value.startTime!.add(tbRx.value.durationSeconds.seconds), DateTime.now()))),
            ],
          ).paddingSymmetric(horizontal: 16).material(color: context.onBackground.withOpacity(.1)).center();
        }),
        FutureBuilder(
            future: TimeBlockStore.find.getRecent(0, 2),
            builder: (_, snp) {
              var list = snp.data;
              list?.removeWhere((e) => e.uuid == tbRx.justValue.uuid);
              var lastTb = list?.getNullable(0);
              return ListTile(
                title: Text(
                  "开始时间".i18n,
                  style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(
                  runSpacing: 2,
                  spacing: 4,
                  children: [
                    if (lastTb != null)
                      ActionChip(
                        label: _buildShortLabel("Last End".i18n, LogicalKeyboardKey.backquote),
                        onPressed: () {
                          setState(() {
                            _updateStarTime(lastTb.endTime!);
                          });
                        },
                      ),
                    ActionChip(
                      label: _buildShortLabel("-5 min", LogicalKeyboardKey.minus),
                      onPressed: () {
                        setState(() {
                          _updateStarTime(tbRx.justValue.startTime!.subtract(5.minutes));
                        });
                      },
                    ),
                    ActionChip(
                      label: _buildShortLabel("+5 min", LogicalKeyboardKey.equal),
                      onPressed: () {
                        setState(() {
                          _updateStarTime(tbRx.justValue.startTime!.add(5.minutes));
                        });
                      },
                    ),
                  ],
                ).focus(
                  skipTraversal: true,
                  canRequestFocus: false,
                  descendantsAreFocusable: false,
                  descendantsAreTraversable: false,
                ),
                trailing: TimeEditor(
                    minTime: lastTb?.endTime,
                    maxTime: DateTime.now(),
                    key: UniqueKey(),
                    autofocus: true,
                    initTime: tbRx.justValue.startTime!,
                    onUpdate: (TimeOfDay timeOfDay) {
                      _updateStarTime(tbRx.justValue.startTime!.copyWithTd(timeOfDay));
                    }),
              ).focus(onKey: (_, event) {
                if (event is RawKeyDownEvent) return KeyEventResult.ignored;
                if (event.logicalKey == LogicalKeyboardKey.backquote && lastTb != null) {
                  setState(() {
                    _updateStarTime(lastTb.endTime!);
                  });

                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.minus) {
                  setState(() {
                    _updateStarTime(tbRx.justValue.startTime!.subtract(5.minutes));
                  });
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.equal) {
                  setState(() {
                    _updateStarTime(tbRx.justValue.startTime!.add(5.minutes));
                  });

                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              });
            }),
        gap12,
        ListTile(
          title: Text(
            "计划持续时间".i18n,
            style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              ActionChip(
                label: _buildShortLabel("-5 min", LogicalKeyboardKey.minus),
                onPressed: () {
                  setState(() {
                    _updateDuration(tbRx.justValue.durationSeconds - 5 * 60);
                  });
                  ;
                },
              ),
              ActionChip(
                label: _buildShortLabel("+5 min", LogicalKeyboardKey.equal),
                onPressed: () {
                  setState(() {
                    _updateDuration(tbRx.justValue.durationSeconds + 5 * 60);
                  });
                },
              )
            ],
          ).focus(
            skipTraversal: true,
            canRequestFocus: false,
            descendantsAreFocusable: false,
            descendantsAreTraversable: false,
          ),
          trailing: DurationEditor(
            key: UniqueKey(),
            init: tbRx.value.durationSeconds.seconds,
            onChange: (Duration duration) {
              _updateDuration(duration.inSeconds);
            },
          ),
        ).focus(onKey: (_, event) {
          if (event is RawKeyDownEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.minus) {
            setState(() {
              _updateDuration(tbRx.justValue.durationSeconds - 5 * 60);
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.equal) {
            setState(() {
              _updateDuration(tbRx.justValue.durationSeconds + 5 * 60);
            });
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }),
        gap24,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 12,
            ),
            OutlinedButton(
              onPressed: () {
                Get.back();
              },
              child: ShortcutTextWidget("取消".i18n, keySet: FnKeys.esc),
            ),
            ElevatedButton(
              onPressed: () {
                _submit();
              },
              child: ShortcutTextWidget("保存".i18n, keySet: FnKeys.cmdS),
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ],
    ).simpleShortcuts({
      FnKeys.cmdS: () {
        _submit();
      },
    });
  }

  void _submit() {
    TimeBlock value = tbRx.justValue;
    $zenService.updateTimeBlock(value.updateTime(startTime: value.startTime));
    Get.back();
  }
}

void showEditTime(Rx<TimeBlock> tbRx) async {
  if (PlatformUtils.isMobile) {
    await FnBottomSheet.bottomSheet(TimeBlockEditorMobile(
      onCancel: () => Get.back(),
      mode: ($zenService.isFocus || $zenService.isRest) ? TimeBlockEditorMobileMode.editTimeOnPlaying : TimeBlockEditorMobileMode.editTimeForPlan,
      onSubmit: (tb) {
        tbRx.value = tb;
        Get.back();
      },
      tb: tbRx.justValue,
    ));
  } else {
    FnDialog.showDialog(
      EditTbTimeWidget(
        tbRx: tbRx,
      )
          .paddingSymmetric(
            horizontal: 12,
            vertical: 8,
          )
          .boxConstraints(
            maxWidth: 700,
          ),
      alignment: CrossAxisAlignment.start,
    );
  }
}
