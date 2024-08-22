import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/platform/platform.dart';

import 'function.dart';

extension RawKeyEventExt on RawKeyEvent {
  bool get isUpKeyEvent {
    return this is RawKeyUpEvent;
  }

  bool get isDownKeyEvent {
    return this is RawKeyDownEvent;
  }

  bool onlyKey(LogicalKeyboardKey key) {
    return !isModifyPressed && this.isKeyPressed(key);
  }

  // only onlyMetapressedAdaptive
  bool get onlyMetaPressedAdaptive {
    return isMetaPressedAdaptive && !isAltPressed && !isShiftPressed;
  }

  bool get isMetaPressedAdaptive {
    if (GetPlatform.isMacOS) {
      return this.isMetaPressed;
    } else {
      assert(GetPlatform.isWindows);
      return this.isControlPressed;
    }
  }

  bool get isModifyPressed {
    return this.isMetaPressed || this.isAltPressed || this.isControlPressed || this.isShiftPressed;
  }
}

abstract class FnModifyString {
  static String meta = "⌘";

  static String get adptiveMeta => GetPlatform.isMacOS ? meta : ctrl;
  static String ctrl = "^";
  static String shift = "⇧";
  static String alt = "⌥";
  static String up = "↑";
  static String down = "↓";

  static String get metaAdaptive {
    if (GetPlatform.isMacOS) {
      return meta;
    } else if (GetPlatform.isWindows) {
      return ctrl;
    }
    throw "un support platform";
  }
}

abstract class FnKeys {
  static late final metaOrCtrl = GetPlatform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;

  static int? parseNum(LogicalKeyboardKey key) {
    if (num0_9.contains(key)) {
      return int.parse(key.keyLabel);
    }
    return null;
  }

  static late final List<LogicalKeyboardKey> num0_9 = [
    LogicalKeyboardKey.digit0,
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
  ];
  static late final List<LogicalKeyboardKey> num1_9 = num0_9.sublist(1, num0_9.length);

  static late final Set<LogicalKeyboardKey> a_z = {
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyG,
    LogicalKeyboardKey.keyH,
    LogicalKeyboardKey.keyI,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.keyL,
    LogicalKeyboardKey.keyM,
    LogicalKeyboardKey.keyN,
    LogicalKeyboardKey.keyO,
    LogicalKeyboardKey.keyP,
    LogicalKeyboardKey.keyQ,
    LogicalKeyboardKey.keyR,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyT,
    LogicalKeyboardKey.keyU,
    LogicalKeyboardKey.keyV,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyX,
    LogicalKeyboardKey.keyY,
    LogicalKeyboardKey.keyZ,
  };
  static late final Set<LogicalKeyboardKey> metasAdaptive = GetPlatform.isMacOS
      ? {
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.metaLeft,
          LogicalKeyboardKey.metaRight,
        }
      : {
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.controlRight,
        };
  static late final Set<LogicalKeyboardKey> meta = {
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  };
  static late final Set<LogicalKeyboardKey> ctrl = {
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
  };
  static late final Set<LogicalKeyboardKey> shift = {
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
  };
  static late final Set<PhysicalKeyboardKey> shiftPhy = {
    PhysicalKeyboardKey.shiftLeft,
    PhysicalKeyboardKey.shiftRight,
  };

  static late final Set<LogicalKeyboardKey> alt = {
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
  };
  static late final LogicalKeySet cmdK = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyK);
  static late final LogicalKeySet cmdR = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyR);
  static late final LogicalKeySet cmdTab = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.tab);
  static late final LogicalKeySet ctlTab = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.tab);
  static late final LogicalKeySet ctlshiftTab = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift, LogicalKeyboardKey.tab);
  static late final LogicalKeySet space = LogicalKeySet(
    LogicalKeyboardKey.space,
  );
  static late final LogicalKeySet cmdT = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyT);
  static late final LogicalKeySet altS = LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyS);
  static late final LogicalKeySet cmdN = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyN);
  static late final LogicalKeySet cmdShiftV = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyV);
  static late final LogicalKeySet cmdEnter = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.enter);
  static late final LogicalKeySet cmdS = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyS);
  static late final LogicalKeySet cmdG = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyG);
  static late final LogicalKeySet f2 = LogicalKeySet(LogicalKeyboardKey.f2);
  static late final LogicalKeySet f3 = LogicalKeySet(LogicalKeyboardKey.f3);
  static late final LogicalKeySet cmdAltEnter = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.enter);
  static late final LogicalKeySet cmdShiftC = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyC);
  static late final LogicalKeySet cmdAltBackspace = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.backspace);
  static late final LogicalKeySet cmdBackspace = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.backspace);
  static late final LogicalKeySet cmdEsc = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.escape);
  static late final LogicalKeySet cmdComma = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.comma);
  static late final LogicalKeySet cmdAltRight = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowRight);
  static late final LogicalKeySet cmdAltComma = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.comma);
  static late final LogicalKeySet cmdAltS = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.alt, LogicalKeyboardKey.keyS);
  static late final LogicalKeySet cmdW = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyW);
  static late final LogicalKeySet cmdI = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyI);
  static late final LogicalKeySet cmdM = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyM);
  static late final LogicalKeySet ctrlM = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyM);
  static late final LogicalKeySet cmdAdd = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.equal);
  static late final LogicalKeySet cmdA = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyA);
  static late final LogicalKeySet cmdZ = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyZ);
  static late final LogicalKeySet cmdShiftZ = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyZ);
  static late final LogicalKeySet cmdShiftA = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyA);
  static late final LogicalKeySet cmdShiftD = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyD);
  static late final LogicalKeySet cmdMinus = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.minus);
  static late final LogicalKeySet f12 = LogicalKeySet(LogicalKeyboardKey.f12);
  static late final LogicalKeySet f11 = LogicalKeySet(LogicalKeyboardKey.f11);
  static late final LogicalKeySet cmdQ = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyQ);
  static late final LogicalKeySet shiftEnter = LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter);

  static late final LogicalKeySet shift1 = LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.digit1);
  static late final LogicalKeySet shift2 = LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.digit2);
  static late final LogicalKeySet shift3 = LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.digit3);
  static late final LogicalKeySet alt1 = LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit1);
  static late final LogicalKeySet alt2 = LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit2);
  static late final LogicalKeySet alt3 = LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit3);
  static late final LogicalKeySet ctrl1 = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1);
  static late final LogicalKeySet ctrl2 = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2);
  static late final LogicalKeySet ctrl3 = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3);
  static late final LogicalKeySet ctrl4 = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit4);

  static late final LogicalKeySet cmdshiftF = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyF);
  static late final LogicalKeySet cmdF = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyF);
  static late final LogicalKeySet cmdE = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.keyE);
  static late final LogicalKeySet cmdShiftE = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyE);
  static late final LogicalKeySet cmdSlash = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.slash);
  static late final LogicalKeySet cmdBack = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.bracketLeft);
  static late final LogicalKeySet cmdBackSpace = LogicalKeySet(FnKeys.metaOrCtrl, LogicalKeyboardKey.backspace);
  static late final LogicalKeySet delete = LogicalKeySet(LogicalKeyboardKey.delete);
  static late final LogicalKeySet esc = LogicalKeySet(LogicalKeyboardKey.escape);
  static late final LogicalKeySet enter = LogicalKeySet(LogicalKeyboardKey.enter);
}

extension LogicalKeyExt on LogicalKeyboardKey {
  String toReadable() {
    return LogicalKeySet(this).toReadable();
  }
}

extension LogicalKeySetExt on LogicalKeySet {
  String toReadable() {
    Set<LogicalKeyboardKey> keys = this.keys;
    // 如果包含 meta => FnModifyString.meta
    // 如果包含 ctrl => FnModifyString.ctrl
    // 如果包含 shift => FnModifyString.shift
    // 如果包含 alt => FnModifyString.alt
    List<String> modifiers = [];
    if (keys.containsAny(FnKeys.meta)) {
      modifiers.add(FnModifyString.meta);
    }
    if (keys.containsAny(FnKeys.ctrl)) {
      modifiers.add(FnModifyString.ctrl);
    }
    if (keys.containsAny(FnKeys.shift)) {
      modifiers.add(FnModifyString.shift);
    }
    if (keys.containsAny(FnKeys.alt)) {
      modifiers.add(FnModifyString.alt);
    }
    var charaters = keys.toList()
      ..removeWhere(
        (e) => FnKeys.alt.contains(e) || FnKeys.shift.contains(e) || FnKeys.ctrl.contains(e) || FnKeys.meta.contains(e),
      );
    fnassert(() => charaters.length == 1);
    var charater = charaters[0];
    late String label;

    if (charater == LogicalKeyboardKey.backspace) {
      label = "⌫";
    } else if (charater == LogicalKeyboardKey.enter) {
      label = "↵";
    } else if (charater == LogicalKeyboardKey.escape) {
      label = "Esc";
    } else if (charater == LogicalKeyboardKey.arrowRight) {
      label = "→";
    } else if (charater == LogicalKeyboardKey.arrowLeft) {
      label = "←";
    } else if (charater == LogicalKeyboardKey.arrowDown) {
      label = "↓";
    } else if (charater == LogicalKeyboardKey.arrowUp) {
      label = "↑";
    } else {
      label = charater.keyLabel;
    }
    return modifiers.join('') + "" + label;
  }
}
