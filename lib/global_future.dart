import 'dart:async';

abstract class GlobalFuture {
  /// 是否 初始化了 loading
  static final loadingInit = Completer();
  static final initSupbase = Completer();
  static Completer initAccount = Completer();
}
