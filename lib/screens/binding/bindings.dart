import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/screens/mobile/controller/pomodoro_home_controller.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/service/undo_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PomodoroHomeController());
    Get.lazyPut(() => TagStore());
    Get.lazyPut(() => TimeBlockStore());
    Get.lazyPut(() => TimeRuleController());
    Get.lazyPut(() => FnUndoController());
  }
}
