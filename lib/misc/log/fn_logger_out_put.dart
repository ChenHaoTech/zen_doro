import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/error_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_view.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart' hide FileOutput;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class $LogOutput extends LogOutput {
  final ConsoleOutput consoleOutput = ConsoleOutput();
  FileOutput? fileOutput;

  @override
  Future<void> init() async {
    await consoleOutput.init();
    if (kAnyDebug && !PlatformUtils.isWeb) {
      var logPath = path.join((await getApplicationDocumentsDirectory()).path, kDebugMode ? "log/debug" : "log",
          "${DateTime.now().formate(DateFormat('yyyy_MM_dd_hh_mm'))}.txt");
      DebugUtils.log("open file out put: ${logPath}");
      var file = File(logPath);
      await file.touch();
      fileOutput = FileOutput(file: file);
      await fileOutput?.init();
    }
  } // /Users/apple/.pub-cache/hosted/pub.flutter-io.cn/logger-2.3.0/lib/src/outputs/file_output_stub.dart:7
  ///Users/apple/.pub-cache/hosted/pub.flutter-io.cn/logger-2.3.0/lib/src/outputs/file_output.dart:28

  @override
  void output(OutputEvent event) {
    LoggerHistoryController.instance.onLog(event);
    consoleOutput.output(event);
    fileOutput?.output(event);
    var origin = event.origin;
    if (event.level.value >= Level.error.value) {
      if (kAnyDebug) {
        ErrorUtils.toast(origin.error ?? origin.message, stacktrace: origin.stackTrace);
      }
    }
    if (event.level.value >= Level.error.value) {
      ErrorUtils.report(origin.error ?? origin.message, origin.stackTrace);
    }
  }

  @override
  Future<void> destroy() async {
    await consoleOutput.destroy();
    await fileOutput?.destroy();
  }
}

class FileOutput extends LogOutput {
  final File file;
  final bool overrideExisting;
  final Encoding encoding;
  IOSink? _sink;

  FileOutput({
    required this.file,
    this.overrideExisting = false,
    this.encoding = utf8,
  });

  @override
  Future<void> init() async {
    _sink = file.openWrite(
      mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
      encoding: encoding,
    );
  }

  @override
  void output(OutputEvent event) {
    _sink?.writeAll(event.lines, '\n');
    _sink?.writeln();
  }

  @override
  Future<void> destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
