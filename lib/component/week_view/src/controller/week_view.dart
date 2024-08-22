import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/week_view/src/controller/day_view.dart';
import 'package:flutter_pasteboard/component/week_view/src/controller/zoom_controller.dart';

/// Allows to control some parameters of a week view.
class WeekViewController extends ZoomController with ZoomControllerListener {
  /// All day view controllers.
  final Map<DateTime, DayViewController> _dayViewControllers = {};

  /// Creates a new week view controller.
  WeekViewController({
    double zoomCoefficient = 0.8,
    double? minZoom,
    double? maxZoom,
  }) : super(
          zoomCoefficient: zoomCoefficient,
          minZoom: minZoom,
          maxZoom: maxZoom,
        );

  /// Returns the day view controller associated with the specified date.
  DayViewController getDayViewController(DateTime date) {
    if (!_dayViewControllers.containsKey(date)) {
      var dayViewController = DayViewController(
        zoomCoefficient: zoomCoefficient,
        minZoom: minZoom,
        maxZoom: maxZoom,
        onDisposed: _onDayViewControllerDisposed,
      );
      _dayViewControllers[date] = dayViewController
        ..previousZoomFactor = previousZoomFactor
        ..zoomFactor = zoomFactor;
      dayViewController.addListener(this);
    }

    return _dayViewControllers[date]!;
  }

  void updateZoomFactor(double zoomFactor, {ScaleUpdateDetails? details}) {
    for (DayViewController controller in _dayViewControllers.values) {
      controller.changeZoomFactor(zoomFactor, notify: false, details: details);
    }
    super.changeZoomFactor(zoomFactor, notify: true, details: details);
  }

  // @override
  // void scaleStart(ScaleStartDetails details) {
  //   super.scaleStart(details);
  //   for (DayViewController controller in _dayViewControllers.values) {
  //     controller.scaleStart(details);
  //   }
  // }

  // @override
  // void changeZoomFactor(double zoomFactor, {bool notify = true, ScaleUpdateDetails? details}) {
  //   super.changeZoomFactor(zoomFactor, notify: notify, details: details);
  //   // for (DayViewController controller in _dayViewControllers.values) {
  //   //   controller.changeZoomFactor(zoomFactor, notify: notify, details: details);
  //   // }
  // }

  @override
  void dispose() {
    super.dispose();
    for (DayViewController controller in _dayViewControllers.values.toList()) {
      controller.dispose();
    }
    _dayViewControllers.clear();
  }

  /// Triggered when a day view controller is disposed.
  void _onDayViewControllerDisposed(DayViewController dayViewController) =>
      _dayViewControllers.removeWhere((date, controller) => controller == dayViewController);

  @override
  void onZoomFactorChanged(covariant ZoomController controller, ScaleUpdateDetails details) {
    // 监听 daiyl controler的
    changeZoomFactor(controller.zoomFactor, details: details, notify: true);
  }

  @override
  void onZoomStart(covariant ZoomController controller, ScaleStartDetails details) {
    scaleStart(details);
  }
}
