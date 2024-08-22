import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/drift/drift_adapter.dart';
import 'package:flutter_pasteboard/service/sync/DirtyMarker.dart';
import 'package:flutter_pasteboard/service/sync/supa_config.dart';
import 'package:flutter_pasteboard/service/sync/supabase/supabase_service.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:get/get.dart';

import 'data_change_listener.dart';
import 'sync/sync_helper.dart';

class TimeBlockStore extends GetxController with TimeBlockChangeGetxMixin, DirtyMarkerController {
  static TimeBlockStore get find => Get.find();
  final RxInt unSyncCnt = RxInt(0);
  final RxInt syncedCnt = RxInt(0);
  late final Rx<DateTime> lastTimeStamp = Rx(DateTime.now());
  late final Rx<TimeBlock?> lastTb = Rx(null);
  SyncHelper? _syncHelper;

  @override
  void onInit() {
    super.onInit();
    /*查询所有没有 END time 的做矫正*/
    _initLastTimeStamp();
    _trySync();
  }

  Future _onSaveRemote(List<Map<String, dynamic>> json) async {
    var tbs = json.mapToList((e) => TimeBlock.fromJson(e)..tryPromodo);
    await updateSynced(tbs);
    TimeBlockChangeListener.listener.forEach((e) => tbs.forEach((element) {
          e.whenUpsertBlockChange(element);
          e.whenRemoteUpsertTimeBlock(element);
        }));
    if (!json.isEmptyOrNull) this.log.dd(() => "从远端新增保存了: ${tbs.length} 个时间块, \n ${tbs.mapToList((e) => e.body).join(",")}");
  }

  Future<void> updateSynced(List<TimeBlock> tbs) async {
    await _db.timeBlockTb.insertAll(
      mode: drift.InsertMode.insertOrReplace,
      tbs.mapToList((e) => e.toTbCompanion().copyWith(status: drift.Value(SyncStatus.SYNC_ED.code))),
    );
  }

  Future _onDeleteRemote(List<String> uuids) async {
    await _db.timeBlockTb.deleteWhere((tbl) => tbl.key.isIn(uuids));
    if (!uuids.isEmptyOrNull) this.log.dd(() => "从远端新增删除了: ${uuids.length} 个时间块, \n ${uuids.join(",")}");
  }

  Future _trySync() async {
    var accountService = await AccountService.init;
    if (await accountService.loginSuccessFuture == false) {
      return;
    }
    var type = KvType.timeBlock;
    var hiveKey = 'timeblock_sync';

    var syncHelper = SyncHelper(
      kvType: type,
      version: 10,
      onSave: _onSaveRemote,
      onDelete: _onDeleteRemote,
      userId: accountService.userId!,
      initTime: accountService.createdAt!,
      hiveKey: hiveKey,
    );
    _syncHelper = syncHelper;
    syncHelper.register();

    await syncHelper.sync();
    _whenLocalChange(syncHelper);
    _listenSynedCnt();
  }

  void _listenSynedCnt() {
    var query = _db.timeBlockTb
        .count(
          where: (tbl) => tbl.status.equals(SyncStatus.SYNC_ED.code),
        )
        .watchSingleOrNull()
        .listen((event) {
      syncedCnt.value = event ?? 0;
    }).bind(this);
  }

  void _whenLocalChange(SyncHelper syncHelper) {
    var query = _db.timeBlockTb.select();
    query.where((tbl) => tbl.status.equals(SyncStatus.UN_SYNC.code));
    query.watch().listen((List<TimeBlock_tbData> tbDatas) async {
      unSyncCnt.value = tbDatas.length;
      if (tbDatas.isEmptyOrNull) return;
      var needSyncData = tbDatas.mapToList((e) {
        var tb = e.toModel();
        return (tb.uuid, tb.toJson());
      });
      if ((await syncHelper.upload(needSyncData)) == false) {
        return;
      }
      var update = _db.timeBlockTb.update();
      var maxTime = tbDatas.mapToList((e) => e.modifyTime).whereNotNull().toList().maxByMapper((i) => i.millisecondsSinceEpoch);
      var keySet = tbDatas.mapToList((e) => e.key);
      update.where((tbl) {
        return drift.Expression.and([
          tbl.key.isIn(keySet),
          // 修改时间 要比回写列表里面的tb的最大修改时间要小。如果更大, 说明后面脏了
          if (maxTime != null) tbl.modifyTime.isSmallerOrEqualValue(maxTime),
        ]);
      });
      var cnt = await update.write(TimeBlock_tbCompanion.custom(status: drift.Constant(SyncStatus.SYNC_ED.code)));
      unSyncCnt.value -= cnt;
      syncHelper.log.dd(() => "update SYNC_ED:${cnt}");
    }).bind(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _initLastTimeStamp() async {
    var select = _db.timeBlockTb.select();
    select.limit(
      1,
      offset: 0,
    );
    select.orderBy([
      (tbl) => drift.OrderingTerm(
            expression: tbl.endTime,
            mode: drift.OrderingMode.desc,
          )
    ]);
    var watch = select.map((p0) => p0.toModel()).watch();
    watch.listen((event) {
      var tb = event.getNullable(0);
      if (tb == null) return;
      lastTb.value = tb;
      var endTime = tb.endTime;
      if (endTime != null) {
        lastTimeStamp.value = endTime;
      }
    }).bind(this);
  }

  AppDatabase get _db => AppDatabase.get;

  Future save(TimeBlock timeBlock) async {
    var query = _db.timeBlockTb.select();
    query..where((tbl) => tbl.key.equals(timeBlock.uuid));
    var tb = (await query.getSingleOrNull())?.toModel();
    if (tb == timeBlock) {
      this.log.dd(() => "相同, 不触发修改, ${timeBlock}");
      return;
    }
    if (timeBlock.isFocus) {
      var promodo = timeBlock.pomodoro;
      promodo.tags.forEach((element) {
        TagStore.find.touch(Tag.empty(element));
      });
      fnassert(() => promodo.progressSeconds >= 0, timeBlock);
      fnassert(() => timeBlock.startTime != null, timeBlock);
      fnassert(() => !timeBlock.startTime!.isAfter(DateTime.now()), timeBlock);
      if (timeBlock.endTime != null) {
        fnassert(() => timeBlock.endTime == timeBlock.startTime || timeBlock.endTime!.isAfter(timeBlock.startTime!));
      }
    }
    timeBlock.assertTimeBlockRule();
    // DebugUtils.log("time_block_store:154: ${timeBlock} \n${StackTrace.current}");
    await _db.timeBlockTb.insertAll(mode: drift.InsertMode.insertOrReplace, [
      timeBlock.toTbCompanion(),
    ]);
    TimeBlockChangeListener.listener.forEach((e) => e.whenUpsertBlockChange(timeBlock));
  }

  Future<int> delete(String uuid) async {
    TimeBlockChangeListener.listener.forEach((e) => e.whenDeleteTimeBlock(
          uuid,
        ));
    var res = await _db.timeBlockTb.deleteWhere((tbl) => tbl.key.equals(uuid));
    this.log.dd(() => "删除 timeblock:${uuid}, 删除${res}个");
    if (res != 0) {
      SupabaseService.tryFind?.batchDeleteJson([(KvType.timeBlock, uuid)]);
    }
    return res;
  }

  Future<List<TimeBlock>> searchPromodoByContext(String context) {
    var query = _db.timeBlockTb.select()..where((tbl) => tbl.body.contains(context));
    query.orderBy([
      (tbl) => drift.OrderingTerm(
            expression: tbl.startTime,
            mode: drift.OrderingMode.desc,
          )
    ]);
    return query.map((p0) => p0.toModel()).get();
  }

  drift.Selectable<TimeBlock> queryPromodoByTime({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    var select = _db.timeBlockTb.select();
    select.where((tbl) => drift.Expression.and([
          tbl.startTime.isBiggerOrEqualValue(startTime),
          tbl.startTime.isSmallerOrEqualValue(endTime),
        ]));
    select.orderBy([
      (tbl) => drift.OrderingTerm(
            expression: tbl.startTime,
            mode: drift.OrderingMode.desc,
          ),
      (tbl) => drift.OrderingTerm(
            expression: tbl.key,
            mode: drift.OrderingMode.desc,
          ),
    ]);
    return select.map<TimeBlock>((p0) => p0.toModel());
  }

  // 批量查询 Future<List<TimeBlock>> query(List<String> uuids)
  Future<List<TimeBlock>> query(List<String> uuids) async {
    var query = _db.timeBlockTb.select();
    query.where((tbl) => tbl.key.isIn(uuids));
    return await query.map((p0) => p0.toModel()).get();
  }

  Future<List<TimeBlock>> getRecent([
    int offset = 0,
    int limit = 50,
  ]) async {
    var select = _db.timeBlockTb.select();
    select.limit(
      limit,
      offset: offset,
    );
    select.orderBy([
      (tbl) => drift.OrderingTerm(
            expression: tbl.startTime,
            mode: drift.OrderingMode.desc,
          )
    ]);
    return await select.map((p0) => p0.toModel()).get();
  }

  Stream<List<TimeBlock>> watchRecent({
    int offset = 0,
    int limit = 50,
  }) {
    var select = _db.timeBlockTb.select();
    select.limit(
      limit,
      offset: offset,
    );
    select.orderBy([
      (tbl) => drift.OrderingTerm(
            expression: tbl.startTime,
            mode: drift.OrderingMode.desc,
          )
    ]);
    return select.map((p0) => p0.toModel()).watch();
  }

  @override
  void whenDeleteTimeBlock(String uuid) {
    // pass
  }

  @override
  void whenUpsertBlockChange(TimeBlock newTb) {
    var tbRx = Get.tryFind<Rx<TimeBlock>>(tag: newTb.uuid);
    if (tbRx != null) {
      tbRx.value = newTb;
    }
  }

  @override
  Future markDirty(int cnt) async {
    var list = await getRecent(0, cnt);
    _db.timeBlockTb.insertAll(
      mode: drift.InsertMode.insertOrReplace,
      list.mapToList((e) => e.toTbCompanion().copyWith(status: drift.Value(SyncStatus.UN_SYNC.code))),
    );
  }
}
