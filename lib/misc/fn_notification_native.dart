import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

export "./fn_notification_native.dart";

Future<void> configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

class NativeNotificationService1 extends GetxService {
  static NativeNotificationService1 get instance => Get.touch(() => NativeNotificationService1._());
  late Future init;

  NativeNotificationService1._() {
    // 只桌面端, 如果是移动端, 走flutter_local_notifications
    fnassert(() => PlatformUtils.isDesktop, "不是桌面端");
  }

  Future<void> show({
    required String title,
    required String context,
    String? subtitle,
    bool slient = false,
  }) async {
    await init;
    final notification = LocalNotification(
      // 用来生成通用唯一识别码
      identifier: newUuid(),
      title: title,
      subtitle: subtitle,
      body: context,
      // 用来设置是否静音
      silent: slient,
    );
    notification.onClose = (LocalNotificationCloseReason reason) {
      // BotToast.showText(text: '通知已经关闭: ${reason}');
    };
    notification.onClick = () {
      $windowService.requestWindowShow();
      notification.close();
    };
    notification.show();
  }

  @override
  void onInit() async {
    super.onInit();
    init = localNotifier.setup(
      appName: FnConst.appName,
      // 仅 Windows
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class NativeNotificationService2 extends GetxService {
  static NativeNotificationService2 get instance => Get.touch(() => NativeNotificationService2._());

  NativeNotificationService2._();

  final Completer _completer = Completer();

  Future get future => _completer.future;
  int id = 0;
  late final DarwinInitializationSettings initializationSettingsDarwin;
  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

  @override
  void onInit() async {
    super.onInit();
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux ? null : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      var selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse?.payload;
      this.log.i("selectedNotificationPayload: ${selectedNotificationPayload}");
      //todo 测试通知跳转
      routes.offHome();
    }

    await configureLocalTimeZone();
    initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        this.log.i("onDidReceiveLocalNotification: {}");
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      //todo 安卓配置
      // android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      // linux: initializationSettingsLinux,
    );
    //todo 测试后台进入
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        log.i("notificationResponse.notificationResponseType: (${notificationResponse.notificationResponseType}) ${notificationResponse}");
        // switch (notificationResponse.notificationResponseType) {
        //   case NotificationResponseType.selectedNotification:
        //     selectNotificationStream.add(notificationResponse.payload);
        //     break;
        //   case NotificationResponseType.selectedNotificationAction:
        //     if (notificationResponse.actionId == navigationActionId) {
        //       selectNotificationStream.add(notificationResponse.payload);
        //     }
        //     break;
        // }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    _completer.complete();
    this.log.dd(() => "flutterLocalNotifications init end");
  }

  Future<bool?> requestPermission() async {
    await future;
    final bool? result =
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
    log.i("IOS MOBILE requestPermission: ${result}");
    return result;
  }

  Future<void> schedule({
    required String title,
    required String context,
    required Duration duration,
  }) async {
    await future;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id++,
        title,
        context,
        tz.TZDateTime.now(tz.local).add(duration),
        const NotificationDetails(
            android: AndroidNotificationDetails('alarm_clock_channel', 'Alarm Clock Channel', channelDescription: 'Alarm Clock Notification')),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  void show({
    required String title,
    required String context,
  }) async {
    await future;
    if (PlatformUtils.isAndroid) return;
    //todo 测试安卓通知
    await requestPermission();
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(id++, title, context, notificationDetails);
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  //todo 测试后台进入
  // ignore: avoid_print
  logger.i('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    logger.i('notification action tapped with input: ${notificationResponse.input}');
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
