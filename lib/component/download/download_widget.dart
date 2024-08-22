import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/misc/download_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:ui_extension/ui_extension.dart';
import 'package:universal_io/io.dart';

class $DemoDownloadWidget extends StatelessWidget {
  const $DemoDownloadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DownloadWidget(
        url: "https://gitee.com/chen-hao91/publix_resource/raw/main/README.md",
        fileName: "README_2.md",
        onInit: (func) {
          return "empty".widget().center().inkWell(onTap: () {
            func.call();
          });
        },
        onComplete: (path) {
          // 展示本地文件(文本)path
          return FutureBuilder<String>(
            future: File(path).readAsString(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return SingleChildScrollView(
                  child: Text(snapshot.data ?? ''),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
        onProgress: (double progess) {
          return CircularProgressIndicator(
            value: progess,
          );
        }).asScaffoldBody();
  }
}

class DownloadWidget extends StatefulWidget {
  final String url;
  final String fileName;
  final String? directory;
  final Widget Function(Function() startDownLoad) onInit;
  final Widget Function(double progress) onProgress;
  final Widget Function(String path) onComplete;
  final Widget Function()? onFail;
  final bool audoDownload;

  const DownloadWidget({
    super.key,
    required this.url,
    required this.fileName,
    required this.onInit,
    required this.onComplete,
    required this.onProgress,
    this.directory,
    this.onFail,
    this.audoDownload = false,
  });

  @override
  _DownloadWidgetState createState() => _DownloadWidgetState();
}

class _DownloadWidgetState extends State<DownloadWidget> {
  late double _progress = -1;
  String? _path;

  /*默认下载中*/
  late bool _completed = false;
  late TaskStatus _taskStatus = TaskStatus.running;

  @override
  void initState() {
    super.initState();
    var downloaded = DownloadUtils.checkFile(fileName: widget.fileName, directory: widget.directory ?? '');
    var path = DownloadUtils.getPath(fileName: widget.fileName, directory: widget.directory ?? '');
    if (downloaded) {
      this.log.dd(() => "${path}已经下载好了");
      setState(() {
        _completed = true;
        this._path = path;
      });
    } else {
      this.log.dd(() => "${path}还未下载");
      if (widget.audoDownload) _startDownload();
    }
  }

  void _startDownload() {
    DownloadUtils.startDownload(
        url: widget.url,
        fileName: widget.fileName,
        directory: widget.directory ?? '',
        onProgress: (progress) {
          // this.log.dd(() => "progress: ${progress}");
          if (!mounted) return;
          setState(() {
            _progress = progress;
          });
        },
        onStatusChange: (statue) {
          if (!mounted) return;
          setState(() {
            _taskStatus = statue;
          });
        },
        onComplete: (path) {
          if (!mounted) return;
          setState(() {
            _completed = true;
            this._path = path;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return widget.onComplete.call(_path!);
    } else {
      if (_taskStatus != TaskStatus.complete) {
        if (_progress != -1) {
          return widget.onProgress.call(_progress);
        } else {
          return widget.onInit.call(() => _startDownload());
        }
      } else {
        return widget.onFail?.call() ?? Text("fail", style: context.errorText);
      }
    }
  }
}
