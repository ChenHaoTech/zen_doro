import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

import '../theme/theme.dart';

class PopUpMenuConfig {
  final Widget widget;
  final void Function()? action;
  final bool customer;

  PopUpMenuConfig(this.widget, [this.action, this.customer = false]);

  static PopUpMenuConfig textBtn(String txt, void Function() action, {TextStyle? style}) {
    return PopUpMenuConfig(Text(txt, style: style), action);
  }

  static PopUpMenuConfig obx(Widget Function() supplier, void Function() action) {
    return PopUpMenuConfig(Obx(supplier), action);
  }

  static PopUpMenuConfig diver() {
    return PopUpMenuConfig(
      Divider(height: 5),
      null,
      true,
    );
  }

  static PopUpMenuConfig withShortcur(
    String txt,
    void Function() action, {
    required LogicalKeySet? keySet,
    Color? color,
  }) {
    return PopUpMenuConfig(
      KeySetTextWidget(
        txt: txt,
        keySet: keySet,
        color: color,
      ),
      action,
    );
  }

  static PopUpMenuConfig raw(Widget widget) {
    return PopUpMenuConfig(
      widget,
      null,
      true,
    );
  }
}

class KeySetTextWidget extends StatelessWidget {
  final String txt;
  final LogicalKeySet? keySet;
  final Color? color;

  const KeySetTextWidget({
    super.key,
    required this.txt,
    this.keySet,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(builder: (context) {
          return Text(
            txt,
            style: context.defaultTextStyle.withColor(color),
          );
        }),
        Spacer(),
        if (keySet != null && PlatformUtils.isDesktop)
          Builder(builder: (context) {
            return Text(
              keySet!.toReadable(),
              style: context.defaultTextStyle.withOpacity(.3).withSmaller(2),
            );
          }),
      ],
    );
  }
}

PopUpMenuConfig buildDrawerBtn(Widget icon, Widget child, Function onPress) {
  return PopUpMenuConfig(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.opacity(.7),
          gap4,
          child,
        ],
      ).paddingOnly(
        left: 8,
        right: 8,
      ), () {
    onPress.call();
  });
}

class FnPopUpMenu extends StatelessWidget {
  final List<PopUpMenuConfig> configs;
  final Widget? label;
  final Widget? child;
  final GlobalKey<PopupMenuButtonState>? popUpKey;
  final PopupMenuCanceled? onCanceled;
  final VoidCallback? onOpened;
  final Function(PopUpMenuConfig config)? onSelected;
  final String? tooltip;

  const FnPopUpMenu({
    super.key,
    required this.configs,
    this.child,
    this.popUpKey,
    this.label,
    this.onCanceled,
    this.onOpened,
    this.onSelected,
    this.tooltip,
  });

  // todo 增加builder

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      key: popUpKey,
      onOpened: onOpened,
      onCanceled: onCanceled,
      onSelected: (i) {
        var config = configs[i];
        config.action?.call();
        onSelected?.call(config);
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<int>> res = [];
        if (label != null) {
          res.add(PopupMenuWidget(label!));
        }
        for (var i = 0; i < configs.length; i++) {
          var c = configs[i];
          if (c.customer) {
            res.add(PopupMenuWidget(c.widget));
            continue;
          }
          res.add(PopupMenuItem<int>(
            value: i,
            child: c.widget,
          ));
        }
        return res;
      },
      tooltip: tooltip,
      child: child ?? FnIcons.moreIcon.paddingAll(12).opacity(.4),
    );
  }
}

class PopupMenuWidget extends PopupMenuEntry<Never> {
  final Widget child;

  const PopupMenuWidget(this.child, {super.key});

  @override
  double get height => 16;

  @override
  bool represents(Never? value) => false;

  @override
  State<PopupMenuWidget> createState() => _PopupMenuLabelState();
}

class _PopupMenuLabelState extends State<PopupMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

void showPopUpMenu(BuildContext context, TapUpDetails detail, List<(Widget, void Function()?)> menus) async {
  var offset = detail.globalPosition;
  double left = offset.dx;
  double top = offset.dy;
  await showMenu(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    position: RelativeRect.fromDirectional(textDirection: Directionality.of(context), start: left, top: top, end: left + 2, bottom: top + 2),
    items: menus.mapToList((e) => PopupMenuItem(
          enabled: e.$2 != null,
          onTap: e.$2,
          child: e.$1,
        )),
    elevation: 8.0,
  );
}
