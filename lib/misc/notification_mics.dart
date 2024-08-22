import 'package:flutter/widgets.dart';

extension WidgetExtForNotification on Widget {
  Widget withNotify<T extends Notification>(bool Function(T notification) onNotification) {
    return NotificationListener<T>(
      onNotification: onNotification,
      child: this,
    );
  }

  Widget withNotified<T extends Notification>(
    void Function(T notification) onNotification, {
    bool alwayReturnX = true,
  }) {
    return NotificationListener<T>(
      onNotification: (notification) {
        onNotification(notification);
        return alwayReturnX;
      },
      child: this,
    );
  }
}

extension NotificationExt on ScrollNotification {
  bool get isScrollStart => this is ScrollStartNotification;

  bool get isScrollEnd {
    var not = this;
    return not is ScrollEndNotification || (not is ScrollUpdateNotification && (not.scrollDelta?.abs() ?? 0) < 2);
  }

  bool get isScrollOver => this is OverscrollNotification;

  bool get isScrollUpdate {
    var not = this;
    return not is ScrollUpdateNotification && (not.scrollDelta?.abs() ?? 0) > 5;
  }

  bool get isScrollUp {
    var not = this;
    return not is ScrollUpdateNotification && (not.scrollDelta ?? 0) > 5;
  }

  bool get isScrollDown {
    var not = this;
    return not is ScrollUpdateNotification && (not.scrollDelta ?? 0) < -5;
  }

  bool get isScrollFast {
    var not = this;
    return not is ScrollUpdateNotification && (not.scrollDelta?.abs() ?? 0) > 80;
  }

  bool get isScrollTop {
    var not = this;
    return not is UserScrollNotification && not.metrics.pixels == not.metrics.minScrollExtent;
  }

  bool get isScrollBottom {
    var not = this;
    return not is UserScrollNotification && not.metrics.pixels == not.metrics.maxScrollExtent;
  }
}
