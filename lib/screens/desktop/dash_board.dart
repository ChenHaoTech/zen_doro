import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/account/account_future_widget.dart';
import 'package:flutter_pasteboard/component/setting/setting_page_share.dart';
import 'package:flutter_pasteboard/component/short_cut/ShortProvider.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/tag/tag_widget.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fnUrlUtils.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:flutter_pasteboard/misc/log/logger_view.dart';
import 'package:flutter_pasteboard/screens/DebugPage.dart';
import 'package:flutter_pasteboard/screens/desktop/promodo_time_widget.dart';
import 'package:flutter_pasteboard/screens/stats_page_share.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/service/sync/sync_function.dart';
import 'package:flutter_pasteboard/service/sync/sync_helper.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:get/get.dart';
import 'package:local_hero/local_hero.dart';
import 'package:ui_extension/ui_extension.dart';

const _iconSize = 20.0;

class DashboardDesktop extends StatefulWidget {
  final int initialIdx;

  const DashboardDesktop({
    super.key,
    this.initialIdx = 0,
  });

  @override
  State<DashboardDesktop> createState() => _DashboardDesktopState();

  static void showDemo() {
    routes.to(() => DashboardDesktop());
  }
}

class _DashboardDesktopState extends State<DashboardDesktop> {
  late int _selectedIndex = widget.initialIdx;
  late final FocusNode _focusNode;

  final List<(Widget, Widget)> binder = [
    (
      Icon(
        Icons.access_time_outlined,
        size: _iconSize,
      ),
      PromodoTimeWidgetDesktop(),
    ),
    (
      Icon(
        Icons.query_stats,
        size: _iconSize,
      ),
      StatsPageAdaptive(),
    ),
    (
      Icon(
        Icons.tag,
        size: _iconSize,
      ),
      TagsWidget(),
    ),
    if (kAnyDebug)
      (
        Icon(
          Icons.logo_dev,
          size: _iconSize,
        ),
        DebugPage(),
      ),
    if (kAnyDebug)
      (
        Icon(
          Icons.text_snippet_outlined,
          size: _iconSize,
        ),
        $LoggerView(),
      ),
  ];

  @override
  void initState() {
    super.initState();
    fnassert(() => binder.length > 0, binder);
    _focusNode = FocusNode(debugLabel: "_dashboard");
    requestDashBoard = true;
    TimeBlockStore.find;
    TagStore.find;
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    requestDashBoard = false;
  }

  void _showSetting() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  Widget buildBody() {
    if (_selectedIndex == -1) {
      return SettingView();
    }
    var widget = binder.getNullable(_selectedIndex)?.$2;
    if (widget == null) {
      return Text("${_selectedIndex}");
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return LocalHeroScope(
      child: ShortcutRooter(
        child: Scaffold(
          body: Row(
            children: <Widget>[
              Column(
                children: [
                  ...() {
                    List<Widget> icons = [];
                    for (int i = 0; i < binder.length; i++) {
                      var child = binder[i].$1.paddingAll(8);
                      child = child.material(
                        color: _selectedIndex == i ? context.onBackground.withOpacity(.1) : Colors.transparent,
                        radius: 8,
                      );
                      var icon = child.inkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = i;
                          });
                        },
                      ).tooltip("${FnModifyString.metaAdaptive} ${i + 1}");
                      icons.add(icon);
                    }
                    return icons;
                  }(),
                  Spacer(),
                  Obx(() {
                    return __buildNavBtn(
                      SyncMangerController.instance.computeIconData(),
                      _selectedIndex == -2,
                      () {
                        batchSync();
                      },
                      FnActions.Download.keySet,
                    );
                  }),
                  gap12,
                  AccountFuture(builder: (find) {
                    return FutureBuilder(
                        future: find.loginSuccessFuture,
                        builder: (_, snap) {
                          if (snap.data != true) {
                            return __buildNavBtn(FnIcons.login, false, () {
                              find.logout();
                              routes.offSignUp();
                            });
                          }
                          return emptyWidget;
                        });
                  }),
                  __buildNavBtn(FnIcons.feedback, false, () {
                    FnUriUtils.openUrl(FnConst.reportUrl);
                  }).tooltip("反馈".i18n),
                  __buildNavBtn(
                    Icons.settings,
                    _selectedIndex == -1,
                    () {
                      _showSetting();
                    },
                    FnActions.OpenSettingsPage.keySet,
                  ),
                  gap48,
                ],
              ).paddingOnly(
                top: 24,
              ),
              const VerticalDivider(thickness: 1, width: 1),
              // This is the main content.
              Expanded(
                child: buildBody(),
              ),
            ],
          ),
        ).simpleShortcuts(
          {
            FnActions.OpenSettingsPage: () => _showSetting(),
            FnActions.Download: () => batchSync(),
          },
          focusNode: _focusNode,
        ).focus(
          onKey: (_, event) {
            if (event.onlyMetaPressedAdaptive) {
              var num1_9 = FnKeys.num0_9.sublist(1, FnKeys.num0_9.length);
              for (int i = 0; i < num1_9.length; i++) {
                if (i >= binder.length) break;
                if (event.isKeyPressed(num1_9[i])) {
                  setState(() {
                    _selectedIndex = i;
                  });
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          },
        ).focusScope(),
      ),
    );
  }

  Widget __buildNavBtn(IconData data, bool selected, void onTap(), [LogicalKeySet? hotKey]) {
    var inkWell = Icon(
      data,
      size: _iconSize,
    )
        .paddingAll(8)
        .material(
          color: selected ? context.onBackground.withOpacity(.1) : Colors.transparent,
          radius: 8,
        )
        .inkWell(
          onTap: onTap,
        );
    if (hotKey != null) {
      return inkWell.guideToolTip(hotKey);
    } else {
      return inkWell;
    }
  }
}
