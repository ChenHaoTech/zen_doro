import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';

extension FnTextStyleExt on TextStyle {
  TextStyle withOpacity(double opacity) {
    return this.copyWith(color: this.color?.withOpacity(opacity));
  }

  TextStyle withSmaller(int fontSizeDec) {
    return this.copyWith(fontSize: (this.fontSize ?? 64) - fontSizeDec);
  }

  TextStyle withBigger(int fontSizeInc) {
    return this.copyWith(fontSize: (this.fontSize ?? 64) + fontSizeInc);
  }

  TextStyle withColor(Color? color) {
    return this.copyWith(color: color);
  }

  TextStyle withStroke({
    required double strokeWidth,
    required Color strokeColor,
  }) =>
      copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = strokeColor,
      );
}

extension FnTextStyleOnBuildontext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  Color dynamicTxtColor(Color? backgroundColor) {
    if (backgroundColor == null) return defaultTextColor;
    return backgroundColor.computeLuminance() > 0.5 ? defaultTextColor : defaultTextBgColor;
  }

  TextStyle get bodySmall => textTheme.bodySmall!;

  TextStyle get bodyMedium => textTheme.bodyMedium!;

  TextStyle get errorText => textTheme.bodyMedium!.copyWith(color: this.cs.error);

  TextStyle get bodyLarge => textTheme.bodyLarge!;

  TextStyle get defaultTextStyle => DefaultTextStyle.of(this).style;

  TextStyle get linkStyle => DefaultTextStyle.of(this).style.copyWith(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      );

  TextStyle get disable => DefaultTextStyle.of(this).style.withOpacity(.6);

  Color get defaultTextColor => DefaultTextStyle.of(this).style.color ?? this.onBackground;

  Color get defaultTextBgColor => DefaultTextStyle.of(this).style.backgroundColor ?? this.background;

  TextStyle get labelSmall => textTheme.labelSmall!;

  TextStyle get labelMedium => textTheme.labelMedium!;

  TextStyle get labelLarge => textTheme.labelLarge!;

  TextStyle get settingSubTitle => textTheme.titleMedium!.copyWith(height: 2);

  TextStyle get settingTitle => textTheme.titleLarge!;

  TextStyle get titleSmall => textTheme.titleSmall!;

  TextStyle get titleMedium => textTheme.titleMedium!;

  TextStyle get titleLarge => textTheme.titleLarge!;

  TextStyle get headlineSmall => textTheme.headlineSmall!;

  TextStyle get headlineMedium => textTheme.headlineMedium!;

  TextStyle get headlineLarge => textTheme.headlineLarge!;

  TextStyle get displaySmall => textTheme.displaySmall!;

  TextStyle get displayMedium => textTheme.displayMedium!;

  TextStyle get displayLarge => textTheme.displayLarge!;
}

extension FastTextColor on TextStyle {
  BuildContext get context => Get.context!;

  TextStyle get primary => copyWith(color: Theme.of(context).colorScheme.primary);

  TextStyle get secondary => copyWith(color: Theme.of(context).colorScheme.secondary);

  TextStyle get tertiary => copyWith(color: Theme.of(context).colorScheme.tertiary);

  TextStyle get onPrimary => copyWith(color: Theme.of(context).colorScheme.onPrimary);

  TextStyle get onSecondary => copyWith(color: Theme.of(context).colorScheme.onSecondary);

  TextStyle get onTertiary => copyWith(color: Theme.of(context).colorScheme.onTertiary);

  TextStyle get background => copyWith(color: Theme.of(context).colorScheme.background);

  TextStyle get onBackground => copyWith(color: Theme.of(context).colorScheme.onBackground);

  TextStyle get surface => copyWith(color: Theme.of(context).colorScheme.surface);

  TextStyle get onSurface => copyWith(color: Theme.of(context).colorScheme.onSurface);

  TextStyle get surfaceTint => copyWith(color: Theme.of(context).colorScheme.surfaceTint);

  TextStyle get error => copyWith(color: Theme.of(context).colorScheme.error);

  TextStyle get onError => copyWith(color: Theme.of(context).colorScheme.onError);

  TextStyle get outline => copyWith(color: Theme.of(context).colorScheme.outline);

  TextStyle get inversePrimary => copyWith(color: Theme.of(context).colorScheme.inversePrimary);

  TextStyle get inverseSurface => copyWith(color: Theme.of(context).colorScheme.inverseSurface);

  TextStyle get onInverseSurface => copyWith(color: Theme.of(context).colorScheme.onInverseSurface);

  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
}
