import 'dart:async';

import 'package:flutter_pasteboard/misc/extension.dart';

class Locker<T> {
  Completer<T> _complete = Completer();

  Locker([T? initV]) {
    if (initV != null) {
      _complete.tryComplete(initV);
    }
  }

  bool get isCompleted => _complete.isCompleted;

  void lock() {
    _complete = Completer();
  }

  Future<T> wait() async {
    return await _complete.future;
  }

  void release([T? value]) {
    _complete.tryComplete(value);
  }
}
