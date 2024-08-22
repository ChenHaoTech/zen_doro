import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/fn_getx/fn_obx_widget.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/fn_textbtn.dart';
import 'package:flutter_pasteboard/component/misc/fn_check_chip.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/misc/debounce.dart';
import 'package:flutter_pasteboard/misc/download_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';
import 'package:universal_io/io.dart';

import '../download/download_widget.dart';

void showAuioMixWidget() {
  if (!Get.context!.isMobile) {
    FnDialog.show(Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: AudioMixWidget().paddingAll(24),
    ));
  } else {
    FnBottomSheet.bottomSheet(Scaffold(
      resizeToAvoidBottomInset: false,
      body: AudioMixWidget(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(32),
        child: Row(
          children: [
            Icon(Icons.keyboard_arrow_down_outlined).opacity(.4).inkWell(onTap: () {
              Get.back();
            }),
            Spacer(),
            FnCheckChip(
              title: "背景音".i18n,
              valueSupplier: () => !FnAudioService.instance.isMute,
              onChanged: (val) => FnAudioService.instance.toggleMute(),
            ),
            gap12,
          ],
        ),
      ),
    ));
  }
}

class AudioMixWidget extends StatefulWidget {
  const AudioMixWidget({super.key});

  @override
  State<AudioMixWidget> createState() => _AudioMixWidgetState();
}

class _AudioMixWidgetState extends State<AudioMixWidget> {
  FnAudioService get service => FnAudioService.instance;
  final double _saveBoxHeight = 64;

  RxList<Rx<AudioConfig>> get _audioConfigs => service.audioConfigs;
  final RxBool _dirty = RxBool(false);

  Map<String, AudioPlayer> get _audioMap => service.audioPlayerMap;

  RxMap<String, PlayerState> get _audioState => service.audioState;
  late bool downloadAll = true;

  late final Rx<AudioMixs> _curAudioMixs = Rx(service.curAduiMixs.justValue);

  void _updateCurAduioMixs(Map<String, double> Function(Map<String, double>) updater) {
    var value = _curAudioMixs.justValue;
    var newConfigs = updater.call(value.configs);
    if (value.configs.entries.deepEqual(newConfigs.entries)) {
      this.log.dd(() => "没有变化不修改");
      return;
    }
    _curAudioMixs.value = value.copyWith(configs: newConfigs);
    service.saveMixs(_curAudioMixs.value);
  }

  RxList<Rx<AudioMixs>> get _audioMixsList => service.audioMixsList;
  final Set<String> _markAudoPlay = {};
  late Rx<String> _searchKey = Rx("");

  @override
  void dispose() async {
    super.dispose();
    service.curAduiMixs.value = _curAudioMixs.justValue;
    service.clearUnNeed();
  }

  final RxBool _hintSearch = RxBool((PlatformUtils.isDesktop || PlatformUtils.isWeb) ? true : false);
  final cmdAltS = FnKeys.cmdAltS;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ListView(
        shrinkWrap: true,
        children: [
          Text(
            "已保存的混音".i18n,
            style: context.titleLarge,
          ),
          gap4,
          ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildUnSaved(),
              gap12,
              Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _audioMixsList.mapToList((e) => _buildSaved(e)),
                  )),
            ],
          ).boxConstraints(maxHeight: _saveBoxHeight),
          gap8,
          _buildSearch(context),
          gap12,
          ..._audioConfigs
              .sorted((a, b) => _curAudioMixs.justValue.configs.containsKey(a.justValue.id) ? -1 : 1)
              .mapToList((i) => _buildAudioCard(i)),
        ],
      ).paddingSymmetric(horizontal: 8, vertical: 4),
    ).simpleShortcuts(
      {
        FnKeys.cmdS: () => _saveCur(),
        cmdAltS: () {
          _newas.value = true;
          _newAsFsn.requestFocus();
        },
        FnKeys.cmdF: () {
          _hintSearch.value = true;
          _textFieldFsn.requestFocus();
        },
        FnActions.TogglePlayPauseMix: () => _onToggle(),
        FnActions.NextTask: () => FocusManager.instance.primaryFocus?.nextFocus(),
        FnActions.FocusPrevious: () => FocusManager.instance.primaryFocus?.previousFocus(),
      },
      isRoot: true,
    );
  }

  final GlobalKey _textFieldKey = GlobalKey();
  late final textEditingController = TextEditingController(text: _searchKey.justValue);
  final FocusNode _textFieldFsn = FocusNode();

  Widget _buildSearch(BuildContext context) {
    return FnObxValue(() {
      var textField = TextField(
        key: _textFieldKey,
        focusNode: _textFieldFsn,
        decoration: InputDecoration(
          hintText: "输入要过滤的字段".i18n,
          border: InputBorder.none,
        ),
        controller: textEditingController,
        maxLines: 1,
        autofocus: true,
        onChanged: (val) {
          DebounceUtils.debounce("audio_search_update", .3.seconds, () {
            if (!mounted) return;
            _searchKey.value = val;
          });
        },
      ).action({
        DismissIntent: SimpleCallbackAction<DismissIntent>(() {
          Get.back();
        }),
      });
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "音频".i18n,
                style: context.titleLarge,
              ),
              Icon(
                _hintSearch.justValue ? Icons.search_off : Icons.search,
                size: 20,
              ).paddingSymmetric(horizontal: 8).inkWell(onTap: () {
                var toggle = _hintSearch.toggle().justValue;
                if (toggle) _textFieldFsn.requestFocus();
              }),
              Spacer(),
              TextButton(
                  onPressed: () {
                    setState(() {
                      downloadAll = true;
                    });
                  },
                  child: Text("下载全部".i18n)),
              Obx(() {
                var anyPlayCnt = _audioState.values.where((e) => e == PlayerState.playing).length;
                if (_dirty.value) {
                  return FnTextBtn(
                    text: "保存 (%s)".i18n.fill([anyPlayCnt]),
                    onPressed: () {
                      _saveCur();
                    },
                  ).guideToolTip(FnKeys.cmdS);
                }

                if (anyPlayCnt != 0) {
                  return FnTextBtn(
                    text: "暂停 (%s)".i18n.fill([anyPlayCnt]),
                    onPressed: () {
                      _onToggle();
                    },
                  ).guideToolTip(FnKeys.cmdEnter);
                } else {
                  return FnTextBtn(
                    text: "播放 (%s)".i18n.fill([_curAudioMixs.value.configs.length]),
                    onPressed: () {
                      _onToggle();
                    },
                  ).guideToolTip(FnKeys.cmdEnter);
                }
              })
            ],
          ),
          if (_hintSearch.justValue) textField.paddingSymmetric(vertical: 4),
        ],
      );
    }, [_hintSearch]);
  }

  void _onToggle() async {
    if (_audioMap.values.any((e) => e.state == PlayerState.playing)) {
      _audioMap.values.forEach((e) => e.stop());
    } else {
      await _ensurePlayMixs(_curAudioMixs.justValue);
    }
  }

  void _saveCur() {
    _dirty.value = false;
    _updateCurAduioMixs((p0) {
      var entries = _audioMap.entries;
      Map<String, double> map = {};
      for (var e in entries) {
        var player = e.value;
        if (player.state == PlayerState.playing) {
          map[e.key] = player.volume;
        }
      }
      this.log.i("保存当前的 audioMixs :${map}");
      BotToast.showText(text: "%s 保存成功(%s)".i18n.fill([_curAudioMixs.justValue.name, map.length]));
      return map;
    });
  }

  void _setCurAudioMixs(AudioMixs audioMixs) {
    if (_curAudioMixs.justValue == audioMixs) return;
    _curAudioMixs.value = audioMixs;
    var configs = audioMixs.configs;
    for (var rx in _audioConfigs.justValue) {
      var origin = rx.justValue;
      var volumn = configs[origin.id];
      if (volumn != null) {
        rx.value = origin.copyWith(volumn: volumn);
      }
    }
  }

  Future<void> _ensurePlayMixs(AudioMixs audioMixs) async {
    var ids = audioMixs.configs.keys.toSet();
    var playingIds = _audioState.entries.where((pair) => pair.value == PlayerState.playing).mapToList((e) => e.key);
    if (ids.deepEqual(playingIds)) {
      return;
    }

    for (var player in _audioMap.values) {
      await player.stop();
    }

    var id2Configs = _audioConfigs.mapToMap((p0) => p0.justValue.id, (p0) => p0.justValue);
    for (var id in ids) {
      var config = id2Configs[id];
      fnassert(() => config != null, id2Configs);
      var path = config!.localDownloadPath;
      if (path != null && !File(path).existsSync()) {
        BotToast.showText(text: "请先下载 %s".i18n.fill([config.name.i18n]));
        return;
      }
      touchPlay(() => _touchPlayer(id), path ?? config.url, config);
    }
  }

  Future<void> _updateAudioMixsName() async {
    var audioMixs = _curAudioMixs.justValue;
    var editingController = TextEditingController(text: audioMixs.name);

    void _submit() {
      audioMixs = audioMixs.copyWith(name: editingController.text);
      _curAudioMixs.value = audioMixs;
      service.saveMixs(audioMixs);
    }

    return FnDialog.showDefault(
        autoFocusConfirm: false,
        title: "重命名".i18n,
        content: TextField(
          autofocus: true,
          controller: editingController,
          decoration: InputDecoration(
            hintText: "命名为...".i18n,
            border: InputBorder.none,
          ),
          onSubmitted: (val) {
            _submit();
            Get.back();
          },
        ),
        onConfirm: () {
          _submit();
          Get.back();
        });
  }

  Widget _buildSaved(Rx<AudioMixs> rx) {
    return Obx(() {
      var mixs = rx.value;
      var hitSelected = _curAudioMixs.value == mixs;
      var dirty = _dirty.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mixs.name),
          if (hitSelected)
            FnPopUpMenu(
              configs: [
                PopUpMenuConfig.textBtn("PLAY".i18n, () {
                  _ensurePlayMixs(mixs);
                }),
                PopUpMenuConfig.textBtn("RENAME".i18n, () {
                  _updateAudioMixsName();
                }),
                if (dirty && hitSelected)
                  PopUpMenuConfig.textBtn("SAVE".i18n, () {
                    _saveCur();
                  }),
              ],
              child: Icon(
                Icons.more_vert_sharp,
                size: 16,
              ).opacity(.6),
            ),
          if (dirty && hitSelected) Text("*"),
        ],
      )
          .paddingSymmetric(horizontal: 8, vertical: 4)
          .material(
            color: hitSelected ? context.onBackground.withOpacity(.15) : context.onBackground.withOpacity(.04),
          )
          .inkWell(
              onTap: () async {
                var audioMixs = rx.justValue;
                _setCurAudioMixs(audioMixs);
                _onToggle();
              },
              onSecondaryTapUp: hitSelected
                  ? null
                  : (detail) async {
                      var offset = detail.globalPosition;
                      double left = offset.dx;
                      double top = offset.dy;
                      await showMenu(
                          context: context,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          position: RelativeRect.fromDirectional(
                              textDirection: Directionality.of(context), start: left, top: top, end: left + 2, bottom: top + 2),
                          items: [
                            PopupMenuItem(
                              child: Text(
                                "Delete",
                                style: context.bodyMedium.copyWith(
                                  color: context.colorScheme.error,
                                ),
                              ),
                              onTap: () {
                                service.deleteMixs(rx.justValue.uuid);
                              },
                            )
                          ]);
                    });
    });
  }

  final RxBool _newas = false.obs;
  late final FocusNode _newAsFsn = FocusNode();

  Widget _buildUnSaved() {
    return Obx(() {
      if (_newas.value) {
        return Focus(
          onFocusChange: (focus) {
            if (!focus) _newas.value = false;
          },
          child: TextField(
            autofocus: true,
            focusNode: _newAsFsn,
            decoration: InputDecoration(
              hintText: "新混音命名为..".i18n,
              border: InputBorder.none,
            ),
            onSubmitted: (val) {
              var allPlayingPlayers = _audioState.entries.where((pair) => pair.value == PlayerState.playing).map((e) => e.key).toList();
              var audioMixs = AudioMixs(
                uuid: newUuid(),
                name: val.takeIf((i) => i.isNotEmpty) ?? "未命名".i18n,
                configs: allPlayingPlayers.mapToMap((p0) => p0, (p0) {
                  var volumn = _audioConfigs.justValue.where((e) => e.justValue.id == p0).first.justValue.volumn;
                  return volumn;
                }),
              );
              _setCurAudioMixs(audioMixs);
              service.saveMixs(audioMixs);
              _dirty.value = false;
              _newas.value = false;
            },
          ).intrinsicWidth(),
        );
      } else {
        return Text(
          "新建混音为...".i18n,
          style: context.titleSmall.copyWith(
            decoration: TextDecoration.underline,
            color: context.onBackground.withOpacity(.6),
          ),
        ).center().inkWell(
          onTap: () {
            _newas.value = true;
          },
        ).guideToolTip(cmdAltS);
      }
    });
  }

  Widget _buildAudioCard(Rx<AudioConfig> rx) {
    return Obx(() {
      var config = rx.value;
      if (!_searchKey.value.isEmptyOrNull) {
        var match = config.name.i18n.fzfMath(_searchKey.value) || config.meta.any((e) => e.i18n.fzfMath(_searchKey.value));
        if (!match) return emptyWidget;
      }

      if (config.url.isEmpty) return emptyWidget;

      /*url非空*/
      var meta = config.meta;
      playerSupplier() => _touchPlayer(config.id);

      Widget _titleBuilder(void Function()? onTap, [bool needDownload = false, Widget? append]) {
        return FnObxValue(() {
          final iconSize = 20.0;
          var data = _audioState[config.id];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            hoverColor: Colors.transparent,
            onTap: onTap,
            title: Wrap(
              children: [
                Text(config.name.i18n),
                if (append != null) append,
                // if (kDebugMode) Text("_audioMap: ${_audioMap[config.id]?.urlOrPath}\n state:${_audioState[config.id]}"),
              ],
            ),
            titleTextStyle:
                context.titleMedium.copyWith(color: _curAudioMixs.value.configs.containsKey(config.id) ? context.primary : context.onBackground),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return Wrap(
                    spacing: 8,
                    children: meta.mapToList((e) => Chip(
                          label: Text(
                            e.i18n,
                            // style: context.defaultTextStyle.withOpacity(.8).withSmaller(2),
                          ),
                          labelStyle: context.defaultTextStyle.withOpacity(.8).withSmaller(2),
                          // padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                          visualDensity: VisualDensity.compact,
                        )),
                  );
                }),
                if (data == PlayerState.playing)
                  Row(
                    children: [
                      Obx(() => Text("${rx.value.volumn.toStringAsFixed(1)}")),
                      _buildVolumn(rx, playerSupplier).expand(),
                    ],
                  ),
              ],
            ).paddingOnly(
              top: 4,
            ),
            trailing: Builder(builder: (_) {
              var iconSize = 32.0;
              if (needDownload) {
                return Icon(
                  Icons.download,
                  size: iconSize,
                );
              }
              if (data == null) {
                return Icon(
                  Icons.play_arrow_outlined,
                  size: iconSize,
                );
              }
              if (data == PlayerState.playing) {
                return Icon(
                  Icons.pause_outlined,
                  color: context.primary,
                  size: iconSize,
                );
              } else if (data == PlayerState.paused) {
                return Icon(
                  Icons.play_arrow_outlined,
                  size: iconSize,
                );
              } else {
                return Icon(
                  Icons.play_arrow_outlined,
                  size: iconSize,
                );
              }
            }).easyTap(onTap: onTap),
          );
        }, [_audioState]);
      }

      if (config.needDownload) {
        var fileName = config.fileName;
        // DebugUtils.log("audio_mix_widget:556 \n${StackTrace.current}");
        return DownloadWidget(
          key: ValueKey(config.url + "${downloadAll}"),
          url: config.url,
          fileName: fileName,
          directory: DownloadConst.Audio,
          onInit: (func) {
            if (downloadAll) {
              // DebugUtils.log("audio_mix_widget:565 开始自动下载 ${config.url}\n${StackTrace.current}");
              func.call();
            }
            return _titleBuilder(() {
              func.call();
              _markAudoPlay.add(config.id);
            }, true);
          },
          onComplete: (String path) {
            if (_markAudoPlay.contains(config.id)) {
              _markAudoPlay.remove(config.id);
              touchPlay(playerSupplier, path, config);
            }
            return _titleBuilder(() {
              _dirty.value = true;
              if (playerSupplier().state == PlayerState.playing) {
                playerSupplier().pause();
              } else {
                touchPlay(playerSupplier, path, config);
              }
            }, false);
          },
          onProgress: (double progress) {
            return _titleBuilder(null, true, Text("Downloading".i18n).paddingOnly(left: 8).opacity(.6)).ignorePointer();
          },
        );
      } else {
        return _titleBuilder(() async {
          _dirty.value = true;
          if (playerSupplier().state == PlayerState.playing) {
            playerSupplier().pause();
          } else {
            playerSupplier().touchPlay(config.url, volume: config.volumn);
          }
        });
      }
    });
  }

  AudioPlayer _touchPlayer(String id) {
    return service.touchPlayer(id);
  }

  Future<dynamic> touchPlay(AudioPlayer playerSupplier(), String path, AudioConfig config) async {
    try {
      await playerSupplier().touchPlay(path, volume: config.volumn);
    } catch (e) {
      this.log.e("播放失败:${config}", e);
      BotToast.showText(text: "播放失败,请重新下载".i18n);
      var path = config.localDownloadPath!;
      _audioMap.remove(config.id);
      _audioState.remove(config.id);
      var file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildVolumn(Rx<AudioConfig> rx, AudioPlayer playerSupplier()) {
    void _update(double val) {
      rx.value = rx.justValue.copyWith(volumn: clampDouble(val, 0, 1));
      playerSupplier().setVolume(val);
      _updateCurAduioMixs((p0) {
        if (!p0.containsKey(rx.justValue.id)) {
          return p0;
        }
        Map<String, double> map = Map.from(p0);
        map[rx.justValue.id] = val;
        return map;
      });
    }

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 16),
        trackHeight: 12, // change height here
      ),
      child: Slider(
          inactiveColor: context.onBackground.withOpacity(.2),
          value: rx.justValue.volumn,
          onChanged: (val) {
            _update(val);
          }),
    );
  }
}
