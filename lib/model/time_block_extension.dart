part of 'time_block.dart';

extension RestExt on RestBlock {
  int get leftSeconds {
    fnassert(() => this.durationSeconds >= 0, this);
    return this.durationSeconds - this.progressSeconds;
  }
}

extension TagExt on Tag {
  Color? get color => this.colorValue?.fnmap((val) => Color(val));
}

extension PromodoExt on FocusBlock {
  int get leftSeconds {
    return this.durationSeconds - this.progressSeconds;
  }

  int get pauseSeconds {
    var logs = this.logs.mapToList((i) => ActionLog.fromJson(i.tryToJson()!), growable: true);
    DateTime? lastResumeTime;
    int res = 0;
    while (!logs.isEmpty) {
      // 倒序退栈
      var last = logs.removeLast();
      if (last.type == ActionLogType.PAUSE.code) {
        if (lastResumeTime == null) {
          continue;
        }
        // diff = pause 到 resume
        var diff = lastResumeTime.difference(last.time).inSeconds;
        fnassert(() => diff >= 0, last);
        res += diff;
      } else if (last.type == ActionLogType.RESUME.code) {
        lastResumeTime = last.time;
      } else {
        fnassert(() => last.type == ActionLogType.STOP.code, last);
        // pass
      }
    }
    return res;
  }

  String? get titleWithoutTag {
    return title?.replaceAll(TagUtils.tagRegExp, "").takeIf((it) => !it.isEmptyOrNull);
  }
}

extension TimeBlockFormateExt on TimeBlock {
  String debugString([bool deep = false]) {
    if (!deep) {
      var time = "${startTime?.formate(FnDateUtils.mmd_hhmm)}=>${endTime?.formate(FnDateUtils.mmd_hhmm)}";
      if (this.isRest) {
        var rest = this.rest;
        return "[rest]" + "($time) => (du:${prettyDuration(rest.durationSeconds.seconds)} pro:(${prettyDuration(rest.progressSeconds.seconds)}))";
      }
      var promodo = this.pomodoro;
      return "[focus]($time)(${promodo.title}|${promodo.context})|${promodo.feedback}|"
          "\ndu:${prettyDuration(promodo.durationSeconds.seconds)}(pro:${prettyDuration(promodo.progressSeconds.seconds)})";
    }
    return this.toString();
  }

  String toSimpleStr() {
    var i = this;
    return "${i.type}_${i.startTime}_${i.endTime}_${() {
      if (i.isRest) return "";
      var promodo = i.pomodoro;
      return "${promodo.title}_${promodo.context}_${promodo.feedback}_${promodo.tags}_${promodo.logs}";
    }()}";
  }

  String toMd({
    bool? showMonthDay,
    bool debug = false,
  }) {
    String removeLastNewLine(String str) {
      return str.endsWith('\n') ? str.substring(0, str.length - 1) : str;
    }

    if (startTime == null) {
      return "";
    }
    late DateFormat format;
    if (showMonthDay == true) {
      format = FnDateUtils.mmd_hhmm;
    } else {
      format = FnDateUtils.hhmm;
    }
    var timeLine = "**${format.format(startTime!)}${endTime?.fnmap((val) => " - " + format.format(val)) ?? ""}** ${() {
      if (endTime != null && startTime != null) {
        var duration = endTime!.difference(startTime!);
        return "(${duration.inMinutes}min)";
      } else {
        return "";
      }
    }()}";
    if (debug) {
      timeLine += "\n" + this.toJsonStr();
    }
    if (type == TimeBlockType.REST.code) {
      var rest = this.rest;
      return """${timeLine}
(${"休息".i18n})${rest.progressSeconds} s""";
    } else {
      fnassert(() => type == TimeBlockType.FOCUS.code);
      var promodo = this.pomodoro;
      return """${timeLine}
${promodo.title ?? ""}${removeLastNewLine(promodo.context?.fnmap((val) => val + "\n") ?? "")}
""";
    }
  }
}

extension TimeBlockExt on TimeBlock {
  DateTime? get progressEndTime {
    return this.startTime?.add((progressSeconds + this.pauseSeconds).seconds);
  }

  DateTime? get planEndTime {
    return this.startTime?.add(this.durationSeconds.seconds);
  }

  List<Tag> get tags {
    if (this.isRest) return [];
    var tags = this.pomodoro.tags;
    return tags.mapToList((e) => TagStore.find.id2tag[e]).whereNotNull().toList();
  }

  Color? get color {
    if (this.isRest) return Get.context?.restColor;
    var tagId = this.tryPromodo?.tags.firstOrNull;
    if (tagId == null) return Get.context?.pomodoroContainerColor;
    return TagStore.find.id2tag[tagId]?.color ?? Get.context?.pomodoroContainerColor;
  }

  int get durationSeconds {
    return this.isFocus ? this.pomodoro.durationSeconds : this.rest.durationSeconds;
  }

  int get leftSeconds {
    return this.isFocus ? this.pomodoro.leftSeconds : this.rest.leftSeconds;
  }

  bool get isFocus {
    return type == TimeBlockType.FOCUS.code;
  }

  bool get isRest {
    return type == TimeBlockType.REST.code;
  }

  String get uniqueKey => "${this.uuid},${this.tryPromodo?.title}";

  FocusBlock? get tryPromodo {
    if (isRest) return null;
    return pomodoro;
  }

  int? get maxProgressSeconds {
    var pauseSeconds = this.pauseSeconds;
    if (this.startTime == null) return null;
    return endTime?.difference(startTime!).inSeconds.fnmap((val) => val - pauseSeconds);
  }

  FocusBlock get pomodoro {
    fnassert(() => isFocus, ["不是promodo", type, uuid, this]);
    try {
      return FocusBlock.fromJson(_adapterBodyJson(json.decode(body)).cast());
    } catch (e) {
      logger.e("反序列化 body as Promodo fail, body:${body}, this: ${this}", e);
      return FocusBlock(durationSeconds: 25 * 60, progressSeconds: 25 * 60);
    }
  }

  RestBlock get rest {
    try {
      fnassert(() => isRest, [uuid, this]);
      var rest = RestBlock.fromJson(_adapterBodyJson(json.decode(body)).cast());
      if (rest.type == RestType.COUNT_DOWN.code) {
        fnassert(() => rest.durationSeconds >= 0, this);
      } else {
        fnassert(() => rest.durationSeconds < 0, this);
      }
      return rest;
    } catch (e) {
      logger.e("反序列化rest 失败:${body}, timeBlock: ${this}", e);
      if (kDebugMode) TimeBlockStore.find.delete(uuid);
      return RestBlock(
        type: RestType.COUNT_DOWN.code,
        progressSeconds: 0,
        durationSeconds: 5 * 60,
      );
    }
  }

  TimeBlock switchRestType(RestType restType) {
    fnassert(() => this.isRest);
    var rest = this.rest;
    if (rest.type == restType.code) {
      return this;
    }
    if (restType == RestType.COUNT_DOWN) {
      fnassert(() => rest.type == RestType.POSITIVE_TIMING.code);
      return this.updateRest(
          mapper: (rest) => rest.copyWith(
                type: restType.code,
                durationSeconds: max(5 * 60, rest.progressSeconds + 1 * 60),
                progressSeconds: 0,
              ));
    } else {
      fnassert(() => rest.type == RestType.COUNT_DOWN.code);
      return this.updateRest(
          mapper: (rest) => rest.copyWith(
                type: restType.code,
                durationSeconds: -1,
                progressSeconds: rest.progressSeconds,
              ));
    }
  }

  TimeBlock? whenFocus() {
    return this.isFocus ? this : null;
  }

  TimeBlock? whenRest() {
    return this.isRest ? this : null;
  }

  TimeBlock updateFocus({
    String? title,
    String? context,
    String? feedback,
    int? durationSeconds,
    int? progressSeconds,
    Tag? tag,
    bool isDeleteTag = false,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    if (isDeleteTag) {
      fnassert(() => tag == null);
    }
    return updatePromodo(
      startTime: startTime,
      endTime: endTime,
      mapper: (p) {
        var tags = tag != null ? [tag.id] : p.tags;
        return p.copyWith(
          title: title ?? p.title,
          context: context ?? p.context,
          feedback: feedback ?? p.feedback,
          durationSeconds: durationSeconds ?? p.durationSeconds,
          progressSeconds: progressSeconds ?? p.progressSeconds,
          tags: isDeleteTag ? [] : tags,
        );
      },
    );
  }

  TimeBlock updateTime({
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? progressSeconds,
  }) {
    if (startTime != null) {
      startTime = FnDateUtils.findMin([startTime, endTime ?? this.endTime]);
    }
    TimeBlock result;
    if (this.isRest) {
      result = this.updateRest(
        mapper: (r) => r.copyWith(
          durationSeconds: durationSeconds ?? r.durationSeconds,
          progressSeconds: progressSeconds ?? r.progressSeconds,
        ),
        startTime: startTime,
        endTime: endTime,
      );
    } else {
      result = this.updatePromodo(
        mapper: (p) => p.copyWith(
          durationSeconds: durationSeconds ?? p.durationSeconds,
          progressSeconds: progressSeconds ?? p.progressSeconds,
        ),
        startTime: startTime,
        endTime: endTime,
      );
    }
    if (endTime != null || startTime != null) {
      return result.correctProgressTime();
    }
    return result;
  }

  int get pauseSeconds {
    if (this.isRest) {
      return 0;
    } else {
      return pomodoro.pauseSeconds;
    }
  }

  bool get isDoing {
    return this.startTime != null && this.isNotEnd;
  }

  bool get isNotEnd {
    return this.endTime == null || this.endTime!.isAfter(DateTime.now());
  }

  bool get isEnd {
    return this.endTime != null && (this.endTime!.isBefore(DateTime.now()) || this.endTime == DateTime.now());
  }

  bool get isPause {
    if (this.isRest) {
      return false;
    } else {
      var logStr = pomodoro.logs.lastOrNull;
      if (logStr != null) {
        var log = ActionLog.fromJson(logStr.toSafeJson());
        if (ActionLogType.PAUSE.match(log.type)) {
          return true;
        }
      }
      return false;
    }
  }

  TimeBlock updateDurationByStartTimeDiffWhenEndIsNull(DateTime startTime) {
    if (this.endTime != null) return this;
    if (this.startTime == null) return this;
    var inSeconds2 = startTime.difference(this.startTime!).inSeconds;
    DebugUtils.log("time_block_extension:332; ${inSeconds2} \n${StackTrace.current}");
    if (this.isRest) {
      return this.updateRest(
        mapper: (r) => r.copyWith(
          durationSeconds: (r.durationSeconds - inSeconds2).ensurePos(),
        ),
      );
    } else {
      return this.updatePromodo(
        mapper: (p) => p.copyWith(
          durationSeconds: (p.durationSeconds - inSeconds2).ensurePos(),
        ),
      );
    }
  }

  TimeBlock correctEndTime({
    bool considerPlan = true,
  }) {
    if (endTime == null || startTime == null) return this;
    if (durationSeconds < 0 && this.isRest) return this;
    return this.copyWith(
      startTime: this.startTime,
      endTime: FnDateUtils.findMax([
        this.startTime,
        if (considerPlan) this.planEndTime,
        this.progressEndTime,
      ]),
    );
  }

  TimeBlock correctDuration() {
    if (this.startTime == null || this.endTime == null) return this;
    int durationSeconds = this.endTime!.difference(this.startTime!).inSeconds;
    fnassert(() => durationSeconds >= 0);
    if (this.isRest) {
      return this.updateRest(
        mapper: (r) => r.copyWith(
          durationSeconds: durationSeconds,
        ),
      );
    } else {
      return this.updatePromodo(
        mapper: (p) => p.copyWith(
          durationSeconds: durationSeconds,
        ),
      );
    }
  }

  TimeBlock correctProgressTime([DateTime? datetime]) {
    if (startTime == null) return this;
    int progressSeconds = (datetime ?? FnDateUtils.findMin([endTime, DateTime.now()]))!.difference(startTime!).inSeconds - this.pauseSeconds;
    if (this.isRest) {
      return this.updateRest(
        mapper: (r) => r.copyWith(
          progressSeconds: progressSeconds.ensurePos(),
        ),
      );
    } else {
      return this.updatePromodo(
        mapper: (p) => p.copyWith(
          progressSeconds: progressSeconds.ensurePos(),
        ),
      );
    }
  }

  int get progressSeconds {
    if (this.isRest) {
      return rest.progressSeconds;
    } else {
      return pomodoro.progressSeconds;
    }
  }
}

extension RuleTimeBlockExt on TimeBlock {
  /*assert*/
  TimeBlock assertTimeBlockRule() {
    var startTime2 = this.startTime;
    var endTime2 = this.endTime;
    if (startTime2 == null || endTime2 == null) return this;
    var inSeconds2 = FnDateUtils.findMin([endTime2, DateTime.now()])!.difference(startTime2).inSeconds;
    //todo assert end, 在当前的
    if ((inSeconds2 - (this.progressSeconds + this.pauseSeconds)).abs() >= 60) {
      this.log.e(["progressSeconds 存储错误", "${inSeconds2} <->${this.progressSeconds} + ${this.pauseSeconds}", startTime2, endTime2, this].join(","));
    }
    return this;
  }
}

extension CommonTimeBlockExt on TimeBlock {
  TimeBlock updateRest({
    RestBlock Function(RestBlock rest)? mapper,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    if (!this.isRest) {
      logger.e("当前不是Rest 修改失败:${this}");
      return this;
    }
    var newBody = mapper?.call(RestBlock.fromJson(json.decode(body))).toJsonStr();
    var timeBlock = copyWith(
      body: newBody ?? body,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
    return timeBlock;
  }

  TimeBlock updatePromodo({
    FocusBlock Function(FocusBlock pro)? mapper,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    if (!this.isFocus) {
      logger.e("当前不是Promodo 修改失败:${this}");
      return this;
    }
    var _promodo = pomodoro;
    _promodo = mapper?.call(_promodo) ?? _promodo;

    var timeBlock = copyWith(
      body: _promodo.toJsonStr(),
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
    return timeBlock;
  }
}
