enum PomodoroState {
  Edit,
  Focus,
  FocusPause,
  FocusTimeEnd,
  Stop,
  Rest,
  RestTimeEnd,
  FocusFeedBack,
}

extension FnStateExt on PomodoroState {
  bool get isFocus => this == PomodoroState.Focus || this == PomodoroState.FocusPause || this == PomodoroState.FocusTimeEnd;

  bool get isTimeOut => this == PomodoroState.FocusTimeEnd || this == PomodoroState.RestTimeEnd;

  bool get isRest => this == PomodoroState.Rest || this == PomodoroState.RestTimeEnd;
  bool get isPause => this == PomodoroState.FocusPause;

  bool get isIdle => this == PomodoroState.Edit || this == PomodoroState.FocusFeedBack;

  bool get isFeedback => this == PomodoroState.FocusFeedBack;
}
