import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_dialog.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/mobile/timeblock/timeblock_edit_mobile.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get.dart';

Future showTimeBlockCardEditor({TimeBlock? tb}) async {
  tb = tb ??
      TimeBlock.emptyFocus(
          startTime: DateTime.now().subtract(
        25.minutes,
      ));
  if (Get.context!.isMobile) {
    await FnBottomSheet.bottomSheet(
      TimeBlockEditorMobile(
        mode: TimeBlockEditorMobileMode.all,
        onSubmit: (tb) {
          $zenService.updateTimeBlock(tb, needSave: true);
          Get.back();
        },
        onDelete: (_tb) {
          $zenService.remove(_tb);
          Get.back();
        },
        tb: tb,
      ),
    );
  } else {
    await FnDialog.show(Dialog(
      insetPadding: EdgeInsets.all(48),
      child: TimeBlockEditorForDialog(
        timeBlock: tb,
        onSubmit: (tb) {
          $zenService.updateTimeBlock(tb, needSave: true);
          Get.back();
        },
        onDelete: (_tb) {
          $zenService.remove(_tb);
          Get.back();
        },
      ).paddingAll(12),
    ));
  }
}
