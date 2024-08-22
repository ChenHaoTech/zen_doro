//todo 待写

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/exception/assert_exception.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

late final Rx<bool> $kFnDebugRx = kDebugMode.obs
  ..apply((it) async {
    var key = "_kFnDebug";
    it.value = appCache.get(key) ?? false;
    it.listen((event) async {
      appCache.put(key, event);
      Get.rootController.update();
    });
  });

bool get kFnDebug => $kFnDebugRx.value;

late final Rx<bool> $kFocusDebug = false.obs
  ..apply((it) {
    it.listen((value) {
      if (value) {
        FocusManager.instance.addListener(_onFocusChaneg);
      } else {
        FocusManager.instance.removeListener(_onFocusChaneg);
      }
    });
  });

bool get kFocusDebug => $kFocusDebug.value;

void _onFocusChaneg() {
  var node = FocusManager.instance.primaryFocus;
  if (node != null) {
    if (kDebugMode) {
      var data = (node.ancestors.map((e) => e.debugLabel ?? "")).join(",") +
          "\n" +
          "**" +
          (node.debugLabel ?? node.toString()) +
          "**" +
          "\n" +
          node.traversalChildren.map((e) => e.debugLabel ?? "").join(",");
      BotToast.showText(text: data);
    }
  }
}

bool get kAnyDebug => $kFnDebugRx.value | kDebugMode;

@pragma('vm:prefer-inline')
Future<bool> fnassert(
  FutureOr<bool> Function() condition, [
  Object? msg,
  StackTrace? stackTrace,
  String Function()? append,
]) async {
  if (!kAnyDebug) {
    return true;
  }
  stackTrace ??= StackTrace.current;
  final c = await condition.call();
  var _msg = '${msg} ${append?.call() ?? ""}';
  if (msg == null && append == null) {
    _msg = stackTrace.toString();
  }
  if (!c && kAnyDebug) {
    throw AssertException(message: _msg, stackTrace: stackTrace);
  }
  return true;
}

Future<void> fnDebug(Function debugger) {
  return debugger();
}

var _uuidInstance = const Uuid();

newUuid() => _uuidInstance.v4();

extension JsonStringEx on Object {
  // 忽略大小写
  Map<String, T> toSafeJson<T>({Map<String, T>? defaultValue}) {
    try {
      return json.decode(toString());
    } catch (e) {
      logger.e("[toSafeJson]parse json fail,obj:${this},T:${T}", e);
      return defaultValue ?? {};
    }
  }

  Map<String, dynamic>? tryToJson() {
    try {
      return json.decode(toString());
    } catch (e) {
      logger.e("[tryToJson]parse json fail,obj:${this}", e);
      return null;
    }
  }
}

abstract class FnPage extends StatelessWidget {
  String get pageName;

  FnPage({super.key});
}

FutureOr<T> traceFuture<T>(FutureOr<T> Function() runnable, String key) async {
  var t1 = DateTime.now();
  var res = await runnable();
  var t2 = DateTime.now();
  var diff = t2.difference(t1).inMilliseconds;
  // assert(diff <= 32, "${key} 花费过多时间: ${diff}ms");
  log("[trace] ${key}: ${diff} ms");
  return res;
}

T trace<T>(T Function() runnable, String key) {
  var t1 = DateTime.now();
  var res = runnable();
  var t2 = DateTime.now();
  var diff = t2.difference(t1).inMilliseconds;
  // assert(diff <= 32, "${key} 花费过多时间: ${diff}ms");
  log("[trace] ${key}: ${diff} ms");
  return res;
}

extension GetExt on GetInterface {
  //get.touch
  S putNew<S>(S dep, [String? tag, bool? permanent]) {
    var getInstance = GetInstance();
    return getInstance.put<S>(dep, tag: tag ?? newUuid(), permanent: permanent ?? false);
  }

  // tryFind
  S? tryFind<S>({String? tag}) {
    var getInstance = GetInstance();
    var isr = getInstance.isPrepared<S>(tag: tag) || getInstance.isRegistered<S>(tag: tag);
    if (!isr) return null;
    return getInstance.find<S>(tag: tag);
  }

  S touch<S>(S Function() supplier, {String? tag, bool? permanent}) {
    var getInstance = GetInstance();
    var isr = getInstance.isRegistered<S>(tag: tag);
    if (isr) return getInstance.find<S>(tag: tag);
    var instance = supplier();
    return getInstance.put<S>(
      instance,
      permanent: permanent ?? false,
      tag: tag,
    );
  }
}

void runOnNextFrame(FutureOr Function() runnable, {int yieldCnt = 1}) {
  StackTrace trace = StackTrace.current;
  void _runnable() async {
    try {
      if (yieldCnt == 1) {
        runnable.call();
        return;
      }
      yieldCnt--;
      Get.engine.addPostFrameCallback((timeStamp) {
        _runnable();
      });
    } catch (e) {
      logger.e("runOnNextFrame fail", e, trace);
      throw e;
    }
  }

  Get.engine.addPostFrameCallback((timeStamp) {
    _runnable();
  });
}

int clampInt(int value, int min, int max) {
  if (value < min) {
    return min;
  } else if (value > max) {
    return max;
  } else {
    return value;
  }
}

class Disposer {
  FutureOr Function() _disposer;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  Disposer(this._disposer);

  static Disposer empty() {
    return Disposer(() {});
  }

  FutureOr dispose() async {
    await _disposer();
    _isDisposed = true;
  }

  bind(DisposableInterface ds) {
    ds.disposeFunc.add(() => this._disposer());
  }

  // 重写操作符 += 以便于使用 += 语法糖
  Disposer operator +(Disposer other) {
    var disposer = () async {
      await _disposer();
      await other._disposer();
    };
    return Disposer(_disposer);
  }
}

mixin StateDisposeMixin<T extends StatefulWidget> on State<T> {
  final List<Disposer> _dispose = [];

  @override
  void dispose() {
    super.dispose();
    for (var i in _dispose) {
      i.dispose();
    }
  }
}
