import 'package:flutter/cupertino.dart';
import 'package:i18n_extension/i18n_extension.dart';

// 语言包:
/*
* {
  "version": "1.2.3",
  "last_updated": "2023-10-01",
  "metadata": {
    "author": "Your Name",
    "email": "your.email@example.com",
    "description": "Language pack for the application."
  },
  "supported_local": "zh_CN"
}
* */
abstract class FnLocalUtils {
  static const chinese = const Locale('zh', "CN");

  static List<Locale> get supportLocals {
    return [
      fallback,
      chinese,
    ];
  }

  static void updateLocal(
    BuildContext context,
    Locale local,
  ) {
    //todo 如果本地没有toast 下载远端包
    I18n.of(context).locale = local;
  }

  static Locale get local {
    return I18n.locale;
  }

  static Locale get fallback {
    return const Locale("en", "US");
  }
}

extension LocaleExt on Locale {
  String getLocaleDisplayName() {
    Locale locale = this;
    switch (locale.toString()) {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      default:
        return 'Unknown';
    }
  }
}