import 'dart:async';

import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:get/get.dart';

mixin AccountListener on DisposableInterface {
  static List<AccountListener> listener = [];

  @override
  void onClose() {
    super.onClose();
    listener.remove(this);
  }

  @override
  void onInit() async {
    super.onInit();
    listener.add(this);
    var accountService = await AccountService.init;
    if (accountService.isLogin) {
      onLogin();
    }
  }

  Future<void> onLogin();

  Future<void> onLogout();
}
