import 'dart:async';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/drift/drift_adapter.dart';
import 'package:flutter_pasteboard/service/sync/DirtyMarker.dart';
import 'package:flutter_pasteboard/service/sync/supa_config.dart';
import 'package:flutter_pasteboard/service/sync/sync_helper.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';

import 'sync/supabase/supabase_service.dart';

class TagStore extends GetxController with DirtyMarkerController {
  static TagStore get find => Get.find();
  final RxList<Tag> all = RxList();
  final RxMap<String, Tag> id2tag = RxMap();
  final RxMap<String, Tag> value2tag = RxMap();
  final Completer _completer = Completer();
  SyncHelper? _syncHelper;

  Future _onSaveRemote(List<Map<String, dynamic>> json) async {
    // DebugUtils.log("tag_store:33: ${json} \n${StackTrace.current}");
    var tags = json.mapToList((e) => Tag.fromJson(e));
    await updateSyncedTag(tags);
    if (!json.isEmptyOrNull) this.log.dd(() => "从远端修改了: ${tags.length} 个 标签, \n ${json.join(",")}");
  }

  Future<void> updateSyncedTag(List<Tag> tags) async {
    if (tags.isEmptyOrNull) return;
    await _db.tagTb.insertAll(
      mode: drift.InsertMode.insertOrReplace,
      tags.mapToList((e) => e.toTbCompanion().copyWith(status: drift.Value(SyncStatus.SYNC_ED.code))),
    );
  }

  Future _onDeleteRemote(List<String> uuids) async {
    await _db.tagTb.deleteWhere((tbl) => tbl.key.isIn(uuids));
    if (!uuids.isEmptyOrNull) this.log.dd(() => "从远端新增删除了: ${uuids.length} 个 标签, \n ${uuids.join(",")}");
  }

  Future _trySync() async {
    var accountService = await AccountService.init;
    await accountService.loginSuccessFuture;
    var type = KvType.tags;
    var hiveKey = 'tag_sync';

    var syncHelper = SyncHelper(
      kvType: type,
      version: 9,
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
  }

  void _whenLocalChange(SyncHelper syncHelper) {
    var query = _db.tagTb.select();
    query.where((tbl) => tbl.status.equals(SyncStatus.UN_SYNC.code));
    query.watch().listen((List<Tag_tbData> tagDatas) async {
      if (tagDatas.isEmptyOrNull) return;
      var needSyncData = tagDatas.mapToList((e) {
        var tag = e.toModel();
        return (tag.id, tag.toJson());
      });
      if ((await syncHelper.upload(needSyncData)) == false) {
        return;
      }
      var update = _db.tagTb.update();
      var maxTime = tagDatas.mapToList((e) => e.modifyTime).whereNotNull().toList().maxByMapper((i) => i.millisecondsSinceEpoch);
      update.where((tbl) => drift.Expression.and([
            tbl.key.isIn(tagDatas.mapToList((e) => e.key)),
            if (maxTime != null) tbl.modifyTime.isSmallerOrEqualValue(maxTime),
          ]));
      var cnt = await update.write(Tag_tbCompanion.custom(status: drift.Constant(SyncStatus.SYNC_ED.code)));
      syncHelper.log.dd(() => "update SYNC_ED:${cnt}");
    }).bind(this);
  }

  //todo 桌面端也要改
  List<String> id2Name(List<String> ids) {
    return ids.mapToList((e) => id2tag[e]?.value ?? e);
  }

  Future<List<Tag>> get allFuture async {
    await _completer.future;
    return all;
  }

  AppDatabase get _db => AppDatabase.get;

  bool contain(String tagName) {
    return all.justValue.any((e) => e.value == tagName);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    var query = _db.tagTb.select();
    query.orderBy([
      (tbl) => drift.OrderingTerm(
            expression: tbl.value,
            mode: drift.OrderingMode.desc,
          )
    ]);
    query.watch().distinct((lista, listb) => lista.deepEqual(listb, (i) => i.modifyTime)).listen((event) {
      var newList = event.mapToList((i) => i.toModel(), growable: false);
      if (!newList.deepEqual(all.justValue)) {
        all.value = newList;
        id2tag.value = newList.mapToMap((p0) => p0.id, (p0) => p0);
        value2tag.value = newList.mapToMap((p0) => p0.value, (p0) => p0);
        this.log.dd(() => "update tags:#{${newList}");
      }
      if (!_completer.isCompleted) {
        _completer.complete();
      }
    }).bind(this);
    _trySync();
  }

  Tag touch(
    Tag tag, {
    bool canToast = true,
  }) {
    tag = tag.copyWith(value: tag.value.trim());
    if (tag.value.contains(" ")) {
      this.log.e("标签包含空格: ${tag}");
    }
    fnassert(() => !tag.value.startsWith("#"));
    var originTag = id2tag[tag.id];
    bool contain = originTag != null;
    if (originTag?.colorValue == null && tag.colorValue == null) {
      var colors = all
          .whereToList(
            (e) => e.colorValue != null,
          )
          .mapToList((e) => Color(e.colorValue!));
      var color = FnColors.pickRandom(exclude: colors);
      tag = tag.copyWith(colorValue: color.value);
    }
    tag = tag.copyWith(colorValue: tag.colorValue ?? originTag?.colorValue);
    var future = save(tag, isDirty: !contain);
    if (!contain && canToast) {
      future.then((value) => BotToast.showText(text: "create #%s".i18n.fill([tag.value])));
    }
    return tag;
  }

  Future<void> save(
    Tag tag, {
    bool isDirty = true,
  }) async {
    this.log.dd(() => "update tag: ${tag}, isDirty: ${isDirty}");
    fnassert(() => tag.color != null, tag);
    // id2tag[tag.id] = tag;
    // value2tag[tag.value] = tag;
    // all.value = all.justValue..replaceWhere((p0) => p0.id == tag.id, tag);
    await _db.tagTb.insertAll(mode: drift.InsertMode.insertOrReplace, [
      tag.toTbCompanion().copyWith(
            modifyTime: drift.Value(DateTime.now()),
            status: drift.Value(isDirty ? SyncStatus.UN_SYNC.code : SyncStatus.SYNC_ED.code),
          ),
    ]);
  }

  Future delete(String uuid) async {
    var res = await _db.tagTb.deleteWhere((tbl) => tbl.key.equals(uuid));
    this.log.dd(() => "删除 tag:${uuid}, 删除${res}个");
    await SupabaseService.tryFind?.batchDeleteJson([(KvType.tags, uuid)]);
  }

  Future<List<Tag>> search(String context) {
    fnassert(() => (!context.startsWith("#")));
    var query = _db.tagTb.select()..where((tbl) => tbl.value.contains(context));
    return query.map((p0) => p0.toModel()).get();
  }

  Future<List<Tag>> searchById(String id) {
    var query = _db.tagTb.select()..where((tbl) => tbl.key.equals(id));
    return query.map((p0) => p0.toModel()).get();
  }

  Future<List<Tag>> recent([int limit = 10]) {
    var query = _db.tagTb.select();
    query.limit(limit);
    query.orderBy([
      (tbl) => drift.OrderingTerm(
            expression: tbl.modifyTime,
            mode: drift.OrderingMode.desc,
          ),
    ]);
    return query.map((p0) => p0.toModel()).get();
  }

  @override
  Future markDirty(int cnt) async {
    var list = await recent(cnt);
    _db.tagTb.insertAll(
      mode: drift.InsertMode.insertOrReplace,
      list.mapToList((e) => e.toTbCompanion().copyWith(status: drift.Value(SyncStatus.UN_SYNC.code))),
    );
  }
}
