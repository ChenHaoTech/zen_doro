import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/screens/desktop/dash_board.dart';
import 'package:flutter_pasteboard/screens/mobile/auth/auth.dart';
import 'package:flutter_pasteboard/screens/mobile/promodo_home_mobile.dart';
import 'package:get/get.dart';

final Routes routes = Routes();

extension AccountExt on Routes {
  offHome() {
    if (Get.context!.isMobile) {
      Get.offAll(() => PomodoroHomeMobile());
    } else {
      Get.offAll(() => DashboardDesktop());
    }
  }

  offSignUp() {
    if (Get.context!.isMobile) {
      Get.offAll(() => SignUp());
    } else {
      Get.offAll(() => SignUp());
    }
  }
}

class Routes {
  Future<T?>? offAll<T>(
    Widget Function() pageSupplier, {
    bool opaque = false,
    Transition? transition,
    Curve? curve = Curves.linear,
    Duration? duration,
    String? routeName,
    bool fullscreenDialog = false,
    dynamic arguments,
    void Function()? binding,
    bool preventDuplicates = true,
  }) async {
    return await Get.offAll<T>(
      pageSupplier,
      opaque: opaque,
      transition: transition,
      curve: curve,
      duration: duration,
      routeName: routeName,
      fullscreenDialog: fullscreenDialog,
      arguments: arguments,
      binding: binding?.fnmap((val) => BindingsBuilder(val)),
    );
  }

  Future<T?>? off<T>(
    Widget Function() pageSupplier, {
    bool opaque = false,
    Transition? transition,
    Curve? curve = Curves.linear,
    Duration? duration,
    int? id,
    String? routeName,
    bool fullscreenDialog = false,
    dynamic arguments,
    void Function()? binding,
    bool preventDuplicates = true,
  }) async {
    return await Get.off<T>(
      pageSupplier,
      opaque: opaque,
      transition: transition,
      curve: curve,
      duration: duration,
      id: id,
      routeName: routeName,
      fullscreenDialog: fullscreenDialog,
      arguments: arguments,
      binding: binding?.fnmap((val) => BindingsBuilder(val)),
      preventDuplicates: preventDuplicates,
    );
  }

  Future<T?>? to<T>(
    Widget Function() pageSupplier, {
    bool? opaque,
    Transition? transition,
    Curve? curve = Curves.linear,
    Duration? duration,
    int? id,
    String? routeName,
    bool fullscreenDialog = false,
    dynamic arguments,
    void Function()? binding,
    bool preventDuplicates = true,
    bool? popGesture,
    double Function(BuildContext context)? gestureWidth,
  }) async {
    return await Get.to<T>(
      pageSupplier,
      opaque: opaque,
      transition: transition,
      curve: curve,
      duration: duration,
      id: id,
      routeName: routeName,
      fullscreenDialog: fullscreenDialog,
      arguments: arguments,
      binding: binding?.fnmap((val) => BindingsBuilder(val)),
      preventDuplicates: preventDuplicates,
      popGesture: popGesture,
      gestureWidth: gestureWidth,
    );
  }
}

class PageParam {
  final Map<String, dynamic> _map;

  static PageParam? get current {
    if (Get.arguments is PageParam) {
      return Get.arguments as PageParam;
    }
    return null;
  }

  PageParam(this._map);

  T? get<T>(String key) {
    if (_map[key] is T) {
      return _map[key] as T;
    }
    return null;
  }
}
