import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/service/sync/supa_config.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupaBaseMixin extends GetxService {
  GoTrueClient get auth {
    return Supabase.instance.client.auth;
  }

  FunctionsClient get function {
    return Supabase.instance.client.functions;
  }

  SupabaseClient get client {
    return Supabase.instance.client;
  }
}

mixin SupaBaseJsonMixin on SupaBaseMixin {
  AccountService get _accountService => AccountService.tryFind!;

  Future<String?> get(KvType type, String key) async {
    var value = (await client).from('common_key_value').select("${uuid_key},${body_key}").eq("type", type.code).eq(uuid_key, key);
    return (await value.maybeSingle()) as String?;
  }

  final uuid_key = "uuid";
  final body_key = "body";
  final modified_at_key = "modified_at";
  final state_key = "state";

  Future<List<Map<String, dynamic>>> batchGet(
    KvType type, {
    DateTime? beginMtime,
    String? beginId,
    int limit = 50,
    bool debug = false,
    required void Function(DateTime? maxModifiedTime, String? id) onMaxFlagChange,
    required void Function(List<String> uuids) onDeleted,
  }) async {
    var list = await $batchGetInner(type, beginMtime: beginMtime, beginId: beginId, limit: limit, debug: debug);
    //todo 这里加上 时间比较 ({id->time/*修改时间*/} func(ids))
    var item = list.lastOrNull;
    var maxModified = list.mapToList((e) => DateTime.parse(e[modified_at_key])).maxByMapper((p0) => p0.millisecondsSinceEpoch);
    // var maxId = list.mapToList((e) => e[uuid_key] as String).maxOrNull;
    if (item != null) {
      onMaxFlagChange.call(maxModified, item[uuid_key]);
    }

    var deleteList = list.whereToList((element) => element[state_key] == KvState.delete.code);
    onDeleted.call(deleteList.mapToList((e) => e[uuid_key]));

    return list.where((e) => e[state_key] != KvState.delete.code).mapToList((e) => (e[body_key] as String).toSafeJson());
  }

  Future<List<Map<String, dynamic>>> $batchGetInner(
    KvType type, {
    DateTime? beginMtime,
    String? beginId,
    int limit = 50,
    bool debug = false,
  }) async {
    await _accountService.loginSuccessFuture;
    var jsonQuery = client.from('common_key_value').select("${uuid_key},${body_key},${modified_at_key},${state_key}").eq("type", type.code);
    if (beginMtime != null) jsonQuery = jsonQuery.gte(modified_at_key, beginMtime.toUtc().toIso8601String());
    if (beginId != null) jsonQuery = jsonQuery.gt(uuid_key, beginId);
    // 先排序id,在排序修改时间, 然后选择最大的修改时间, (因为是id排序, 所以修改时间会错乱开)
    var builder = jsonQuery.order(uuid_key, ascending: true).order("${modified_at_key}", ascending: true);
    builder = builder.limit(limit);
    var list = ((await builder) as List<dynamic>);
    if (debug) {
      this.log.dd(() => "list: ${list}");
    }
    return list.map((val) => val as Map<String, dynamic>).toFixedList();
  }

  Future<void> batchUpsertJson(
    List<(KvType, String, Map<String, dynamic>)> list, {
    KvState state = KvState.normal,
  }) async {
    var current = StackTrace.current;
    await _accountService.loginSuccessFuture;
    this.log.dd(() => "batchUpsertJson: list:${list}\n${current}");
    await (await client)
        .from('common_key_value')
        .upsert(list
            .map((e) => {
                  "user_id": _accountService.userId,
                  "type": e.$1.code,
                  uuid_key: e.$2,
                  body_key: e.$3,
                  state_key: state.code,
                  "update_appid": appUuid,
                })
            .toList())
        .contains(uuid_key, list.mapToList((e) => e.$2));
  }

  Future<void> batchDeleteJson(List<(KvType, String)> list) async {
    if (list.isEmpty) return;
    var param = list.mapToList((e) => (e.$1, e.$2, <String, dynamic>{}));
    try {
      await batchUpsertJson(param, state: KvState.delete);
    } catch (e) {
      this.log.w("batchDeleteJson fail ,${list}, ${e}");
    }
  }
}
