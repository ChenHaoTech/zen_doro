/// logger 扩展
library logger_extension;

import 'dart:async';

import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/fn_logger_out_put.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

late final _level = kAnyDebug ? Level.trace : Level.info;
LoggerWrapper logger = LoggerWrapper.build("[DEFAULT]");
Logger _$logger = Logger(
  level: _level,
  output: $LogOutput(),
  printer: PrettyPrinter(
    excludePaths: [
      "package:flutter_pasteboard/misc/log",
      "package:flutter_pasteboard/misc/log/logger_extension.dart",
      "package:flutter_pasteboard/misc/function.dart",
    ],
    methodCount: 2,
    // Number of method calls to be displayed
    errorMethodCount: 16,
    // Number of method calls if stacktrace is provided
    lineLength: 120,
    // Width of the output
    colors: true,
    // Colorful log messages
    printEmojis: true,
    // Print an emoji for each log message
  ),
  filter: ProductionFilter(),
);

extension LoggerExt on Object {
  LoggerWrapper get log {
    return LoggerWrapper(_$logger, this.runtimeType.toString());
  }
}

class LoggerWrapper {
  final Logger _logger;
  final String prefix;

  const LoggerWrapper(this._logger, this.prefix);

  static LoggerWrapper build(String prefix) {
    return LoggerWrapper(_$logger, prefix);
  }

  LoggerWrapper get(String prefix) {
    return LoggerWrapper(_logger, '${this.prefix}.${prefix}');
  }

  bool _shouldDebugLog() {
    return _level.value <= Level.debug.value || kAnyDebug;
  }

  void dd(FutureOr<String> Function() supplier, [StackTrace? stackTrace]) async {
    stackTrace ??= StackTrace.current;
    if (_shouldDebugLog())
      _logger.d(
        "[${DateTime.now()}]👋👋👋[${prefix}]: ${await supplier()}",
        stackTrace: stackTrace,
      );
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e("[ERROR][${prefix}] ${message}", error: error ?? message, stackTrace: stackTrace ?? StackTrace.current);
  }

  void w(dynamic message, [StackTrace? stackTrace]) {
    _logger.w("[WARN][${prefix}] ${message}", stackTrace: stackTrace ?? StackTrace.current);
  }

  void i(dynamic message, [StackTrace? stackTrace]) {
    _logger.i("[${prefix}]" + message, stackTrace: stackTrace ?? StackTrace.current);
  }
}

// shake 未完全 要包一层

extension LoggerEx on Logger {
  LoggerWrapper wrap(Object obj, [String? key]) {
    return LoggerWrapper(_$logger, obj.runtimeType.toString() + (key ?? ""));
  }
}
