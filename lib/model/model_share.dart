import 'package:collection/collection.dart';

enum TimeRule {
  UpdateDuration,
  UpdateEndTime,
}

enum TimeBlockType {
  FOCUS(0),
  REST(1),
  ;

  final int code;

  const TimeBlockType(this.code);

  bool match(int code) {
    return this.code == code;
  }

  static TimeBlockType? from(int code) {
    return TimeBlockType.values.firstWhereOrNull((e) => e.code == code);
  }
}

enum ActionLogType {
  PAUSE(0),
  RESUME(1),
  STOP(2),
  ;

  final int code;

  const ActionLogType(this.code);

  bool match(int code) {
    return this.code == code;
  }
}

enum RestType {
  COUNT_DOWN(0),
  POSITIVE_TIMING(1),
  ;

  final int code;

  const RestType(this.code);

  bool match(int code) {
    return this.code == code;
  }
}

enum FocusEndAction {
  POP(0),
  POP_TOP(3),
  ;

  final int code;

  const FocusEndAction(this.code);

  static FocusEndAction defaultV = FocusEndAction.POP;

  static FocusEndAction of(int code) {
    return FocusEndAction.values.firstWhereOrNull((e) => e.code == code) ?? FocusEndAction.POP;
  }

  bool match(int code) {
    return this.code == code;
  }
}

enum PomodoroType {
  COMMOND(0),
  PROGRESSIVE(1),
  CUSTOM(2),
  ;

  final int code;

  const PomodoroType(this.code);

  bool match(int code) {
    return this.code == code;
  }
}
