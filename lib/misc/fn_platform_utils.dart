import 'package:flutter/foundation.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';

abstract class PlatformUtils {
  static bool get _isDesktop => GetPlatform.isDesktop;

  static bool get isMac => GetPlatform.isMacOS;
  static bool get isAndroid => GetPlatform.isAndroid;

  static bool get isDesktop {
    // if (kDebugMode) return false;
    return _isDesktop;
  }

  static bool get _isMobile => GetPlatform.isMobile && Get.context!.isMobile;

  static bool get isMobile {
    // if (kDebugMode) return true;
    return _isMobile;
  }

  static bool get isWeb => kIsWeb;
}
