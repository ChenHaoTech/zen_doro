import 'dart:async';

import 'package:get/get.dart';
import 'package:meta/meta.dart';

final List<DirtyMarkerController> dirtyMarkers = [];
mixin DirtyMarkerController on GetxController {
  Future markDirty(int cnt);

  @override
  void onInit() {
    super.onInit();
    dirtyMarkers.add(this);
  }

  @override
  void onClose() {
    super.onClose();
    dirtyMarkers.remove(this);
  }
}
