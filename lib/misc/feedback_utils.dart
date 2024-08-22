import 'package:flutter/cupertino.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:get/get.dart';
import 'package:wiredash/wiredash.dart';

class FeedbackUtils extends GetxService {
  static FeedbackUtils get instance => Get.touch(() => FeedbackUtils._());

  FeedbackUtils._();

  void show(BuildContext context) {
    Wiredash.of(context).show(inheritMaterialTheme: true);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
