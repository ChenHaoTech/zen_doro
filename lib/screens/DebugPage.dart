import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:device_preview/device_preview.dart';
import 'package:drift/drift.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pasteboard/component/editor/time_eidtor.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/misc/fn_check_list.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_end_widget.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/download_utils.dart';
import 'package:flutter_pasteboard/misc/error_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/feedback_utils.dart';
import 'package:flutter_pasteboard/misc/fnUrlUtils.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_email_utils.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/guide/guide_data.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/misc/log/logger_view.dart';
import 'package:flutter_pasteboard/misc/purchase_utils.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/desktop/dash_board.dart';
import 'package:flutter_pasteboard/screens/desktop/promodo_time_widget.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/stats_widget.dart';
import 'package:flutter_pasteboard/screens/mobile/auth/auth.dart';
import 'package:flutter_pasteboard/screens/mobile/auth/sign_up.dart';
import 'package:flutter_pasteboard/screens/mobile/timeblock/timeblock_edit_mobile.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';
import 'package:universal_io/io.dart';
import 'package:window_manager/window_manager.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final RxString _searchKey = RxString("");
  final String _hiveKey = "_debugPage_search";
  final FocusNode _searchNode = FocusNode();
  final FocusNode _first = FocusNode();

  List<FocusNode> get _focusNodes => [
        _searchNode,
        _first,
      ];

  @override
  void initState() {
    super.initState();
    _searchKey.value = appCache.get(_hiveKey, defaultValue: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('DEBUG'),
        ),
        body: ListView(
          children: [
            Text("packinfo:${FnConst.packageInfo}"),
            ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Obx(() => FnCheckList(
                      title: $kFnDebugRx.value ? 'DEBUG open' : "DEBUG close",
                      valueSupplier: () => $kFnDebugRx.value,
                      onChanged: (val) => $kFnDebugRx.value = val,
                    )),
                Obx(() => FnCheckList(
                      title: kFocusDebug ? 'focus debug' : "focus not debug",
                      valueSupplier: () => $kFocusDebug.value,
                      onChanged: (val) => $kFocusDebug.value = val,
                    )),
                FutureBuilder(
                    future: appCache.asFuture(),
                    builder: (_, snapshot) {
                      var data = snapshot.data;
                      if (data == null) return emptyWidget;
                      return Row(
                        children: [
                          gap12,
                          Text(
                            "account",
                            style: context.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: TextEditingController(text: data.get("account")),
                            onChanged: (val) {
                              data.put("account", val);
                            },
                          ).intrinsicWidth(),
                        ],
                      );
                    })
              ],
            ).boxConstraints(maxHeight: 64),
            TextField(
              focusNode: _searchNode,
              autofocus: true,
              controller: TextEditingController(text: _searchKey.justValue),
              onChanged: (val) {
                _searchKey.value = val;
                appCache.put(_hiveKey, val);
              },
            ),
            gap12,
            Obx(() => Wrap(
                  spacing: 4,
                  children: [
                    _buildBtn("time editor", () {
                      routes.to(() {
                        return TimeEditorDemo();
                      });
                    }),
                    _buildBtn("PromodoTimeWidget", () {
                      routes.to(
                        () => PromodoTimeWidgetDesktop(),
                      );
                    }),
                    _buildBtn("throw exception", () {
                      throw "fuck";
                    }),
                    _buildBtn("PomodoroEndWidget()", () {
                      routes.to(() => PomodoroEndWidget(
                            tb: TimeBlock.emptyFocus(),
                          ));
                    }),
                    _buildBtn("AUDIO", () {
                      var instance = FnAudioService.instance;
                      var players = instance.allDoingingPlayers;
                      if (players.any((element) => element.state == PlayerState.playing)) {
                        instance.stop();
                      } else {
                        instance.start();
                      }
                    }),
                    _buildBtn("LOG", () {
                      Timer.periodic(.2.seconds, (timer) {
                        this.log.dd(() => "fuck ${timer}");
                      });
                      routes.to(() => $LoggerView());
                    }),
                    _buildBtn("STATS PAGE", () async {
                      await windowManager.setSize(Size(1200, 800));
                      await windowManager.center();
                      routes.to(() => StatsWidget());
                    }),
                    _buildBtn("Drift View", () async {
                      Get.to(DriftDbViewer(AppDatabase.get));
                    }),
                    _buildBtn("timeblock card", () async {
                      FnBottomSheet.bottomSheet(TimeBlockEditorMobile(
                        onSubmit: (TimeBlock) {},
                        onDelete: (TimeBlock) {},
                        tb: TimeBlock.emptyCountDownRest(),
                      ));
                    }),
                    _buildBtn("Dashboard", () {
                      DashboardDesktop.showDemo();
                    }),
                  ].whereNotNull().toList(),
                ))
          ],
        )).simpleShortcuts({
      FnActions.FocusNext: () {
        if (!_focusNodes.anyFocus()) {
          _focusNodes.next();
        } else {
          FocusManager.instance.primaryFocus?.nextFocus();
        }
      },
    });
  }

  Widget? _buildBtn(String text, void Function() onInvoke) {
    if (_searchKey.value.isEmpty || text.containsIgnoreCase(_searchKey.value)) {
      return ElevatedButton(
        onPressed: onInvoke,
        child: Text(text),
        focusNode: _first.canRequestFocus ? null : _first,
      );
    }
    return null;
  }
}

abstract class DebugPopUpConfig {
  static List<PopUpMenuConfig> mobilePopConfgs(BuildContext context) {
    return [
      PopUpMenuConfig.diver(),
      PopUpMenuConfig.textBtn("showTextSnackBar", () {
        FnNotification.showTextSnackBar(text: 'fuck');
      }),
      PopUpMenuConfig.textBtn("open disk folder", () {
        FnUriUtils.openDir(applicationDocumentsDirectory);
      }),
      PopUpMenuConfig.textBtn("异常 toast", () {
        ErrorUtils.toast("fuck", stacktrace: StackTrace.current);
      }),
      PopUpMenuConfig.textBtn("showNofitiy_delay", () {
        NativeNotificationService2.instance.show(title: "fuck", context: "ok");
        // DeskTopNativeNotificationService.instance.show(title: "title", context: "context");
        // // Future.delayed(5.seconds, () {
        // //   MobileNativeNotificationService.instance.show(title: "fuck", context: "ok");
        // // });
      }),
      PopUpMenuConfig.textBtn("CLEAR AUDIO", () {
        File(applicationDocumentsDirectory.path + "/" + DownloadConst.Audio).delete(recursive: true);
      }),
      PopUpMenuConfig.textBtn("DB VIEW", () {
        routes.to(() => DriftDbViewer(AppDatabase.get));
      }),
      PopUpMenuConfig.textBtn("Clear ALL TIMEBLOCK", () async {
        var deleteAll = await AppDatabase.get.timeBlockTb.deleteAll();
        BotToast.showText(text: "delete all tb; ${deleteAll}");
      }),
      PopUpMenuConfig.textBtn("pay wall", () async {
        PurchaseUtils.showPurchasePage();
      }),
    ];
  }

  static List<PopUpMenuConfig> deskTopPopConfgs(BuildContext context) {
    return [
      PopUpMenuConfig.textBtn("emial", () {
        FnEmailUtils.sendMail();
      }),
      PopUpMenuConfig.textBtn("删除全部", () {
        var res = AppDatabase.get.delete(AppDatabase.get.timeBlockTb).go();
        Get.rootController.update();
        print("delete time block, res:${res}");
      }),
      PopUpMenuConfig.textBtn("mustGuide", () {
        GuideService.instance.mustGuide();
      }),
      PopUpMenuConfig.diver(),
      PopUpMenuConfig.textBtn("re download", () async {
        AppDatabase.get.reUpload();
      }),
      PopUpMenuConfig.textBtn("DRIFT VIEW", () {
        Get.to(DriftDbViewer(AppDatabase.get));
      }),
      PopUpMenuConfig.textBtn("SIGNUP", () {
        routes.to(() => SignUp());
      }),
      PopUpMenuConfig.diver(),
      PopUpMenuConfig.textBtn("Feed back", () {
        FeedbackUtils.instance.show(context);
      }),
      PopUpMenuConfig.diver(),
      PopUpMenuConfig.textBtn("倒数3秒", () {
        $zenService.updateTimeBlock($zenService.curTimeBlock
            .updateTime(startTime: DateTime.now().subtract(25.minutes), endTime: DateTime.now().add(3.seconds))
            .correctDuration()
            .correctProgressTime());
      }),
      PopUpMenuConfig.textBtn("超时4分钟半了", () {
        $zenService.updateTimeBlock($zenService.curTimeBlock.updateTime(
          startTime: DateTime.now().subtract(30.minutes),
          endTime: DateTime.now().subtract(4.9.minutes),
        ));
      }),
    ];
  }
}
