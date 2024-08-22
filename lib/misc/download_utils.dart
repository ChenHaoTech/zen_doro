import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

abstract class DownloadConst {
  static const Audio = "audio";
}

abstract class DownloadUtils {
  static final log = LoggerWrapper.build("DownloadUtils");

  static bool checkFile({
    required String fileName,
    String directory = "",
  }) {
    // todo 兼容 web
    if (PlatformUtils.isWeb) return false;
    var file = File(getPath(fileName: fileName, directory: directory));
    var exits = file.existsSync();
    return exits;
  }

  static String getPath({
    required String fileName,
    String directory = "",
  }) {
    return path.join(applicationDocumentsDirectory.path, directory, fileName);
  }

  static Future startDownload({
    required String url,
    required String fileName,
    bool requestUpdate = false,
    String directory = "",
    bool requiresWiFi = false,
    Duration? timeout,
    Function(double progress)? onProgress,
    Function(TaskStatus status)? onStatusChange,
    required Function(String path) onComplete,
    Function()? onFail,
  }) async {
    if (checkFile(fileName: fileName, directory: directory)) {
      log.dd(() => "${fileName}已经下载好了, 跳过下载");
      onComplete.call(getPath(fileName: fileName, directory: directory));
      if (requestUpdate) {
        mustDownLoad(
          fileName: fileName,
          url: url,
          directory: directory,
          requiresWiFi: requiresWiFi,
          timeout: timeout,
          onComplete: (path) => log.dd(() => "重新下载结束:${path}, 下一次会更新到"),
        );
      }
      return;
    }
    await mustDownLoad(
      fileName: fileName,
      url: url,
      directory: directory,
      onProgress: onProgress,
      onStatusChange: onStatusChange,
      onComplete: onComplete,
      requiresWiFi: requiresWiFi,
      timeout: timeout,
      onFail: onFail,
    );
  }

  static Future mustDownLoad({
    required String url,
    required String fileName,
    bool requiresWiFi = false,
    Duration? timeout,
    String directory = "",
    Function(double progress)? onProgress,
    Function(TaskStatus status)? onStatusChange,
    Function(String path)? onComplete,
    Function()? onFail,
  }) async {
    //todo web环境支持 下载
    if (PlatformUtils.isWeb) return;
    final tmpFileName = "tmp_${fileName}";
    var task = DownloadTask(
      requiresWiFi: requiresWiFi,
      url: url,
      // urlQueryParameters: {'q': 'pizza'},
      filename: tmpFileName,
      // headers: {'myHeader': 'value'},
      directory: directory,
      updates: Updates.statusAndProgress,
      retries: 5,
      allowPause: false,
    );
    final resultFuture = FileDownloader().download(task, onProgress: onProgress, onStatus: onStatusChange);

    Future<TaskStatus> resultFu;
    if (timeout != null) {
      resultFu = resultFuture.then((value) => value.status).timeout(timeout, onTimeout: () async {
        logger.e("超时了, ${url},time:${timeout}");
        return TaskStatus.failed;
      });
    } else {
      resultFu = resultFuture.then((value) => value.status);
    }
    var result = await resultFu;

    switch (result) {
      case TaskStatus.complete:
        if (DebugFlag.download) log.dd(() => 'Success!');
        var file = File(getPath(fileName: tmpFileName, directory: directory));
        var exists = await file.exists();
        fnassert(() => exists, file.path);
        file = await file.rename(getPath(fileName: fileName, directory: directory));
        log.i("${file.path} 下载结束, url:${url}");
        onComplete?.call(file.path);
        break; // 注意添加break
      case TaskStatus.canceled:
        if (DebugFlag.download) log.dd(() => 'Download was canceled');
        break; // 注意添加break
      case TaskStatus.paused:
        if (DebugFlag.download) log.dd(() => 'Download was paused');
        break; // 注意添加break
      default:
        if (DebugFlag.download) log.dd(() => 'Download not successful: ${result}, url:${url}');
        onFail?.call();
        break; // 注意添加break
    }
  }
}
