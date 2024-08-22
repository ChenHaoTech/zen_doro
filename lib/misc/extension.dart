import 'dart:async';
import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:daily_extensions/daily_extensions.dart' hide DateTimeX;
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material show Image, ImageConfiguration, ImageStreamListener;
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:local_hero/local_hero.dart';
import 'package:pinyin/pinyin.dart';
import 'package:ui_extension/ui_extension.dart';
import 'package:universal_io/io.dart';

export 'package:flutter_pasteboard/theme/text_theme.dart';
export 'package:flutter_pasteboard/theme/theme.dart';
export 'package:flutter_pasteboard/theme/padding_constants.dart';

extension LocalHeroExt on Widget {
  Widget localHero(String tag, [LocalHeroFlightShuttleBuilder? flightShuttleBuilder]) {
    return LocalHero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder,
      child: this,
    );
  }

  Widget guideToolTip(
    LogicalKeySet? set, {
    String guideKey = "",
    String? guide,
  }) {
    if (set == null || PlatformUtils.isMobile) return this;
    return Tooltip(
      child: this,
      message: set.toReadable(),
    );
    return Tooltip(
      height: 32,
      showDuration: Duration(
        seconds: 10,
      ),
      richMessage: TextSpan(
        text: set.toReadable(),
        children: <InlineSpan>[
          TextSpan(text: "\n"),
          WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: (() {
                  // key.currentState?.ensureTooltipVisible();
                }),
                child: TextButton(
                  child: Text(
                    'Get',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: (() {}),
                ),
              )),
          const TextSpan(
            text: '.',
          ),
        ],
      ),
      triggerMode: TooltipTriggerMode.tap,
      child: this,
    );
  }
}

extension DateTimeExt on DateTime {
  String relativeFormate() {
    return DateTimeFormat.relative(this, appendIfAfter: "ago".i18n, abbr: true);
  }

// DateTime clamp(DateTime min,DateTime max)
  DateTime clamp(DateTime? min, DateTime? max) {
    if (min != null && this.isBefore(min)) {
      return min;
    } else if (max != null && this.isAfter(max)) {
      return max;
    } else {
      return this;
    }
  }

  DateTime onlyYmd() {
    return DateTime(year, month, day);
  }

  DateTime copyWithTd(TimeOfDay timeOfDay) {
    return this.copyWith(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    );
  }

  String formate(DateFormat dateFormat) {
    return dateFormat.format(this);
  }

  String smartFormate([DateTime? pivot]) {
    var sameDay = this.onlyYmd() == (pivot ?? DateTime.now()).onlyYmd();
    var dateFormat = sameDay ? FnDateUtils.hhmm : FnDateUtils.ymmd_hhmm;
    return dateFormat.format(this);
  }

  DateTime onlyYmdHm() {
    return DateTime(year, month, day, hour, minute);
  }

  DateTime onlyYmdh() {
    return DateTime(year, month, day, hour);
  }

  DateTime atToday() {
    return DateTime.now().onlyYmd().add(this.hour.hours).add(this.minute.minutes);
  }

  DateTime atDate(DateTime date) {
    return date.onlyYmd().add(this.hour.hours).add(this.minute.minutes);
  }
}

class SimpleCallbackAction<T extends Intent> extends Action<T> {
  final void Function() consumer;

  SimpleCallbackAction(this.consumer);

  @override
  Object? invoke(T intent) {
    consumer.call();
    return true;
  }
}

extension CompleterExt<T> on Completer<T> {
  bool tryComplete([FutureOr<T>? value]) {
    if (!this.isCompleted) {
      this.complete(value);
      return true;
    }
    return false;
  }
}

extension StringEx on String {
  bool containIgnoreCase(String target) {
    return this.toLowerCase().contains(target.toLowerCase());
  }

  List<T> asListForJson<T>([T Function(dynamic raw)? mapper]) {
    try {
      return (json.decode(this) as List<dynamic>).mapToList(
        (i) => mapper?.call(i) ?? i,
      );
    } catch (e) {
      logger.e("json.decode fail:,str:${this}, type ${T}", e);
      return [];
    }
  }

  T? asObjForJson<T>() {
    try {
      return json.decode(this) as T;
    } catch (e) {
      logger.e("json.decode fail:,str:${this}, type ${T}", e);
      return null;
    }
  }

  bool fzfMath(String target) {
    return this.containIgnoreCase(target) ||
        () {
          var thisPinyin = PinyinHelper.getPinyinE(this);
          var targetPinyin = PinyinHelper.getPinyinE(target);
          return thisPinyin.containIgnoreCase(targetPinyin);
        }();
  }
}

extension MenuExt on Widget {
  Widget onContextTap(void Function() onMenuTap) {
    TapDownDetails? detail;
    return GestureDetector(
      onLongPressStart: !PlatformUtils.isMobile ? null : (_) => onMenuTap.call(),
      onSecondaryTapDown: (_) {
        onMenuTap.call();
      },
      child: this,
    );
    // return this.easyTap(
    //   // hoverColor: Colors.transparent,
    //   // onTapDown: (_) => detail = _,
    //     onSecondaryTap: (_) =>,
    //     onLongPress: PlatformUtils.isMobile
    //         ? () {
    //       onMenuTap.call(null);
    //     }
    //         : null);
  }
}

extension WindowWidgetExt on Widget {
  Widget blurOnUnFocus() {
    if (!PlatformUtils.isDesktop) return this;
    return Obx(() {
      var focus = $windowService.windowFocus.value;
      if (!focus) {
        return this.opacity(.99);
      }
      return this;
    });
  }

  Widget onlyWindowFocus() {
    if (!PlatformUtils.isDesktop) return this;
    return Obx(() {
      var focus = $windowService.windowFocus.value;
      if (!focus) {
        return emptyWidget;
      }
      return this;
    });
  }
}

extension PortalExt on Widget {
  Widget portal({
    List<PortalLabel<dynamic>>? labels,
  }) {
    if (labels != null) {
      return Portal(
        labels: labels,
        child: this,
      );
    }
    return Portal(
      child: this,
    );
  }

  Widget portalOverlay(
    Widget overlay, {
    Anchor? anchor,
  }) {
    return PortalTarget(
      anchor: anchor ?? const Filled(),
      portalFollower: overlay,
      child: this,
    );
  }
}

extension Find<K, V, R> on Map<K, V> {
  R? find<T>(
    K key,
    R? Function(T value) cast,
  ) {
    final value = this[key];
    if (value != null && value is T) {
      return cast(value as T);
    } else {
      return null;
    }
  }
}

extension GetImageAspectRatio on material.Image {
  Future<double> getAspectRatio() {
    final completer = Completer<double>();
    image.resolve(const material.ImageConfiguration()).addListener(
      material.ImageStreamListener(
        (imageInfo, synchronousCall) {
          final aspectRatio = imageInfo.image.width / imageInfo.image.height;
          imageInfo.image.dispose();
          completer.complete(aspectRatio);
        },
      ),
    );
    return completer.future;
  }
}

extension GetImageDataAspectRatio on Uint8List {
  Future<double> getAspectRatio() {
    final image = material.Image.memory(this);
    return image.getAspectRatio();
  }
}

typedef FilePath = String;

extension GetImageFileAspectRatio on FilePath {
  Future<double> getAspectRatio() {
    final file = File(this);
    final image = material.Image.file(file);
    return image.getAspectRatio();
  }
}

extension Log<T> on T {
  T dl([String? prefix]) {
    if (!kDebugMode) return this;
    devtools.log("\x1b[101m\x1b[30m${prefix} ${this?.toString()}\x1b[0m");
    return this;
  }
}

extension FocusListExt on Iterable<FocusNode> {
  bool anyFocus({
    bool primary = true,
  }) {
    return this.toList().findIdx((p0) => primary ? p0.hasPrimaryFocus : p0.hasFocus) != null;
  }

  void pre({
    bool primary = true,
  }) {
    this.toList().reversed.next(primary: primary);
  }

  void ensureFocus({
    bool primary = true,
  }) {
    var list = this.toList();
    var idx = list.findIdx((p0) => primary ? p0.hasPrimaryFocus : p0.hasFocus) ?? -1;
    if (idx != -1) return;
    for (int i = idx + 1; i <= this.length + idx; i++) {
      var node = list.getNullable((i) % this.length);
      if (node != null && node.canRequestFocus && !node.skipTraversal) {
        node.requestFocus();
        return;
      }
    }
  }

  void next({
    bool primary = true,
  }) {
    var list = this.toList();
    var idx = list.findIdx((p0) => primary ? p0.hasPrimaryFocus : p0.hasFocus) ?? -1;
    for (int i = idx + 1; i <= this.length + idx; i++) {
      var node = list.getNullable((i) % this.length);
      if (node != null && node.canRequestFocus && !node.skipTraversal && node.parent != null) {
        // DebugUtils.log("extension:364: ${node} ${node.parent}\n${StackTrace.current}");
        node.requestFocus();
        return;
      }
    }
  }
}

extension ListExt<T> on List<T> {
  // findIdx(predict)
  int? findIdx(bool Function(T) predict) {
    for (int i = 0; i < this.length; i++) {
      if (predict(this[i])) {
        return i;
      }
    }
    return null; // 如果没有找到，返回-1   }
  }

  List<R> mapIdx<R>(R Function(int idx, T item) transform) {
    return List<R>.generate(this.length, (idx) => transform(idx, this[idx]));
  }

  List<T> sortByInt<T>(List<T> list, int Function(T) mapper) {
    list.sort((a, b) => mapper(a).compareTo(mapper(b)));
    return list;
  }

  /**
   * 从大到小
   */
  T? maxByMapper(int Function(T) scoreMapper) {
    if (this.isEmptyOrNull) return null;
    var scores = this.mapToList(scoreMapper);

    int maxIndex = 0;
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > scores[maxIndex]) {
        maxIndex = i;
      }
    }
    return this[maxIndex];
  }

  // upsert(bool Function(T) predict, T targe)
  void upsert(bool Function(T) predict, T target) {
    final index = this.indexWhere(predict);
    if (index != -1) {
      this[index] = target;
    } else {
      this.add(target);
    }
  }
}

extension ExtWidgetExt on String {
  Widget widget({
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    ui.TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor, // Deprecated
    TextScaler? textScaler,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Color? selectionColor,
  }) {
    return Text(
      this,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      // Deprecated
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

extension AudioPlayerExt on AudioPlayer {
  String? get urlOrPath {
    if (this.source is DeviceFileSource?) {
      return (this.source as DeviceFileSource?)?.path;
    }
    if (this.source is AssetSource?) {
      return (this.source as AssetSource?)?.path;
    }
    return null;
  }

  Future touchPlay(
    String path, {
    double volume = .5,
  }) async {
    if (path.startsWith("/")) {
      var _source = this.source as DeviceFileSource?;
      if (this.state == PlayerState.playing && _source != null && _source.path == path) {
        return;
      }
      if (this.state == PlayerState.playing || this.state == PlayerState.paused) {
        await this.stop();
      }
      await this.setReleaseMode(ReleaseMode.loop);
      await this.play(DeviceFileSource(path), volume: volume);
    } else {
      var _source = this.source as AssetSource?;
      if (this.state == PlayerState.playing && _source != null && _source.path == path) {
        return;
      }
      if (isStart) {
        await this.stop();
      }
      await this.setReleaseMode(ReleaseMode.loop);
      await this.play(AssetSource(path), volume: volume);
    }
  }

  bool get isMute {
    return this.volume == 0;
  }

  bool get isStart {
    return this.state == PlayerState.playing || this.state == PlayerState.paused || this.state == PlayerState.completed;
  }

  Future toggleMute({
    required double unMuteVolume,
    Function(double volume)? onUnMuteVolume,
  }) async {
    var _volume = this.volume;
    if ((_volume - 0).abs() <= 0.01) {
      // 已经静音, 则使用unMuteVolume
      await this.setVolume(unMuteVolume);
    } else {
      // 未静音, 设置为0
      await this.setVolume(0);
      onUnMuteVolume?.call(_volume);
    }
  }
}

extension StackTraceExt on StackTrace {
  List<String> get list {
    return this.toString().split("\n");
  }

  String? get invoker {
    return list.whereToList((p0) => !p0.contains("logger_extension")).getNullable(1);
  }
}

extension TextEditingControllerExt on TextEditingController {
  TextSelection getSelection(TextSelection selection) {
    return !selection.isValid
        ? selection.copyWith(
            baseOffset: text.length,
            extentOffset: text.length,
          )
        : selection;
  }

  bool get hasSelection => (selection.baseOffset - selection.extentOffset) != 0;

  void removeLast(int range) {
    removeRange(text.length - 1 - range, text.length - 1);
  }

  bool get isAtStart {
    return this.selection.baseOffset <= 0;
  }

  void removeLastUntil(bool Function(String) predict) {
    int cursorPosition = this.selection.extentOffset;
    if (cursorPosition < 0) return;
    cursorPosition = min(cursorPosition, this.text.length - 1);
    for (int i = cursorPosition; i >= 0; i--) {
      var str = text.substring(i, cursorPosition + 1);
      if (predict(str)) {
        removeRange(i, cursorPosition);
        break;
      }
    }
  }

  void removeRange(int start, int end) {
    TextSelection selection = this.selection;
    String oldText = text;
    String newText = oldText.substring(0, start) + oldText.substring(end + 1, text.length);
    int textDelta = newText.length - oldText.length;

    this.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.baseOffset + textDelta),
    );
  }

  void selectAll() {
    this.selection = TextSelection(baseOffset: 0, extentOffset: this.text.length);
  }

  void insertTextAtCursor(String text) {
    TextSelection selection = this.selection;
    String newText = this.text.replaceRange(selection.start.takeIf((it) => it > 0) ?? this.text.length, selection.end, text);
    this.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.baseOffset + text.length),
    );
  }
}

extension ThemeWidgetExt on Widget {
  Widget mask(Gradient gradient) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      blendMode: BlendMode.color,
      child: this,
    );
  }

  Widget gradient({
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: Colors.red,
      ),
      child: this,
    );
  }
}

extension FileExt on File {
  void touchSync() {
    if (!this.existsSync()) {
      this.createSync();
    }
  }

  Future touch() async {
    if (!(await this.exists())) {
      await this.create(recursive: true);
    }
  }
}

extension KeyBoardToolExt on Widget {
  Widget keyboardToolbar({
    List<KeyboardActionsItem>? actions,
    bool disableScroll = false,
    bool enable = true,
  }) {
    if (!enable) return this;
    return Builder(builder: (context) {
      return KeyboardActions(
        disableScroll: disableScroll,
        config: KeyboardActionsConfig(
          keyboardBarColor: context.background,
          actions: actions ?? [],
        ),
        child: this,
      );
    });
  }
}

extension NumExt on int {
  int clamp(int min, int max) {
    return clampInt(this, min, max);
  }

  int ensurePos() {
    return this < 0 ? 0 : this;
  }

  int ensureMin(int min) {
    return this < min ? min : this;
  }
}

extension DeviceScreenshotExt on DeviceScreenshot {
  Future saveAsFile() async {
    // Get the directory to store the file
    final Directory dir = applicationDocumentsDirectory;

    // Create the file
    fnassert(() => this.format == ImageByteFormat.png, this.format);
    final File file = File('${dir.path}/screenshot/${this.device.name}.png');
    await file.create(recursive: true);

    // Write the byte data to the file
    await file.writeAsBytes(this.bytes);
    this.log.dd(() => "saveAsFile, file:${file.path},${this.device}");
    return file;
  }
}
