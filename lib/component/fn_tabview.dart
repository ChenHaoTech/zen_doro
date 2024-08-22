import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:ui_extension/ui_extension.dart';

class FnTabView extends StatefulWidget {
  final List<(/*title*/ Widget, /*body*/ Widget)> tabBinding;
  final Widget Function(TabBar tabBar)? tabBarBuilder;
  final Widget Function(TabBarView)? tabBodyBuilder;
  final Function(int idx)? onChange;
  final int initialIndex;

  const FnTabView({
    super.key,
    required this.tabBinding,
    this.tabBarBuilder,
    this.tabBodyBuilder,
    this.initialIndex = 0,
    this.onChange,
  });

  @override
  State<FnTabView> createState() => FnTabViewState();
}

class FnTabViewState extends State<FnTabView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: widget.tabBinding.length,
      child: Builder(builder: (context) {
        return Column(
          children: [
            PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: widget.tabBarBuilder?.call(_buildTabBar(context)) ?? _buildTabBar(context),
            ).tooltip(
              FnKeys.ctlTab.toReadable(),
            ),
            gap12,
            (widget.tabBodyBuilder?.call(_buildTabBody()) ?? _buildTabBody()).expand(),
          ],
        ).onLifeCycle(onInit: () {
          var controller = DefaultTabController.of(context);
          controller.addListener(() {
            widget.onChange?.call(controller.index);
          });
        }).simpleShortcuts({
          FnKeys.ctlTab: () {
            var controller = DefaultTabController.of(context);
            controller.animateTo((controller.index + 1) % widget.tabBinding.length);
          },
          FnKeys.ctlshiftTab: () {
            var controller = DefaultTabController.of(context);
            controller.animateTo((controller.index - 1) % widget.tabBinding.length);
          },
        });
      }),
    );
  }

  TabBar _buildTabBar(BuildContext context) {
    return TabBar(
      labelColor: context.cs.primary,
      dividerColor: context.cs.primaryContainer,
      unselectedLabelColor: context.cs.primary.withOpacity(.4),
      indicatorColor: context.cs.primaryContainer,
      tabs: widget.tabBinding.mapToList(
        (e) => e.$1,
      ),
    );
  }

  TabBarView _buildTabBody() {
    return TabBarView(
        children: widget.tabBinding.mapToList(
      (e) => e.$2,
    ));
  }
}
