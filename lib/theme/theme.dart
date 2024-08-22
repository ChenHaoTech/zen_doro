import 'package:daily_extensions/daily_extensions.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/fn_random.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

export 'padding_constants.dart';
export 'text_theme.dart';

extension ColorsExt on Color {
  Color withSaturation(/*0~1*/ double saturation) {
    return HSVColor.fromColor(this).withSaturation(saturation).toColor();
  }

  String toHex() {
    return "#${this.value.toRadixString(16).padLeft(8, '0').toUpperCase()}";
  }

  Color withLightness(/*0~1*/ double ligntness) {
    return HSVColor.fromColor(this).withValue(ligntness).toColor();
  }
}

extension ResponsiveBreakpointsExt on BuildContext {
  // 获取ResponsiveBreakpoints的实例
  ResponsiveBreakpointsData get responsiveBreakpoints => ResponsiveBreakpoints.of(this);

  // 判断是否是桌面
  bool get isDesktop => responsiveBreakpoints.isDesktop;

  // 判断是否是平板
  bool get isTablet => responsiveBreakpoints.isTablet;

  // 判断是否是手机
  bool get isMobile => responsiveBreakpoints.isMobile;

  // 判断是否是电话
  bool get isPhone => responsiveBreakpoints.isPhone;
}

abstract class FnColors {
  static Color pickRandom({
    List<Color>? exclude,
  }) {
    var nonRepeatingRandomGenerator = NonRepeatingRandomGenerator(usedNumbers: exclude?.mapToList((e) => e.value) ?? []);
    return nonRepeatingRandomGenerator.random(tagColors) ?? tagColors.random;
  }

  static List<ColorSwatch> tagColors = <ColorSwatch>[
    Colors.purple,
    Colors.purpleAccent,
    Colors.deepPurpleAccent,
    Colors.indigoAccent,
    Colors.blue,
    Colors.lightBlueAccent,
    Colors.cyanAccent,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.greenAccent,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.yellow,
    Colors.amber,
    Colors.amberAccent,
    Colors.orange,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.red,
    Colors.pinkAccent,
  ];
}

abstract class FnIcons {
  /*
  * /Users/apple/Work/dev/flutter/packages/flutter/lib/src/cupertino/icons.dart:3201
  * */
  static const IconData pin = Icons.push_pin;
  static const IconData feedback = Icons.feedback_outlined;
  static const IconData login = Icons.account_circle_outlined;
  static const IconData text_right = HeroIcons.arrow_small_right;
  static const IconData question = Icons.question_mark_rounded;
  static const IconData skip = Icons.skip_next_rounded;
  static const IconData start = Icons.play_arrow_rounded;
  static const IconData focus = ZondIcons.hour_glass;
  static const IconData stop = Icons.stop_rounded;
  static const IconData discard = Icons.close_rounded;
  static const IconData snooze = Icons.snooze_rounded;
  static const IconData rest = ZondIcons.coffee;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData setting = Icons.tune;
  static const IconData done = Icons.done;
  static const IconData close = Icons.close;
  static const IconData filter = Icons.filter_list;
  static const IconData explore = Icons.swipe_outlined;
  static const IconData add = Icons.add;
  static const Icon addIcon = Icon(Icons.add);
  static const Icon markIcon = Icon(Icons.bookmark_border);
  static const IconData mark = Icons.bookmark_border;
  static const Icon historyIcon = Icon(Icons.history);
  static const IconData history = Icons.history;
  static const Icon noteIcon = Icon(Icons.sticky_note_2_outlined);
  static const IconData more = Icons.more_horiz_outlined;
  static const IconData moreV = Icons.more_vert_rounded;
  static const IconData down = Icons.keyboard_arrow_down_outlined;
  static const Icon moreIcon = Icon(Icons.more_horiz_outlined);
  static const Icon dateIcon = Icon(Icons.date_range);
  static const Icon searchIcon = Icon(Icons.search);

  // static const IconData deleteBack = FontAwesome.delete_left;
  static const IconData delete = Icons.delete_forever_outlined;

  static const IconData unPin = Icons.push_pin_outlined;
}

abstract class FnTheme {
  // todo font选择
  static ThemeData get lightTheme => _lightTheme;

  static void updateTheme(ThemeData data) {
    var cs = data.colorScheme;
    _lightTheme = data.copyWith(
        colorScheme: cs.copyWith(
      background: cs.primaryContainer.withOpacity(.1),
      surface: cs.primaryContainer.withOpacity(.1),
    ));
    Get.rootController.setTheme(_lightTheme);
    DebugUtils.log("theme:195: ${data} \n${StackTrace.current}");
  }

  static void set lightTheme(value) {
    _lightTheme = value;
    Get.rootController.setTheme(value);
  }

  static ThemeData _lightTheme = FlexThemeData.light(
    scheme: FlexScheme.sakura,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useTextTheme: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      appBarBackgroundSchemeColor: SchemeColor.primaryContainer,
    ),
    keyColors: const FlexKeyColors(
      useTertiary: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: false,
    // To use the Playground font, add GoogleFonts package and uncomment
    // fontFamily: GoogleFonts.notoSans().fontFamily,
  );

  static ThemeData get darkTheme => _darkTheme;

  static void set darkTheme(value) {
    _darkTheme = value;
    Get.rootController.update();
  }

  static ThemeData _darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.redWine,
  );
}

abstract class Aligneds {
  static Aligned get fbl_ttl {
    return Aligned(
      follower: Alignment.bottomLeft,
      target: Alignment.topLeft,
      offset: Offset(0, -4),
    );
  }
}

// FnTextStyle
abstract class FnStyle {
  static RoundedRectangleBorder recBorder([double? radius]) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius ?? 12.0),
    );
  }

  static Size appbarSize = Size.fromHeight(48);

  static ButtonStyle get buttonStyle => ButtonStyle(
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.67))),
      );

  static InputDecoration get normalinputDecoration {
    return InputDecoration(
      enabledBorder: null,
      disabledBorder: null,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
      ),
    );
  }

  static InputDecoration get normalinputDecorationWithoutBorder {
    return InputDecoration(
      enabledBorder: null,
      disabledBorder: null,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
    );
  }

  static InputDecoration get underlineDecoration {
    return InputDecoration(
      enabledBorder: null,
      disabledBorder: null,
      filled: true,
    );
  }
}

extension TextStyleExt on TextStyle {
  TextStyle copyMapper(TextStyle Function(TextStyle) mapper) {
    return mapper.call(this);
  }
}

class ThemeMapper extends StatelessWidget {
  final TextTheme Function(TextTheme)? textThemeMapper;
  final IconThemeData Function(IconThemeData)? iconThemeMapper;
  final TextStyle? Function(TextTheme)? defaultTextStyle;
  final Widget child;

  const ThemeMapper({
    super.key,
    this.textThemeMapper,
    required this.child,
    this.iconThemeMapper,
    this.defaultTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var themeData = Theme.of(context);
      var widget = child;
      if (defaultTextStyle?.call(themeData.textTheme) != null) {
        widget = DefaultTextStyle(
          style: defaultTextStyle!.call(themeData.textTheme)!,
          child: child,
        );
      }
      return Theme(
          data: themeData.copyWith(
            textTheme: themeData.textTheme.merge(textThemeMapper?.call(themeData.textTheme)),
            iconTheme: themeData.iconTheme.merge(iconThemeMapper?.call(themeData.iconTheme)),
          ),
          child: widget);
    });
  }
}

extension BuildContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppBarTheme get appbarTheme => Theme.of(this).appBarTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  ColorScheme get cs => theme.colorScheme;

  TextTheme get tt => theme.textTheme;

  Color get background => colorScheme.background;

  Color get onBackground => colorScheme.onBackground;
  Color get focusColor => colorScheme.onBackground.withOpacity(.1);

  Color get primary => colorScheme.primary;

  Color get pomodoroColor => colorScheme.primary;

  Color get pomodoroContainerColor => colorScheme.primaryContainer;

  Color get restContainerColor => Colors.lightGreen.withOpacity(.3);

  Color get restColor => Colors.lightGreen;

  Color get secondary => colorScheme.secondary;

  Color get onPrimary => colorScheme.onPrimary;
}
