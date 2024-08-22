import 'dart:async';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/misc/purchase_utils.dart';
import 'package:flutter_pasteboard/service/sync/supa_config.dart';
import 'package:flutter_pasteboard/service/sync/supabase/supabase_channel.dart';
import 'package:flutter_pasteboard/service/sync/supabase/supabase_service.dart';
import 'package:get/get.dart';

class SyncMangerController extends GetxService {
  static SyncMangerController get instance => Get.touch(() => SyncMangerController());
  final List<SyncHelper> syncHelpers = [];

  List<Rx<SyncState>> get states => SyncMangerController.instance.syncHelpers.mapToList((e) => e.state);

  bool get allSuccess {
    return states.every((element) => element.value == SyncState.success);
  }

  IconData computeIconData() {
    if (states.any((element) => element.value == SyncState.failure)) return Icons.sync_problem_outlined;
    if (states.every((element) => element.value == SyncState.success)) return Icons.cloud_done_rounded;
    return Icons.sync_outlined;
  }
}

enum SyncState {
  initial,
  syncing,
  upload,
  success,
  failure,
}

class SyncHelper extends GetxController {
  SyncHelper({
    required this.kvType,
    required FutureOr Function(List<Map<String, dynamic>>) onSave,
    required FutureOr Function(List<String>) onDelete,
    this.batchCnt = 100,
    required this.userId,
    required this.initTime,
    required this.hiveKey,
    this.version = 7,
  }) {
    StackTrace strace = StackTrace.current;
    FutureOr __onDelete(List<String> uuids) async {
      var current = StackTrace.current;
      try {
        await onDelete.call(uuids);
      } catch (e) {
        logger.e("ondelete call fail: ${uuids} \n${strace}", e, current);
      }
    }

    FutureOr __onSave(List<Map<String, dynamic>> json) async {
      var current = StackTrace.current;
      try {
        await onSave.call(json);
      } catch (e) {
        logger.e("onSave call fail: ${json}\n ${strace}", e, current);
      }
    }

    _onDelete = __onDelete;
    _onSave = __onSave;
  }

  final Rx<SyncState> state = Rx(SyncState.initial);
  late final log = LoggerWrapper.build("${SyncHelper}_${kvType.name}");

  void register() {
    Get.put(this, tag: this.kvType.toString());
  }

  @override
  void onInit() {
    super.onInit();
    SyncMangerController.instance.syncHelpers.add(this);
    state.value = SyncState.initial;
  }

  SupabaseService get _supabaseService => SupabaseService.tryFind!;
  late Disposer _disposor = Disposer.empty();
  final String hiveKey;
  final String userId;
  final DateTime initTime;
  final KvType kvType;
  final int batchCnt;
  final int version;
  late final FutureOr Function(List<Map<String, dynamic>> json) _onSave;
  late final FutureOr Function(List<String> uuids) _onDelete;

  bool get _debug => DebugFlag.syncLog;
  int _cnt = 0;

  int get _maxTime => 100;

  int get _innerVersion => appCache.get("_innerVersion", defaultValue: 0);

  String get _timeHiveKey => "time_${userId}_${hiveKey}_${version}_${_innerVersion}";

  String get _idHiveKey => "idx_${userId}_${hiveKey}_${version}_${_innerVersion}";

  DateTime get _startFetchTime =>
      DateTime.fromMillisecondsSinceEpoch(appCache.get(_timeHiveKey, defaultValue: initTime.millisecondsSinceEpoch)).subtract(
        GetNumUtils(3).minutes, // 冗余时间, 避免时间漂移边缘问题
      );

  String? _beginIdx = null;
  late DateTime _tmpModifyTime = _startFetchTime;

  Future _update(DateTime dateTime, String? beginIdx) async {
    _beginIdx = beginIdx ?? _beginIdx;
    _tmpModifyTime = FnDateUtils.max(dateTime, _tmpModifyTime);
  }

  Future<bool> get _checkSyncAbility async {
    if (SupabaseService.tryFind == null) return false;
    if (await PurchaseUtils.checkPro()) return true;
    return false;
  }

  Future sync() async {
    if (!await _checkSyncAbility) {
      return;
    }
    var current = StackTrace.current;
    state.value = SyncState.syncing;
    try {
      if (_debug)
        this.log.dd(() => "start fetch, ${this._timeHiveKey},${this._idHiveKey}, ${kvType}, ${_startFetchTime}(${this.initTime}), ${_beginIdx}");
      await _fetch(_maxTime);
      appCache.put(_timeHiveKey, _tmpModifyTime.millisecondsSinceEpoch);
      if (_debug) {
        this.log.dd(() => "更新_startFetchTime: ${_startFetchTime}");
        FnNotification.toast("累计下载: %s".i18n.fill([_cnt]));
      }
      if (_debug) this.log.dd(() => "bind listenerJsonChannel start");
      _disposor = _disposor +
          _supabaseService.listenerJsonChannel(kvType, simpleListener: (ChannelEventType type, Map<String, dynamic> payload) async {
            if (!type.isUpSert) {
              this.log.e("type: ${type}, payload: ${payload}");
              return;
            }
            if (_debug) {
              this.log.dd(() => "type:${type}, payload: ${payload}");
            }
            state.value = SyncState.syncing;
            Map<String, dynamic>? body;
            try {
              body = (payload["body"] as String).tryToJson();
              var uuid = (payload["uuid"] as String);
              var dataState = (payload["state"] as int);
              if (dataState == KvState.delete.code) {
                await _onDelete.call([uuid]);
              } else {
                if (body != null) await _onSave.call([body]);
              }
              state.value = SyncState.success;
            } catch (e) {
              this.log.e("_supabaseService.listenerJsonChannel,body:${body} \n ${current}", e);
              state.value = SyncState.failure;
            }
          });
      state.value = SyncState.success;
    } catch (e) {
      this.log.e("fail sync, \n${current}", e);
      state.value = SyncState.failure;
    }
  }

  @override
  void onClose() {
    super.onClose();
    _disposor.dispose();
    SyncMangerController.instance.syncHelpers.remove(this);
  }

  Future<bool> upload(List<(String, Map<String, dynamic>)> jsonList) async {
    if (!await _checkSyncAbility) {
      return false /*没有同步成功, 下次还会尝试*/;
    }
    state.value = SyncState.upload;
    if (_debug) {
      this.log.dd(() => "update(${jsonList.length}), jsonList: ${jsonList.mapToList((e) => e.$2.values.join(",")).join("|")}");
    }
    try {
      await _supabaseService.batchUpsertJson(jsonList.mapToList((e) => (kvType, e.$1, e.$2)));
      state.value = SyncState.success;
      return true;
    } catch (e) {
      this.log.w("_supabaseService.batchUpsertJson fail ${jsonList},$e");
      state.value = SyncState.failure;
      return false;
    }
  }

  Future<bool> fetchRecent({
    required int limit,
  }) async {
    if (!await _checkSyncAbility) {
      return false /*没有同步成功, 下次还会尝试*/;
    }
    var current = StackTrace.current;
    state.value = SyncState.syncing;
    try {
      List<String> deleteList = [];
      List<Map<String, dynamic>> list = await _supabaseService.batchGet(
        kvType,
        debug: _debug,
        limit: limit,
        onDeleted: (List<String> uuids) {
          deleteList = uuids;
        },
        onMaxFlagChange: (DateTime? maxModifiedTime, String? id) {},
      );
      if (kAnyDebug) {
        FnNotification.toast("下载了${list.length} + del:${deleteList.length}");
      }

      await _onSave.call(list);
      await _onDelete.call(deleteList);
      state.value = SyncState.success;
      return true;
    } catch (e) {
      this.log.e("fetch recent sync, ", e, current);
      state.value = SyncState.failure;
      return false;
    }
  }

  /**
   * 递归 fetch
   */
  Future _fetch(int maxTime) async {
    if (!await _checkSyncAbility) {
      return false /*没有同步成功, 下次还会尝试*/;
    }
    if (maxTime <= 0) {
      this.log.e("怎么拉取了这么多的内容: ${_maxTime}");
      return;
    }
    if (_disposor.isDisposed) {
      this.log.e("中途被终止了, 暂停");
      return;
    }
    var time = _startFetchTime;
    var id = _beginIdx;
    List<String> deleteList = [];
    List<Map<String, dynamic>> list = await _supabaseService.batchGet(
      kvType,
      debug: _debug,
      limit: batchCnt,
      beginMtime: _startFetchTime,
      beginId: _beginIdx,
      onMaxFlagChange: (DateTime? datetime, String? uuid) {
        if (_debug) this.log.dd(() => "onMaxModifiedTimeChange: ${datetime}, ${uuid}");
        if (datetime != null) time = datetime;
        if (uuid != null) id = uuid;
      },
      onDeleted: (List<String> uuids) {
        deleteList = uuids;
      },
    );

    _cnt += list.length + deleteList.length;
    if (_debug) this.log.dd(() => "累计下载: ${_cnt}");

    await _onSave.call(list);
    await _onDelete.call(deleteList);
    if (_debug) {
      this.log.dd(() =>
          "(${list.length + deleteList.length})(${_startFetchTime},${_beginIdx}) save(${list.length}): ${list}, delete(${deleteList.length}): ${deleteList}");
    }
    await _update(time, id);
    if (!list.isEmptyOrNull) {
      // 还有的fetch
      await _fetch(maxTime - 1);
    }
  }
}
