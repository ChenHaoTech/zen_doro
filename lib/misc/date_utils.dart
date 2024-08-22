import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

abstract class FnDateUtils {
  static int hour_seconds = 60 * 60;
  static int day_minutes = 60 * 24;
  static DateTime zeroTime = DateTime.fromMillisecondsSinceEpoch(0);
  static late final Rx<DateTime> now = DateTime.now().obs
    ..apply((it) {
      Timer.periodic(1.seconds, (timer) {
        it.value = DateTime.now();
      });
    });

  static Rx<DateTime> get nowYmdHm {
    var value = _nowYmdHm.justValue;
    var now = DateTime.now().onlyYmdHm();
    if (value != now) {
      _nowYmdHm.value = now;
    }
    return _nowYmdHm;
  }

  static late final Rx<DateTime> _nowYmdHm = DateTime.now().onlyYmdHm().obs
    ..apply((it) {
      Timer.periodic(1.minutes, (timer) {
        it.value = DateTime.now().onlyYmdHm();
      });
    });
  static late final Rx<DateTime> nowYmd = DateTime.now().onlyYmd().obs
    ..apply((it) {
      Timer.periodic(1.minutes, (timer) {
        it.value = DateTime.now().onlyYmd();
      });
    });
  static DateFormat ymmd_hhmm = DateFormat('yyyy-MM-dd HH:mm');
  static DateFormat mmd_hhmm = DateFormat('MM-dd HH:mm');
  static DateFormat hhmm = DateFormat('HH:mm');
  static DateFormat ymmd_notime = DateFormat('yyyy-MM-dd');
  static DateFormat mmd_notime = DateFormat('MM-dd');

  static String format(DateTime? dt, {bool needMint = false}) {
    if (dt == null) return "";
    if (needMint) return ymmd_hhmm.format(dt).toString();
    return ymmd_notime.format(dt).toString();
  }

  static String humanReadable(DateTime? dt, {bool onlyDay = false}) {
    if (dt == null) return "";
    if (dt.onlyYmd() == dt) onlyDay = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final aWeekAgo = DateTime(now.year, now.month, now.day - 6);

    final dtDay = DateTime(dt.year, dt.month, dt.day);
    final timeFormat = DateFormat('HH:mm');
    final time = timeFormat.format(dt);

    if (dtDay == today) {
      if (onlyDay) return 'Today'.i18n;
      return time;
    } else if (dtDay == yesterday) {
      if (onlyDay) return 'Yesterday'.i18n;
      return 'Yesterday %s'.i18n.fill([time]);
    } else if (dtDay.isAfter(aWeekAgo)) {
      final weekDay = DateFormat('EEEE').format(dt);
      if (onlyDay) return weekDay;
      return '$weekDay $time';
    } else {
      var sameYear = DateTime.now().year == dt.year;
      if (sameYear) {
        if (onlyDay) return mmd_notime.format(dtDay).toString();
        return mmd_hhmm.format(dt).toString();
      }
      if (onlyDay) return ymmd_notime.format(dtDay).toString();
      return ymmd_hhmm.format(dt).toString();
    }
  }

  static DateTime min(DateTime a, DateTime b) {
    return a.isBefore(b) ? a : b;
  }

  static DateTime max(DateTime a, DateTime? b) {
    if (b == null) return a;
    return a.isBefore(b) ? b : a;
  }

  static DateTime? findMin(List<DateTime?> dates) {
    if (dates.isEmpty) return null;
    DateTime? minDate = dates.first;
    for (DateTime? date in dates) {
      if (date == null) continue;
      if (minDate == null || date.isBefore(minDate)) {
        minDate = date;
      }
    }
    return minDate;
  }

  static DateTime? findMax(List<DateTime?> dates) {
    var _dates = dates.whereNotNull().toList();
    if (_dates.isEmpty) return null;
    DateTime maxDate = _dates.first;
    for (DateTime date in _dates) {
      if (date.isAfter(maxDate)) {
        maxDate = date;
      }
    }
    return maxDate;
  }

  static bool isClamp(DateTime? start, DateTime? end, DateTime target) {
    if (start == null || target.isBefore(start)) {
      return false;
    }
    if (end == null || target.isAfter(end)) {
      return false;
    }
    return true;
  }

  static String formatDuration_hh_mm(
    Duration duration, {
    bool needSecond = true,
  }) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = seconds.toString().padLeft(2, '0');

    if (hours == 0) {
      return '$formattedMinutes:$formattedSeconds';
    } else {
      if (needSecond) {
        return '$formattedHours:$formattedMinutes:$formattedSeconds';
      } else {
        return '$formattedHours:$formattedMinutes';
      }
    }
  }
}
