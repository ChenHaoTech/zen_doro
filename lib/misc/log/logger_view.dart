import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/fn_textbtn.dart';
import 'package:flutter_pasteboard/component/search_highlight/search_highlight_text.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debounce.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:logger/logger.dart' hide FileOutput;
import 'package:ui_extension/ui_extension.dart';

class LoggerHistoryController extends GetxService {
  static LoggerHistoryController get instance => Get.touch(() => LoggerHistoryController());
  final RxList<OutputEvent> _logs = RxList();
  void Function(OutputEvent event)? onLogCallback;
  final Rx<(String, Level)> _filter = Rx(("", Level.all));
  final Rx<bool> _displayLine = Rx(false);
  final Rx<bool> _displayStackTrace = Rx(false);

  void clear() {
    _logs.clear();
  }

  void onLog(OutputEvent event) {
    _logs.add(event);
    if (_logs.length > 10000) {
      _logs.removeRange(0, 5000 - _logs.length);
    }
    onLogCallback?.call(event);
  }
}

class $LoggerView extends StatefulWidget {
  const $LoggerView({super.key});

  @override
  State<$LoggerView> createState() => _$LoggerViewState();
}

class _$LoggerViewState extends State<$LoggerView> {
  final controller = LoggerHistoryController.instance;
  final Rx<LogEvent?> _curEvent = Rx(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64 + 4 + 12 * 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            gap12,
            Row(
              children: [
                if (context.isMobile)
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.chevron_left_outlined,
                      )),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(hintText: "输入要过滤的字段".i18n),
                  onChanged: (val) {
                    var filter = controller._filter.justValue;
                    controller._filter.value = (
                      val,
                      filter.$2,
                    );
                  },
                  maxLines: 1,
                ).expand(),
                FnPopUpMenu(configs: [
                  PopUpMenuConfig.textBtn("ALL", () {
                    var filter = controller._filter.justValue;
                    controller._filter.value = (
                      filter.$1,
                      Level.all,
                    );
                  }),
                  PopUpMenuConfig.textBtn("WARN", () {
                    var filter = controller._filter.justValue;
                    controller._filter.value = (
                      filter.$1,
                      Level.warning,
                    );
                  }),
                  PopUpMenuConfig.textBtn("ERROR", () {
                    var filter = controller._filter.justValue;
                    controller._filter.value = (
                      filter.$1,
                      Level.error,
                    );
                  }),
                ])
              ],
            ).boxConstraints(maxHeight: 48),
            Row(
              children: [
                Obx(() {
                  if (controller._displayStackTrace.value) {
                    return Text("不展示stacktrace");
                  }
                  return Text("展示stacktrace");
                }).inkWell(onTap: () => controller._displayStackTrace.toggle()),
                gap12,
                Obx(() {
                  if (controller._displayLine.value) {
                    return Text("不展示lines");
                  }
                  return Text("展示lines");
                }).inkWell(onTap: () => controller._displayLine.toggle()),
                Spacer(),
                FnTextBtn.simple(
                    onPressed: () {
                      this.log.dd(() => "ffff");
                      ;
                    },
                    text: "log"),
                gap12,
              ],
            ),
            Divider(),
          ],
        ),
      ),
      body: Obx(() {
        return Row(
          children: [
            Obx(
              () {
                var filter = controller._filter.value;
                var logs = controller._logs.whereToList(
                  (i) {
                    var str_f = filter.$1;
                    return i.level.value >= filter.$2.value &&
                        (i.origin.message.toString().contains(str_f) ||
                            (i.origin.stackTrace?.toString().contains(str_f) ?? false) ||
                            (i.origin.error?.toString().contains(str_f) ?? false));
                  },
                );
                return ListView.builder(
                  itemBuilder: (_, idx) {
                    var event = logs[idx];
                    return _buildEvent(event);
                  },
                  itemCount: logs.length,
                );
              },
            ).expand(flex: 3),
            if (_curEvent.value != null && context.isDesktop) _buildView().expand(flex: 1),
          ],
        );
      }),
    ).simpleShortcuts({LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyL): () => LoggerHistoryController.instance.clear()});
  }

  SingleChildScrollView _buildView() {
    return SingleChildScrollView(
      child: SelectionArea(
        child: Text("""
          ${_curEvent.value?.message}
          ${_curEvent.value?.error}
          ${_curEvent.value?.stackTrace}
          """),
      ),
    );
  }

  Widget _buildEvent(OutputEvent event) {
    var origin = event.origin;
    return Builder(builder: (context) {
      return SelectionArea(
        onSelectionChanged: (_) {
          if (event.origin != _curEvent.value) {
            runOnNextFrame(() => FnBottomSheet.bottomSheet(_buildView()));
          }
          _curEvent.value = event.origin;
        },
        child: Obx(
          () {
            var filter = controller._filter.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(FnDateUtils.humanReadable(origin.time)),
                    gap4,
                    () {
                      switch (event.level) {
                        case Level.error:
                        case Level.fatal:
                          return Text("[ERROR]",
                              style: context.bodySmall.copyWith(
                                backgroundColor: Colors.red,
                              ));
                        case Level.warning:
                          return Text("[WARN]",
                              style: context.bodySmall.copyWith(
                                backgroundColor: Colors.yellow,
                              ));
                        default:
                          return Text("[${event.level.name}]", style: context.bodySmall);
                      }
                    }(),
                    gap12,
                    SearchHighlightText(
                      origin.message,
                      searchText: filter.$1,
                      overflow: TextOverflow.ellipsis,
                    ).expand(),
                  ],
                ),
                DefaultTextStyle(
                  style: context.bodySmall.copyWith(
                    fontSize: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (origin.error != null)
                        SearchHighlightText(
                          origin.error!.toString(),
                          searchText: filter.$1,
                        ),
                      if (controller._displayStackTrace.value && origin.stackTrace != null)
                        SearchHighlightText(
                          origin.stackTrace!.toString(),
                          searchText: filter.$1,
                        ),
                      if (controller._displayLine.value && event.lines.isNotEmpty)
                        SearchHighlightText(
                          event.lines.join("\n"),
                          searchText: filter.$1,
                        ),
                    ],
                  ).paddingOnly(
                    left: 12,
                  ),
                )
              ],
            );
          },
        ),
      );
    });
  }
}
