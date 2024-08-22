import 'dart:developer';
import 'package:universal_io/io.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/error_widget/error_stack.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/debounce.dart';
import 'package:flutter_pasteboard/misc/exception/assert_exception.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

void $handleError() {
  var log = LoggerWrapper.build("_handleError");
  FlutterError.onError = (details) {
    var msg = details.exception;
    var stack = details.stack;
    if (details.exception is AssertException) {
      var exception = details.exception as AssertException;
      msg = exception.message;
      stack = exception.stackTrace ?? stack;
    }
    log.e(
      "[${details.library}] ${msg}",
      details.exception,
      stack,
    );
    $_handleError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    var orginStack = stack;
    if (error is AssertException) {
      var exception = error as AssertException;
      error = exception.message;
      stack = exception.stackTrace ?? stack;
    }
    log.e("PlatformDispatcher.instance.onError, orginStack:${orginStack}", error, stack);
    $_handleError(FlutterErrorDetails(exception: error, stack: stack));
    return true;
  };

  ErrorWidget.builder = ErrorStack.errorWidget;
}

int _errorHint = 0;
Disposer? _disposer;

void $_handleError(FlutterErrorDetails detail) {
  _errorHint++;
  if (_errorHint >= 500) {
    _disposer?.dispose();
    _errorHint = 0;
    if (kDebugMode) {
      exit(0);
    }
  }
  if (_errorHint >= 50) {
    _back();
    return;
  }
  _disposer = DebounceUtils.debounce("error_reset", 5.seconds, () {
    _errorHint = 0;
  });

  void __skip() {}
  void __showError() {}

  if (detail.exception.toString() == "Stack Overflow") {
    debugger();
  }
  switch (detail.library) {
    case "widgets library":
      __showError();
    case "rendering library":
      var context = detail.context.toString();
      if (context == "during layout") {
        __skip();
      } else {
        //during performLayout ()resize
        _back();
        __showError();
      }
    case "gesture":
      __showError();
    default:
      _back();
      __showError();
  }
}

void _back() {
  runOnNextFrame(() => Get.back());
}

/*=======debug=======*/
Future _debugHive() async {
  await initFlutter(kDebugMode ? "debug" : null);
}

Future _debugInitPath() async {
  applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
}

Future _debugInitWindow() async {
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: Size(600, 300),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: true,
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: false,
      ), () {
    windowManager.show();
  });
}

void debugRunApp(Widget widget) async {
  WidgetsFlutterBinding.ensureInitialized();
  await hotKeyManager.unregisterAll();
  await _debugInitWindow();
  await _debugInitPath();
  await _debugHive();
  runApp(widget);
  hotKeyManager.register(HotKey(KeyCode.keyK, modifiers: [KeyModifier.control]), keyDownHandler: (_) async {
    if (await windowManager.isFocused()) {
      await windowManager.hide();
    } else {
      await windowManager.show();
    }
  });
}
