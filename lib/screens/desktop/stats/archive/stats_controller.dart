import 'dart:async';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_function.dart';
import 'package:flutter_pasteboard/misc/guide/guide_data.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/data_change_listener.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart';

enum GroupType {
  Week,
  Date,
  Tag,
}

class StatsController extends GetxController with DataChanegGetxMixin {
  final RxList<TimeBlock> timeBlocks = RxList();

  static StatsController get instance => Get.touch(() => StatsController());
  final groupType = Rx(GroupType.Date);

  DateTime? get lastStartTime {
    return timeBlocks.getNullable(timeBlocks.length - 1)?.startTime;
  }

  final Rx<DateTime> startTime = Rx(DateTime.now().onlyYmd());
  final Rx<DateTime> endTime = Rx(DateTime.now().onlyYmd().add(1.days));
  late final RxBool showRest = RxBool(true)
    ..apply((it) {
      it.listen((p0) {
        refreshList("showRest");
      }).bind(this);
    });
  late final RxBool showNoTag = RxBool(true)
    ..apply((it) {
      it.listen((p0) {
        refreshList("showNoTag");
      }).bind(this);
    });
  late final RxList<Tag> tags = RxList<Tag>().apply((it) async {
    TagStore.find.all.listenAndPump((p0) {
      it.value = p0.toList(growable: true);
    }).bind(this);
    it.listen((p0) {
      refreshList("tag");
    }).bind(this);
  });
  final RxBool showGuideInfo = RxBool(false);

  void markGuideEnd() {
    SettingService.instance.needGuideInTimeLine.value = false;
    showGuideInfo.value = false;
    var set = GuideData.guideTimeBlock.mapToList((e) => e.uuid).toSet();
    timeBlocks.value = timeBlocks.justValue.where((element) => !set.contains(element.uuid)).toList(growable: false);
  }

  Future<List<TimeBlock>> refreshList([String? source]) async {
    var list = await TimeBlockStore.find
        .queryPromodoByTime(
          startTime: startTime.justValue,
          endTime: endTime.justValue,
        )
        .get();
    var idSet = tags.mapToList((e) => e.id).toSet();
    var valueSet = tags.mapToList((e) => e.value).toSet();
    var newList = list.where(
      (e) {
        if (!showRest.justValue && e.isRest) return false;
        if (e.isFocus) {
          var promodo = e.pomodoro;
          if (!showNoTag.justValue && promodo.tags.isEmpty) return false;
          return idSet.isEmpty ||
              idSet.containsAny(promodo.tags) ||
              valueSet.containsAny(promodo.tags) ||
              (showNoTag.justValue && promodo.tags.isEmpty);
        }
        return true;
      },
    ).toList(growable: false);
    if (!timeBlocks.justValue.deepEqual(newList, (i) => i.toSimpleStr())) {
      timeBlocks.value = newList;
      this.log.dd(() => "[${source}]timeBlocks.refresh origin: ${list.length}, result:${timeBlocks.length}");
    }
    return timeBlocks;
  }

  Future<bool> tryInitGuide() async {
    await SettingService.instance.needGuideInTimeLine.init;
    var needGuide = SettingService.instance.needGuideInTimeLine.value;
    if (needGuide) {
      showGuideInfo.value = true;
      timeBlocks.value = [
        ...GuideData.guideTimeBlock,
        ...GuideData.guideTimeBlock
            .mapToList((e) => e.updateTime(startTime: e.startTime!.subtract(1.days + 3.hours), endTime: e.endTime!.subtract(1.days + 3.hours))),
      ];
    }
    return needGuide;
  }

  void createNewOne() {
    var startT = startTime.justValue;
    var tb = TimeBlock.emptyFocus(
        startTime: startT,
        endTime: startT.add(
          25.minutes,
        ));
    showTimeBlockCardEditor(tb: tb);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void whenDeleteTimeBlock(String uuid) {
    var list = timeBlocks.justValue.toList();
    var res = list.removeWhereExt((p0) => p0.uuid == uuid);
    if (res != 0) {
      timeBlocks.value = list.toList(growable: false);
      this.log.dd(() => "timeBlock delete:${uuid}, res:${res}");
    }
  }

  @override
  void whenSettingChange(String key, oldV, newV) {
    // TODO: implement whenSettingChange
  }

  @override
  void whenUpsertBlockChange(TimeBlock newTb) {
    var list = timeBlocks.justValue.toList();
    var res = list.replaceWhere((p0) => p0.uuid == newTb.uuid, newTb);
    if (res) {
      timeBlocks.value = list.toList(growable: false);
      this.log.dd(() => "timeBlock change:${newTb}, res:${res}");
    } else {
      timeBlocks.value = [...list, newTb].toFixedList();
    }
  }
}
