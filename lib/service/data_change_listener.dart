import 'package:flutter/cupertino.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:get/get.dart';

abstract class TimeBlockChangeListener {
  void whenUpsertBlockChange(TimeBlock newTb) {}

  void whenDeleteTimeBlock(String uuid) {}
  void whenRemoteUpsertTimeBlock(TimeBlock newTb) {}

  static final List<TimeBlockChangeListener> listener = [];
}

abstract class SettingChangeListener {
  void whenSettingChange(String key, dynamic oldV, dynamic newV) {}
  static final List<SettingChangeListener> listener = [];
}

mixin TimeBlockChangeGetxMixin on DisposableInterface implements TimeBlockChangeListener {
  void whenUpsertBlockChange(TimeBlock newTb) {}

  void whenDeleteTimeBlock(String uuid) {}
  void whenRemoteUpsertTimeBlock(TimeBlock newTb) {}
  @override
  void onInit() {
    super.onInit();
    fnassert(() => !TimeBlockChangeListener.listener.contains(this));
    TimeBlockChangeListener.listener.add(this);
  }

  @override
  void onClose() {
    super.onClose();
    fnassert(() => TimeBlockChangeListener.listener.contains(this));
    TimeBlockChangeListener.listener.remove(this);
  }
}

mixin TimeBlockChangeStateMixin<T extends StatefulWidget> on State<T> implements TimeBlockChangeListener {
  void whenRemoteUpsertTimeBlock(TimeBlock newTb) {}
  @override
  void initState() {
    super.initState();
    fnassert(() => !TimeBlockChangeListener.listener.contains(this));
    TimeBlockChangeListener.listener.add(this);
  }

  @override
  void dispose() {
    super.dispose();
    fnassert(() => TimeBlockChangeListener.listener.contains(this));
    TimeBlockChangeListener.listener.remove(this);
  }
}

mixin DataChanegStateMixin<T extends StatefulWidget> on State<T> implements TimeBlockChangeListener, SettingChangeListener {
  @override
  void initState() {
    super.initState();
    fnassert(() => !TimeBlockChangeListener.listener.contains(this));
    TimeBlockChangeListener.listener.add(this);
    fnassert(() => !SettingChangeListener.listener.contains(this));
    SettingChangeListener.listener.add(this);
  }

  @override
  void dispose() {
    super.dispose();
    fnassert(() => TimeBlockChangeListener.listener.contains(this));
    TimeBlockChangeListener.listener.remove(this);
    fnassert(() => SettingChangeListener.listener.contains(this));
    SettingChangeListener.listener.remove(this);
  }
}
mixin DataChanegGetxMixin on DisposableInterface implements TimeBlockChangeListener, SettingChangeListener {
  void whenRemoteUpsertTimeBlock(TimeBlock newTb) {}
  @override
  void onInit() {
    super.onInit();
    fnassert(() => !TimeBlockChangeListener.listener.contains(this));
    TimeBlockChangeListener.listener.add(this);
    fnassert(() => !SettingChangeListener.listener.contains(this));
    SettingChangeListener.listener.add(this);
  }

  @override
  void onClose() {
    super.onClose();
    fnassert(() => TimeBlockChangeListener.listener.contains(this));
    TimeBlockChangeListener.listener.remove(this);
    fnassert(() => SettingChangeListener.listener.contains(this));
    SettingChangeListener.listener.remove(this);
  }
}
