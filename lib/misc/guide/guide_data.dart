import 'dart:async';
import 'dart:convert';
import 'dart:math' as m;

import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:drift/drift.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/download_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:get/get.dart';
import 'package:universal_io/io.dart';

abstract class GuideData {
  // todo 思考如何新手引导 文案
  static List<TimeBlock> get guideTimeBlock => [
        _buildPromodo(
          title: "[模板] 学习时间管理技巧 #学习".i18n,
          progressSeconds: 25 * 60,
          tags: ["学习".i18n],
        ),
        _buildRest(
          restSeconds: 5 * 60,
          type: RestType.COUNT_DOWN,
        ),
        _buildPromodo(
          title: "[模板] 学习番茄工作法 #学习".i18n,
          progressSeconds: 25 * 60,
          tags: ["学习".i18n],
        ),
        _buildRest(
          restSeconds: 5 * 60,
          type: RestType.COUNT_DOWN,
        ),
        _buildPromodo(
          title: "[模板] 学习四象限工作法 #学习".i18n,
          progressSeconds: 25 * 60,
        ),
        _buildRest(
          restSeconds: 5 * 60,
          type: RestType.COUNT_DOWN,
        ),
        _buildPromodo(
          title: "[模板] 阅读柳比歇夫的时间统计法《奇特的一生》#阅读 ".i18n,
          progressSeconds: 20 * 60,
          logs: [
            ActionLog(
              type: ActionLogType.PAUSE.code,
              time: _start.add(
                5.minutes,
              ),
            ),
            ActionLog(
              type: ActionLogType.RESUME.code,
              time: _start.add(
                10.minutes,
              ),
            ),
            ActionLog(
              type: ActionLogType.STOP.code,
              time: _start.add(
                20.minutes,
              ),
            ),
          ],
          tags: ["阅读".i18n],
        ),
        _buildRest(
          restSeconds: 5 * 60,
          type: RestType.COUNT_DOWN,
        ),
        _buildPromodo(
          title: "[模板] 阅读柳比歇夫的时间统计法《奇特的一生》 #阅读".i18n,
          progressSeconds: 25 * 60,
          tags: ["阅读".i18n],
        ),
        _buildRest(
          restSeconds: 25 * 60,
          type: RestType.COUNT_DOWN,
        ),
        _buildPromodo(
          title: "[模板] 撰写读书笔记:《奇特的一生》 #阅读".i18n,
          progressSeconds: 25 * 60,
          tags: ["阅读".i18n],
        ),
      ];
  static late DateTime _endTime = DateTime.now().subtract(10.minutes);

  static DateTime get _start => _endTime;

  static TimeBlock _buildPromodo({
    required String title,
    String? context,
    required int progressSeconds,
    List<ActionLog>? logs,
    List<String>? tags,
    String? feedback,
  }) {
    var end = _endTime;
    var start = _endTime.subtract(progressSeconds.seconds);
    // DebugUtils.log("guide_data:118 ${_endTime} ,${start}, ${end} \n${StackTrace.current}");
    _endTime = start;
    var list = (logs?.mapToList((i) {
          var d = m.Random().nextDouble() * progressSeconds;
          return i.copyWith(time: start.add(d.seconds));
        }) ??
        []);
    list..sort((a, b) => a.time.millisecondsSinceEpoch - b.time.millisecondsSinceEpoch);
    return TimeBlock.emptyFocus()
        .updatePromodo(
          mapper: (pro) => pro.copyWith(
            tags: tags ?? [],
            progressSeconds: progressSeconds,
            context: context ?? "",
            title: title,
            feedback: feedback,
            logs: list.mapToList((e) => e.toJsonStr()),
          ),
        )
        .updateTime(
          startTime: start,
          endTime: end,
        );
  }

  // _buildRest
  static TimeBlock _buildRest({
    required RestType type,
    required int restSeconds,
  }) {
    var end = _endTime;
    var start = _endTime.subtract(restSeconds.seconds);
    _endTime = start;
    return TimeBlock.emptyCountDownRest()
        .updateRest(
          mapper: (rest) => rest.copyWith(
            type: type.code,
            progressSeconds: restSeconds,
          ),
        )
        .updateTime(
          startTime: start,
          endTime: end,
        );
  }
}

class GuideService extends GetxService {
  static GuideService get instance => Get.touch(() => GuideService());

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<List<TimeBlock>?> tryFetchGuideDataOnline() async {
    await TagStore.find.allFuture;
    Completer<List<TimeBlock>> _completer = Completer<List<TimeBlock>>();
    DownloadUtils.startDownload(
        url: "https://gitee.com/chen-hao91/publix_resource/raw/main/guide.json",
        fileName: "guide.json",
        timeout: 3.seconds,
        onFail: () => _completer.tryComplete([]),
        onComplete: (path) async {
          var file = File(path);
          var result = file.readAsStringSync();
          if (DebugFlag.download) log.dd(() => "result:${result}");
          try {
            List<TimeBlock> tbs = json.decode(result);
            _completer.tryComplete(tbs);
          } catch (e) {
            log.e("解析失败:${result}");
            _completer.tryComplete([]);
          }
        });
    await _completer.future;
  }

  final String _hiveKey = "guideTbsIds";

  Future<bool> tryInitGuide() async {
    var holder = SettingService.instance.needGuideInTimeLine;
    await holder.init;
    var needGuide = holder.value;
    if (needGuide) {
      holder.value = false;
      await mustGuide();
    } else {
      this.log.dd(() => "已经引导过了");
    }
    // if (kDebugMode) {
    //   holder.value = true;
    //   // lazyAppCache.delete(_hiveKey);
    // }
    return needGuide;
  }

  Future<void> mustGuide() async {
    GuideData._endTime = DateTime.now().subtract(10.minutes);
    List<TimeBlock> guideDatas = [];
    var onlineTbs = await tryFetchGuideDataOnline();
    if (onlineTbs.isEmptyOrNull) {
      this.log.dd(() => "查不到远端配置");
      guideDatas = GuideData.guideTimeBlock;
    } else {
      guideDatas = (onlineTbs ?? []).mapToList((e) {
        if (e.isRest) return e;
        var pomodoro = e.pomodoro;
        // todo 处理远端的时间
        return GuideData._buildPromodo(
          title: pomodoro.title ?? "",
          progressSeconds: e.progressSeconds,
          context: pomodoro.context,
          tags: pomodoro.tags,
          feedback: pomodoro.feedback,
        );
      });
    }
    for (var i in guideDatas) {
      var tags = i.tryPromodo?.tags.mapToList((e) => Tag.empty(e).copyWith(
            colorValue: FnColors.tagColors.random.value,
          ));
      await TagStore.find.updateSyncedTag(tags ?? []);
    }
    await TimeBlockStore.find.updateSynced(guideDatas);
    List<String> originList = await getGuideList();
    await lazyAppCache.put(_hiveKey, [...guideDatas.mapToList((e) => e.uuid), ...originList]);
    DebugUtils.log("guide_data:220: 开始写:${guideDatas} \n${StackTrace.current}");
    if (Get.context != null) {
      Get.rootController.update();
      // FnNotification.showTextSnackBar(
      //     width: 300,
      //     text: "为您填充新手引导数据, 点击删除".i18n,
      //     action: (
      //       "DELETE".i18n,
      //       () {
      //         deleteGuide();
      //       }
      //     ),
      //     duration: 10.minutes);
    }
  }

  Future<int> deleteGuide() async {
    var list = await getGuideList();
    if (list.isNotEmpty) {
      var cnt = await AppDatabase.get.timeBlockTb.deleteWhere((tbl) => tbl.key.isIn(list));
      this.log.dd(() => "已移除引导数据: $cnt 条");
      await lazyAppCache.delete(_hiveKey);
      return cnt;
    } else {
      this.log.dd(() => "没有找到需要移除的引导数据");
      return 0;
    }
  }

  Future<List<String>> getGuideList() async => (await lazyAppCache.get(_hiveKey, defaultValue: []) as List<dynamic>).mapToList((e) => e.toString());
}
