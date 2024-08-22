import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:get/get.dart';

class NetWorkUtils extends GetxService {
  static NetWorkUtils get instance => Get.touch(() => NetWorkUtils());
  final RxList<ConnectivityResult> connectResult = RxList();
  late StreamSubscription<List<ConnectivityResult>> subscription;

  bool get offline {
    var connectivityResult = connectResult.value;
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
      return true;
    } else {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initConnectivityResult();
    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      connectResult.value = result;
    });
  }

  Future _initConnectivityResult() async {
    connectResult.value = await (Connectivity().checkConnectivity());
  }

  @override
  void onClose() {
    super.onClose();
    subscription.cancel();
  }
}
