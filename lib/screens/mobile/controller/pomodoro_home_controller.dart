import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

class TimeBlockViewModel {
  final int length = 2;
  final List<Widget> tabs = [
    Text("日历".i18n),
    Text("列表".i18n),
  ];
  late int initIdx = 0;
}

class PomodoroHomeController extends GetxController {
  int get selectedIndex => _selectedIndex;
  final Rx<TimeBlockViewModel?> timeBlockModel = Rx(null);
  final TimeBlockViewModel _vm = TimeBlockViewModel();

  set selectedIndex(value) {
    _selectedIndex = value;
    if (_selectedIndex == 1) {
      timeBlockModel.value = _vm;
    } else {
      timeBlockModel.value = null;
    }
    update();
  }

  int _selectedIndex = 0;

  void requestHome() {
    _selectedIndex = 0;
    update();
  }
}
