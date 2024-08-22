import 'package:flutter_pasteboard/misc/i18n/local_utils.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'local_const.dart';

//[i18n_extension |Flutter 软件包 --- i18n_extension | Flutter package](https://pub.dev/packages/i18n_extension)
extension Localization on String {
  //
  static final t = Translations.byLocale("en_us") +
      {
        "en_us": i18n_en_us,
      };

  String get i18n {
    var split = this.split("//");
    var key = split[0];
    var localize2 = localize(key, t);
    if (FnLocalUtils.local == FnLocalUtils.chinese) return key;
    return localize2;
  }

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, t);

  String version(Object modifier) => localizeVersion(modifier, this, t);

  Map<String?, String> allVersions() => localizeAllVersions(this, t);
}
