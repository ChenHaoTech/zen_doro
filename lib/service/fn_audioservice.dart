import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/download_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:get/get.dart';

class FnAudioService extends GetxService {
  late final LoggerWrapper log = LoggerWrapper.build("AudioService");
  final bool debug;

  FnAudioService({
    this.debug = false,
  });

  static FnAudioService get instance => Get.touch(() => FnAudioService(debug: DebugFlag.audio));
  final Map<String, AudioPlayer> audioPlayerMap = {};
  final RxMap<String, PlayerState> audioState = RxMap();
  final Map<String, double> _volumnCache = {};
  final RxList<Rx<AudioConfig>> audioConfigs = RxList([
    AudioConfig(
            id: "1",
            url: "海浪_本地.mp3",
            name: "海浪".i18n,
            volumn: .5,
            extra: {
              "meta": ["隔离效果好", "海浪"]
            }.toJsonStr())
        .obs,
  ]);
  late final Rx<AudioMixs> curAduiMixs = Rx(AudioMixs.empty());
  final RxList<Rx<AudioMixs>> audioMixsList = RxList();

  final RxDouble volume = RxDouble(/*prefs.getDouble("volume") ??*/ 0.5);

  AudioPlayer touchPlayer(String key) {
    return audioPlayerMap.putIfAbsent(
        key,
        () => AudioPlayer()
          ..onPlayerStateChanged.listen((event) {
            audioState[key] = event;
          }));
  }

  @override
  void onClose() {
    audioPlayerMap.values.toList().forEach((e) async {
      await e.stop();
      e.dispose();
    });
    audioPlayerMap.clear();
    audioState.clear();
  }

  Future _updatePlayer(
    FutureOr Function(String key, AudioPlayer) updater, {
    FutureOr<bool> Function(String key, AudioPlayer player)? predict,
  }) async {
    var entries = audioPlayerMap.entries.toList();
    for (var entry in entries) {
      var player = entry.value;
      var key = entry.key;
      if (predict != null && await predict.call(key, player)) {
        await updater.call(key, player);
      } else {
        await updater.call(key, player);
      }
    }
  }

  List<AudioPlayer> get allDoingingPlayers {
    var players = audioPlayerMap.values;
    return players.where((element) => element.isStart).toList();
  }

  @override
  void onInit() async {
    super.onInit();
    volume.listen((p0) async {
      var diff = p0 - volume.lastValue!;
      var volumnConfigs = curAduiMixs.justValue.configs;
      var volumnSum = volumnConfigs.values.sum;
      FnNotification.toast("volume".i18n + " ${diff > 0 ? "+" : ""}${diff.toStringAsFixed(1)}");
      await _updatePlayer((key, i) async {
        var factor = (volumnConfigs[key] ?? 0.5) / volumnSum;
        var volumn = clampDouble(i.volume + diff * factor, 0, 1);
        return await i.setVolume(volumn);
      }, predict: (_, i) => i.state == PlayerState.playing || i.state == PlayerState.paused);
    });
    await touchUpdateConfigs();
    await _initMixsList();
    await _initCurAudioMixs();
  }

  void _ensureIsmute() {
    var isMute = allDoingingPlayers.every((e) => e.isMute);
    SettingService.instance.audioMute.value = isMute;
    this.log.dd(() => "ensuer ismute:${isMute}, doing playing: ${allDoingingPlayers}, stack:${StackTrace.current.invoker}");
  }

  bool get anyPlaying {
    return allDoingingPlayers.any((e) => e.state == PlayerState.playing);
  }

  bool get isMute {
    return SettingService.instance.audioMute.value;
  }

  Future<void> saveMixs([AudioMixs? audioMixs]) async {
    if (audioMixs != null) {
      var rx = audioMixsList.justValue.firstWhereOrNull((e) => e.justValue.uuid == audioMixs.uuid);
      if (rx == null) {
        audioMixsList.add(Rx(audioMixs));
      } else {
        rx.value = audioMixs;
      }
      if (curAduiMixs.justValue.uuid == audioMixs.uuid) {
        curAduiMixs.value = audioMixs;
      }
    }
    var mapToList = audioMixsList.justValue.mapToList((e) => e.justValue.toJson());
    SettingService.instance.mixsList.value = mapToList.toJsonStr();
  }

  Future<void> deleteMixs(String uuid) async {
    var hint = audioMixsList.justValue.removeWhereExt((e) => e.justValue.uuid == uuid);

    if (hint != 0) {
      var mapToList = audioMixsList.justValue.mapToList((e) => e.justValue.toJson());
      SettingService.instance.mixsList.value = mapToList.toJsonStr();
      audioMixsList.refresh();
    }
  }

  Future _initCurAudioMixs() async {
    await SettingService.instance.curMixs.init;
    var value = SettingService.instance.curMixs.value;
    if (!value.isEmptyOrNull && !value.isBlank) {
      var mixs = AudioMixs.fromJson(value.toSafeJson(defaultValue: AudioMixs.empty().toJson()));
      curAduiMixs.value = mixs;
    } else {
      curAduiMixs.value = audioMixsList[0].justValue;
    }
    curAduiMixs.listen((p0) {
      SettingService.instance.curMixs.value = p0.toJsonStr();
    }).bind(this);
  }

  Future touchUpdateConfigs() async {
    var url = "https://gitee.com/chen-hao91/publix_resource/raw/main/audio.json";
    var fileName = url.split("/").last;
    var exist = DownloadUtils.checkFile(fileName: fileName);
    if (exist) {
      var path = DownloadUtils.getPath(fileName: fileName);
      final jsonStr = await File(path).readAsString(encoding: utf8);
      _appendConfigs(jsonStr);
      if (debug) this.log.dd(() => "再次下载; ${url}");
      DownloadUtils.mustDownLoad(url: url, fileName: fileName);
    } else {
      if (debug) this.log.dd(() => "第一次下载; ${url}");
      await DownloadUtils.startDownload(
          url: url,
          fileName: fileName,
          onComplete: (path) async {
            final jsonStr = await File(path).readAsString(encoding: utf8);
            _appendConfigs(jsonStr);
          });
    }
    // todo wifi下直接批量下载
  }

  void _appendConfigs(String jsonStr) {
    if (debug) this.log.dd(() => "[_appendConfigs]开始解析: ${jsonStr}");
    var configs = (json.decode(jsonStr) as List<dynamic>).mapToList((e) => AudioConfig.fromJson(e));
    var justValue = audioConfigs.justValue;
    var newIds = configs.map((e) => e.id).toSet();
    var names = configs.map((e) => e.name).toSet();
    fnassert(() => newIds.length == names.length, ["ids 长度非法", newIds, names]);
    fnassert(() => newIds.length == configs.length, ["ids 长度非法", newIds, configs]);
    if (newIds.length != names.length || newIds.length != configs.length) {
      log.e("配置非法");
      return;
    }
    // 删除
    justValue.removeWhere((i) => configs.any((e) => newIds.contains(i.justValue.id)));
    if (DebugFlag.audio) this.log.dd(() => "删除了 ${newIds}");
    audioConfigs.addAll(configs.mapToList((e) => e.obs));
  }

  Future _initMixsList() async {
    var holder = SettingService.instance.mixsList;
    await holder.init;
    var value = holder.justValue;
    if (value.isEmptyOrNull) {
      fnassert(() => !audioConfigs.isEmpty);
      var configs = audioConfigs.justValue;
      var firstConfig = configs.first.justValue;
      var audioMixs = AudioMixs(uuid: newUuid(), name: firstConfig.name, configs: {firstConfig.id: firstConfig.volumn});
      audioMixsList.add(Rx(audioMixs));
    } else {
      audioMixsList.value = (value.asObjForJson<List<dynamic>>() ?? [])
          .mapToList((e) => AudioMixs.fromJson(e as Map<String, dynamic>))
          .mapToList((e) => e.obs, growable: true);
    }
  }

  void clearUnNeed() async {
    var audioMixs = curAduiMixs.value;
    var configIds = audioMixs.configs.keys.toList();

    var id2Config = audioConfigs.justValue.mapToMap((p0) => p0.justValue.id, (p0) => p0.justValue);
    // clear old
    for (var e in audioPlayerMap.entries.toList()) {
      var id = e.key;
      var player = e.value;
      if (!configIds.contains(id)) {
        audioPlayerMap.remove(id);
        await player.stop();
        player.dispose();
        log.dd(() => "clear ${Key} player");
      }
    }
  }

  Future start() async {
    clearUnNeed();
    var audioMixs = curAduiMixs.value;
    var configIds = audioMixs.configs.keys.toList();
    var id2Config = audioConfigs.justValue.mapToMap((p0) => p0.justValue.id, (p0) => p0.justValue);

    log.i("开始播放:${audioMixs}");

    for (var key in configIds) {
      var player = touchPlayer(key);
      var config = id2Config[key];
      if (config == null) continue;
      if (config.needDownload) {
        var fileName = config.fileName;
        if (!DownloadUtils.checkFile(fileName: fileName, directory: DownloadConst.Audio)) {
          BotToast.showText(text: "音频还未下载".i18n + (kAnyDebug ? fileName : ""));
          continue;
        } else {
          var path = DownloadUtils.getPath(fileName: fileName, directory: DownloadConst.Audio);
          await player.touchPlay(path, volume: isMute ? 0 : config.volumn);
        }
      } else {
        await player.touchPlay(config.localDownloadPath ?? config.url, volume: isMute ? 0 : config.volumn);
      }
    }
  }

  Future pause() async {
    log.dd(() => "pause player, ${curAduiMixs.justValue}");
    await _updatePlayer((_, p0) async {
      await p0.pause();
    }, predict: (_, p0) {
      return p0.state == PlayerState.playing;
    });
  }

  Future toggleMute() async {
    if (!anyPlaying) {
      SettingService.instance.audioMute.value = !SettingService.instance.audioMute.justValue;
      return;
    }
    log.dd(() => "toggleMute player, ${curAduiMixs.justValue}");
    var key2Volumn = curAduiMixs.justValue.configs;
    await _updatePlayer((key, p0) async {
      await p0.toggleMute(
          unMuteVolume: _volumnCache[key] ?? (max(key2Volumn[key] ?? .5, 0.1)),
          onUnMuteVolume: (vol) {
            _volumnCache[key] = vol;
          });
    }, predict: (_, p0) {
      return p0.isStart;
    });
    _ensureIsmute();
  }

  Future stop() async {
    log.dd(() => "stop player, ${curAduiMixs.justValue}");
    for (var player in allDoingingPlayers) {
      if (player.isStart) {
        await player.stop();
      }
    }
  }

  Future resume() async {
    log.dd(() => "resume player, ${curAduiMixs.justValue}");
    for (var player in allDoingingPlayers) {
      if (player.state == PlayerState.paused) {
        await player.resume();
      }
    }
  }
}
