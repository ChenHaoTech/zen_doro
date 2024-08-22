import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/account/account_future_widget.dart';
import 'package:flutter_pasteboard/component/audio/audio_mix_widget.dart';
import 'package:flutter_pasteboard/component/fn_getx/fn_obx_widget.dart';
import 'package:flutter_pasteboard/component/setting/flutter_settings_ui.dart';
import 'package:flutter_pasteboard/component/setting/setting_function.dart';
import 'package:flutter_pasteboard/component/setting/setting_item_widget.dart';
import 'package:flutter_pasteboard/component/setting/setting_mics_widget.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/short_cut/hotkey_virtual_view.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fnUrlUtils.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/guide/guide_data.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/purchase_utils.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:get/get.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:rich_clipboard/rich_clipboard.dart';
import 'package:ui_extension/ui_extension.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置".i18n),
      ),
      body: SettingView(),
    );
  }
}

void showSettingDialog() {
  FnDialog.show(SettingView());
}

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  SettingService get service => SettingService.instance;
  final FocusNode searchFsn = FocusNode();
  final FocusNode focusNode = FocusNode();
  final FocusNode backgroupFsn = FocusNode();
  final GlobalKey _searchkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return buildBuildSettingsAdaptive(context)
        .inkWell(onTap: () {
          backgroupFsn.requestFocus();
        })
        .focus(
          autofocus: true,
          focusNode: backgroupFsn,
        )
        .simpleShortcuts({
          FnActions.FocusSettingsSearch: () {
            _requestSearch();
          },
          FnActions.FocusNext: () {
            FocusManager.instance.primaryFocus?.nextFocus();
          },
          FnActions.FocusPrevious: () {
            FocusManager.instance.primaryFocus?.previousFocus();
          },
        }, isRoot: true);
  }

  void _requestSearch() {
    if (_searchkey.currentContext != null) {
      Scrollable.ensureVisible(_searchkey.currentContext!);
    }
    runOnNextFrame(() => searchFsn.requestFocus());
  }

  final RxString _selectTitle = RxString("");
  late final SettingController controller = Get.put(SettingController());
  late final searchController = TextEditingController(text: controller.searchKey.justValue);
  final RxBool _expandShorts = RxBool(PlatformUtils.isMobile ? false : true);
  final String _AudioWidgetTitle = "自定义音频".i18n;
  final String _accountMembershipTitle = "账户与会员".i18n;
  final String _themeAndLanguagehipTitle = "样式和本地化语言".i18n;
  final String _pomodoroTitle = "Pomodoro".i18n;
  final String _feedbackTitle = 'Feedback'.i18n;
  final String _devTitle = 'Dev'.i18n;

  final String _newUserGuideTitle = '新手引导'.i18n;

  final String _shortcutTitle = '应用内快捷键'.i18n;
  final String _globalShortcutTitle = '全局快捷键'.i18n;

  late final List<String> _titles = [
    _accountMembershipTitle,
    _newUserGuideTitle,
    _themeAndLanguagehipTitle,
    _pomodoroTitle,
    if (PlatformUtils.isDesktop) _globalShortcutTitle,
    _shortcutTitle,
    _feedbackTitle,
    _devTitle,
  ];

  Widget buildBuildSettingsAdaptive(BuildContext context) {
    var settingsList = buildSettingsList(context);
    if (context.isMobile) return settingsList;
    return Row(
      children: [
        buildNavigator().paddingSymmetric(vertical: 24).expand(flex: 1),
        FnObxValue(() {
          if (_selectTitle.value == _AudioWidgetTitle) return AudioMixWidget().paddingSymmetric(horizontal: 32, vertical: 24);
          return settingsList;
        }, [_selectTitle]).expand(flex: 4),
      ],
    );
  }

  Obx buildNavigator() {
    return Obx(() {
      return Column(
        children: [
          ListView(
            children: _titles.mapToList((e) {
              return ListTile(
                onTap: () {
                  _selectTitle.value = e;
                  if (_selectTitle.justValue == _shortcutTitle) {
                    _expandShorts.value = true;
                  }
                },
                selected: e == _selectTitle.value,
                title: Text(
                  e,
                ),
              );
              return TextButton(
                  onPressed: () {},
                  child: Text(
                    e,
                  )).material();
            }),
          ).expand(),
          Obx(() => ListTile(
                selected: _selectTitle.value == _AudioWidgetTitle,
                title: Text(_AudioWidgetTitle),
                onTap: () => _selectTitle.value = _AudioWidgetTitle,
              )),
        ],
      );
    });
  }

  Widget buildSettingsList(BuildContext context) {
    return SettingsList(
      shrinkWrap: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12),
      lightTheme: SettingsThemeData(
        settingsListBackground: context.cs.background,
        settingsSectionBackground: context.cs.background,
      ),
      darkTheme: SettingsThemeData(
        settingsListBackground: context.cs.background,
        settingsSectionBackground: context.cs.background,
      ),
      sections: [
        CustomSettingsSection(
          child: gap12,
        ),
        CustomSettingsSection(
          child: TextField(
            key: _searchkey,
            focusNode: searchFsn,
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索设置...'.i18n, // 占位符文本
              border: OutlineInputBorder(
                // 边框样式
                borderRadius: BorderRadius.circular(20.0),
              ),
              suffixIcon: Icon(Icons.close).inkWell(onTap: () {
                searchController.clear();
                SettingController.find.searchKey.value = "";
                _expandShorts.value = false;
              }),
              prefixIcon: Icon(Icons.search), // 前缀图标
            ),
            onChanged: (String value) {
              // 这里可以添加你的搜索逻辑
              SettingController.find.searchKey.value = value;
              _expandShorts.value = true;
            },
          ).paddingSymmetric(horizontal: 32),
        ),
        // SearchSettingSection(child: ,),
        SearchSettingSection(
          searchKeys: [
            "账户".i18n,
            "会员".i18n,
            "login".i18n,
            "logout".i18n,
            "account".i18n,
            "upgrade".i18n,
            "sync".i18n,
          ],
          child: SettingsSection(
            title: buildTitle(_accountMembershipTitle),
            tiles: [
              _buildAccountInfo(context),
              _buildSyncInfo(context),
            ],
          ),
        ),
        SearchSettingSection(
          searchKeys: [
            "引导".i18n,
            "新手".i18n,
          ],
          child: SettingsSection(
            title: buildTitle(_newUserGuideTitle),
            tiles: [
              SettingsTile(
                title: Text('删除新手引导模板数据'.i18n),
                description: Builder(builder: (context) {
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '这将删除所有新手引导模板数据，此操作不可逆，请谨慎操作。'.i18n, // 原始文本
                          style: context.defaultTextStyle,
                        ),
                        TextSpan(
                          text: ' 重新添加'.i18n, // 要添加的文本
                          style: context.linkStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await GuideService.instance.mustGuide();
                            },
                        ),
                      ],
                    ),
                  );
                }),
                trailing: TextButton(
                    onPressed: () async {
                      var cnt = await GuideService.instance.deleteGuide();
                      if (cnt != 0) {
                        FnNotification.toast("删除成功，共删除了$cnt条数据。".i18n);
                      }
                    },
                    child: Text("DELETE".i18n)),
              ),
            ],
          ),
        ),
        SearchSettingSection(
          searchKeys: [
            "theme".i18n,
            "主题".i18n,
            "样式".i18n,
            "本地化".i18n,
            "语言".i18n,
          ],
          child: SettingsSection(
            title: buildTitle(_themeAndLanguagehipTitle),
            tiles: [
              SettingsTile(
                title: Text('本地化语言'.i18n),
                description: Text('更改应用的显示语言'.i18n),
                leading: Icon(Icons.language),
                trailing: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  var values = FnLocalUtils.supportLocals.mapToList((e) => (e.getLocaleDisplayName(), e));
                  return buildDropdownMenu(I18n.of(context).locale, values, (value) {
                    FnLocalUtils.updateLocal(context, value);
                  });
                }),
              ),
            ],
          ),
        ),
        CustomSettingsSection(
          child: FnObxValue(() {
            List<SettingItemWidget> children = [
              service.autoRest,
              service.autoFocus,
              service.sessionResumptionTime,
              service.smallestLifeOfRest,
              service.biggestLifeOfRest,
              service.smallestLifeOfTask,
              service.smartRestFactor,
              service.canNotify,
              if (service.canNotify.justValue) service.overtimeReminder,
            ].where((e) {
              var config = service.configs[e.key];
              if (config == null) return false;
              return config.match(SettingController.find.searchKey.justValue);
            }).mapToList((e) {
              var config = service.configs[e.key]!;
              var iconData = service.iconDatas[e.key];
              return SettingItemWidget(
                focusNode: FocusNode(),
                settingKey: e.key,
                title: config.title,
                type: SettingType.from(config.type),
                description: config.description,
                icon: iconData,
              );
            }).toList();
            if (children.isEmpty) return emptyWidget;
            return SettingsSection(
              title: buildTitle(_pomodoroTitle),
              tiles: children,
            );
          }, [
            SettingController.find.searchKey,
            service.canNotify.rx,
          ]),
        ),
        // 快捷键
        if (PlatformUtils.isDesktop)
          SearchSettingSection(
            searchKeys: ["窗口".i18n, "快捷键".i18n, "全局快捷键".i18n, _globalShortcutTitle.i18n],
            child: CustomSettingsSection(
              child: SettingsSection(
                title: buildTitle(_globalShortcutTitle),
                tiles: [
                  CustomSettingsTile(child: ShortCutSetWidget()),
                ],
              ),
            ),
          ),
        SearchSettingSection(
          searchKeys: [
            ...inappactions.mapToList((e) => e.title),
            ...inappactions.mapToList((e) => e.description).whereNotNull(),
            "快捷键",
            "快捷键".i18n,
          ],
          child: CustomSettingsSection(
              child: FnObxValue(() {
            var searchKey = SettingController.find.searchKey.justValue;
            var children = inappactions
                .where((e) {
                  return e.title.fzfMath(searchKey) || (e.description?.fzfMath(searchKey) ?? false);
                })
                .mapToList((e) => ListTile(
                      title: Text(e.title),
                      subtitle: e.description != null ? Text(e.description!).opacity(.6) : null,
                      trailing: ShortcutVitualView(
                        keySet: e.keySet,
                      ),
                    ))
                .mapToList((e) => CustomSettingsTile(
                      child: e,
                    ));
            if (children.isEmpty) return emptyWidget;
            return Obx(() => SettingsSection(
                  title: Row(
                    children: [
                      buildTitle(_shortcutTitle),
                      Spacer(),
                      Obx(() => IconButton(
                          onPressed: () => _expandShorts.toggle(),
                          icon: Icon(
                            _expandShorts.value ? Icons.expand_less : Icons.expand_more,
                          )))
                    ],
                  ).inkWell(onTap: () => _expandShorts.toggle()),
                  tiles: _expandShorts.value
                      ? children
                      : [
                          CustomSettingsTile(
                            child: Text("%s 个快捷键配置".i18n.fill([children.length.toString()])).paddingSymmetric(horizontal: 20),
                          ),
                        ],
                ));
          }, [SettingController.find.searchKey])),
        ),
        SearchSettingSection(
          searchKeys: [
            'Feedback'.i18n,
            'feedback and support'.i18n,
            'Contact '.i18n,
          ],
          child: SettingsSection(
            title: buildTitle(_feedbackTitle),
            tiles: [
              SettingsTile(
                title: Text('Ask Feature/Report'.i18n),
                description: Text('We welcome your feedback and support!🙏'.i18n),
                leading: Icon(Icons.feedback_outlined),
                onPressed: (BuildContext context) {
                  FnUriUtils.openUrl(FnConst.reportUrl);
                },
              ),
              if (!FnConst.feedbackInfos.isEmptyOrNull)
                SettingsTile(
                  title: Text('Contact us.'),
                  description: ListView(
                      scrollDirection: Axis.horizontal,
                      children: FnConst.feedbackInfos.mapToList((e) => Text("${e.label}: ${e.value}").inkWell(onTap: () {
                            RichClipboard.setData(RichClipboardData(text: e.value));
                            BotToast.showText(text: "copy \"${e.value}\"");
                          }))).sizedBox(height: 32),
                  leading: Icon(Icons.people),
                  // onPressed: (BuildContext context) {
                  //   FnUriUtils.openUrl(FnConst.reportUrl);
                  // },
                ),
            ],
          ),
        ),
        SearchSettingSection(
          searchKeys: [
            'AppInfo'.i18n,
            'Dev'.i18n,
          ],
          child: SettingsSection(
            title: buildTitle(_devTitle),
            tiles: [
              SettingsTile(
                title: Text('AppInfo'.i18n),
                description: Text("version: %s".i18n.fill([FnConst.version])),
                leading: Icon(Icons.info_outline),
                onPressed: (BuildContext context) {
                  RichClipboard.setData(RichClipboardData(text: FnConst.version));
                  BotToast.showText(text: "copy \"${FnConst.version}\"");
                },
              ),
              CustomSettingsTile(
                child: AccountFuture(builder: (find) {
                  return FutureBuilder(
                      future: find.loginSuccessFuture,
                      builder: (_, snap) {
                        var instance = find;
                        return SettingsTile(
                          title: Text('用户信息'.i18n),
                          description: snap.data != true ? Text("未登入".i18n) : Text("${instance?.userName},${instance?.email},${instance?.userId}"),
                          leading: Icon(Icons.code_off_outlined),
                          onPressed: snap.data != true
                              ? null
                              : (BuildContext context) {
                                  RichClipboard.setData(RichClipboardData(text: instance?.$innerUser?.toString()));
                                  BotToast.showText(text: "copy user session".i18n);
                                },
                        );
                      });
                }),
              ),
            ],
          ),
        ),
        CustomSettingsSection(
          child: Divider(),
        ),
        SearchSettingSection(
          searchKeys: [
            "privacy".i18n,
            "terms".i18n,
          ],
          child: CustomSettingsSection(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(),
              _buildUnderLine(
                "privacy".i18n,
                style: context.bodyMedium,
              ).inkWell(onTap: () {
                FnUriUtils.openUrl(FnConst.privateUrl);
              }),
              gap12,
              _buildUnderLine(
                "terms".i18n,
                style: context.bodyMedium,
              ).inkWell(onTap: () {
                FnUriUtils.openUrl(FnConst.termsUrl);
              }),
              Spacer(),
            ],
          )),
        ),
        CustomSettingsSection(
          child: SizedBox(height: 42),
        ),
      ],
    );
  }

  SettingsTile _buildSyncInfo(BuildContext context) {
    return SettingsTile(
      trailing: _buildProWidget(
        onPro: Text("重新同步".i18n).inkWell(onTap: () async {
          await AppDatabase.get.reUpload();
          AppDatabase.get.reDownload();
        }),
        onUnPro: Text("upgrade".i18n).inkWell(onTap: () {
          PurchaseUtils.showPurchasePage();
        }),
      ),
      title: AccountFuture(builder: (find) {
        return Obx(() {
          var value = TimeBlockStore.find.unSyncCnt.value;
          return Text(value == 0 && find.isLogin
              ? "全都同步啦🤟".i18n
              : "未同步%s个时间块".i18n.fill([
                  value,
                ]));
        });
      }),
      description: _buildProWidget(
          onPro: Text('已经同步%s个时间块'.i18n.fill([TimeBlockStore.find.syncedCnt.value])),
          onUnPro: Text("升级以同步%s个时间块".i18n.fill([
            TimeBlockStore.find.unSyncCnt.value,
          ]))),
    );
  }

  SettingsTile _buildAccountInfo(BuildContext context) {
    return SettingsTile(
      trailing: AccountFuture(builder: (find) {
        return FutureBuilder(
            future: find.loginSuccessFuture,
            builder: (_, snap) {
              if (snap.data == true) {
                return TextButton(
                    onPressed: () {
                      find.logout();
                      routes.offSignUp();
                    },
                    child: Text("Login Out".i18n));
              }
              return TextButton(
                  onPressed: () {
                    fnassert(() => !find!.isLogin);
                    routes.offSignUp();
                  },
                  child: Text("Login In".i18n));
            });
      }),
      title: AccountFuture(builder: (find) {
        return FutureBuilder(
            future: find.loginSuccessFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.data != true
                  ? Text(
                      "未登入".i18n,
                      style: context.defaultTextStyle.withColor(context.primary),
                    ).inkWell(onTap: () => routes.offSignUp())
                  : _buildUserAccountTitle();
            });
      }),
      description: Builder(builder: (context) {
        var onPro = Text("Premium membership.".i18n);
        var onUnPro = RichText(
            text: TextSpan(
          text: 'Regular membership. '.i18n,
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: 'upgrade'.i18n,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // 在此处添加链接的操作
                  PurchaseUtils.showPurchasePage();
                },
            ),
          ],
        ));
        return _buildProWidget(onPro: onPro, onUnPro: onUnPro);
      }),
    );
  }

  Widget _buildUserAccountTitle() {
    return Builder(builder: (context) {
      return AccountFuture(builder: (find) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(find.userName ?? ""),
            Text(
              find.email ?? "",
              style: context.defaultTextStyle.withSmaller(1).withOpacity(.7),
            ),
          ],
        );
      });
    });
  }

  Widget _buildProWidget({required Widget onPro, required Widget onUnPro}) {
    return FutureBuilder(
        future: PurchaseUtils.checkPro(),
        builder: (_, snap) {
          return snap.data == true ? onPro : onUnPro;
        });
  }

  Widget buildTitle(String title) {
    return Builder(builder: (context) {
      return Obx(() {
        if (title == _selectTitle.value && context.findRenderObject() != null) {
          Scrollable.ensureVisible(context);
        }
        return Text(
          title,
          style: context.titleLarge,
        );
      });
    });
  }

  Text _buildUnderLine(String title, {TextStyle? style}) {
    return Text(
      title,
      style: (style ?? context.settingSubTitle).copyWith(
        decoration: TextDecoration.underline,
        decorationColor: context.primary,
      ),
    );
  }
}
