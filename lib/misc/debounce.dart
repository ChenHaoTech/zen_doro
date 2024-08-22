import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/function.dart';

abstract class DebounceUtils {
  static final Map<String, Timer> _actions = {};

  static Disposer debounce(
    String key,
    Duration duration,
    VoidCallback callback,
  ) {
    if (duration == Duration.zero) {
      // Call immediately
      callback();
      cancel(key);
    } else {
      cancel(key);
      _actions[key] = Timer(
        duration,
        () {
          callback();
          cancel(key);
        },
      );
    }
    return Disposer(() => cancel(key));
  }

  static void cancel(String key) {
    _actions[key]?.cancel();
    _actions.remove(key);
  }

  static void clear() {
    _actions.forEach((key, timer) {
      timer.cancel();
    });
    _actions.clear();
  }
}
