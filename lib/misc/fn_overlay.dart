import 'dart:async';

import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

abstract class FnOverlay {
  static debugFocus() {
    Completer? _comp;
    FocusManager.instance.addListener(() {
      if (!kFnDebug) return;
      _comp?.tryComplete();
      var value = "${FocusManager.instance.primaryFocus?.debugLabel}\n${FocusManager.instance.primaryFocus?.debugKey}";
      showOverlay((comp) {
        _comp = comp;
        return Row(
          children: [
            Spacer(),
            Builder(builder: (context) {
              return Text(
                "${value}",
                style: context.defaultTextStyle.copyWith(backgroundColor: context.background),
              );
            }),
            Spacer()
          ],
        );
      }, duration: 24.hours);
    });
  }

  static List<Completer> needDismiss = [];

  static Future showBottom(Widget Function(Completer) widgetSupplier, {Duration? duration}) {
    return showOverlay((comp) {
      return widgetSupplier.call(comp);
    }, duration: duration);
  }

  static Future showOverlay(
    Widget Function(Completer) supplier, {
    Duration? duration,
    double opacity = 0,
    bool dismissOnTap = true,
    bool bottom = true,
    bool autoDismiss = true,
  }) {
    var comp = Completer();
    if (autoDismiss) {
      needDismiss.add(comp);
      comp.future.then((value) => needDismiss.remove(comp));
    }
    // 如果 duration 时间大于 24 小时, 那么就不消失
    if (duration != null && duration.inHours < 24) {
      Future.delayed(duration, () => comp.tryComplete());
    }
    return Get.showOverlayWithoutOpa(
      asyncFunction: () => comp.future,
      loadingWidget: () {
        Widget child;
        if (bottom) {
          child = Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              supplier.call(comp),
              gap48,
            ],
          );
        } else {
          child = supplier.call(comp);
        }
        if (!dismissOnTap) return child;
        child = Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => comp.tryComplete(),
              onPanUpdate: (e) => comp.tryComplete(),
              child: () {
                if (opacity != 0) {
                  return child.container(color: context.onBackground.withOpacity(opacity));
                } else {
                  return child;
                }
              }(),
            );
          }
        );

        return child;
      }(),
    );
  }

  static Future showRawOverlay(
    Widget Function(Completer) supplier, {
    Duration? duration,
    double opacity = 0,
    bool autoDismiss = true,
  }) {
    var comp = Completer();
    if (autoDismiss) {
      needDismiss.add(comp);
      comp.future.then((value) => needDismiss.remove(comp));
    }
    if (duration != null) {
      Future.delayed(duration, () => comp.tryComplete());
    }
    return Get.showOverlayWithoutOpa(
      asyncFunction: () => comp.future,
      loadingWidget: () {
        var child = supplier.call(comp);
        child = Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => comp.tryComplete(),
              onPanUpdate: (e) => comp.tryComplete(),
              child: () {
                if (opacity != 0) {
                  return child.container(color: context.onBackground.withOpacity(opacity));
                } else {
                  return child;
                }
              }(),
            );
          }
        );

        return child;
      }(),
    );
  }
}
