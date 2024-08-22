import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/service/sync/supa_config.dart';
import 'package:flutter_pasteboard/service/sync/supabase/supabase_json_mixin.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ChannelEventType {
  UPDATE("update"),
  INSERT("insert"),
  DELETE("delete"),
  UNKONW("unkonw"),
  ;

  final String key;

  const ChannelEventType(this.key);
}

extension ChannelEventTypeExt on ChannelEventType {
  bool get isUpSert => this == ChannelEventType.UPDATE || ChannelEventType.INSERT == this;
}

mixin SupaBaseChannelMixin on SupaBaseMixin {
  RxInt hintError = RxInt(0);

  // kvChannelMap:  String(table)  -> Map<KvType,Function()>
  // 如果 kvChannelMap 是空, 那么调用_listenerChannel , 否则, 修改kvChannelMap
  final Map<KvType, void Function(ChannelEventType type, Map<String, dynamic> payload)> _kvChannelMap = {};
  Disposer? _kvChanneDispose;

  Disposer listenerJsonChannel(
    KvType kvType, {
    required void Function(ChannelEventType type, Map<String, dynamic> payload) simpleListener,
  }) {
    if (_kvChannelMap.isEmpty) {
      fnassert(() => _kvChanneDispose == null);
      _kvChanneDispose = _listenerChannel("common_key_value", simpleListener: (ChannelEventType type, Map<String, dynamic> payload) {
        if (payload["type"] != kvType.code) return;
        _kvChannelMap[kvType]?.call(type, payload);
      });
    }

    fnassert(() => _kvChannelMap[kvType] == null, [
      _kvChannelMap.keys,
    ]);
    _kvChannelMap[kvType] = simpleListener;
    return Disposer(() {
      _kvChannelMap.remove(kvType);
      if (_kvChannelMap.isEmpty) {
        _kvChanneDispose?.dispose();
        _kvChanneDispose = null;
      }
    });
  }

  Disposer _listenerChannel(String table,
      {void Function(ChannelEventType type, Map<String, dynamic> newSn)? simpleListener,
      void Function(ChannelEventType type, Map<String, dynamic> newSn, [Map<String, dynamic> oldSn, dynamic ref])? rawListener}) {
    fnassert(() => AccountService.tryFind!.isLogin);
    // 可变局部变量
    late RealtimeChannel channel;
    var live = true;
    Duration wait = 1.seconds;

    // 重建 channel
    RealtimeChannel buildChannel() {
      var c = Supabase.instance.client.channel('public:$table').onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            callback: (payload) async {
              var type = payload.eventType;
              if (payload.newRecord["update_appid"] == appUuid) {
                DebugUtils.log("listenerChannel ignore self update,type: ${type}, raw: ${payload.newRecord["update_appid"]}");
                return;
              }
              //todo 这里加上 时间比较 ({id->time/*修改时间*/} func(ids))
              this.log.dd(() => "listenerChannel type: ${type},data:${payload}");
              var changeType = ChannelEventType.values.firstWhere((e) => e.key == type.name, orElse: () => ChannelEventType.UNKONW);
              simpleListener?.call(changeType, payload.newRecord);
              rawListener?.call(changeType, payload.newRecord, payload.oldRecord);
            },
          );
      c.subscribe((status, error) async {
        this.log.dd(() => "RealtimeChannel-status change: status: ${status}, error: ${error}");
        if (status == RealtimeSubscribeStatus.subscribed || status == RealtimeSubscribeStatus.closed) return;
        this.log.w("RealtimeChannel error: ${error}, state: ${status}, rebind");
        hintError.value++;
        await channel.unsubscribe();
        if (live) {
          // 重新绑定(每次延迟指定时间)
          Future.delayed(wait, () {
            if (!live) return;
            channel = buildChannel();
            wait = clampInt((wait.inSeconds * 2), 2, 60 * 10).seconds;
          });
        }
      });
      return c;
    }

    channel = buildChannel();
    return Disposer(() {
      this.log.dd(() => "dispose RealtimeChannel");
      channel.unsubscribe();
      live = false;
    });
  }
}
