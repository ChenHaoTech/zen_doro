import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/fn_const.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/component/search_highlight/search_highlight_text.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:get/get.dart';

class FnErrorWidget extends StatefulWidget {
  final FlutterErrorDetails details;
  static final RxList<FlutterErrorDetails> DETAILS_LIST = RxList();

  const FnErrorWidget({
    super.key,
    required this.details,
  });

  @override
  State<FnErrorWidget> createState() => _FnErrorWidgetState();
}

class _FnErrorWidgetState extends State<FnErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ERROR"),
      ),
      body: Builder(builder: (context) {
        return SelectionArea(
          child: ListView(
            children: FnErrorWidget.DETAILS_LIST.mapToList(
              (i) => _build(i),
            ),
          ).simpleShortcuts({
            FnKeys.cmdW: () => Get.back(),
            FnKeys.esc: () => Get.back(),
          }),
        );
      }).paddingSymmetric(
        horizontal: 12,
        vertical: 12,
      ),
    );
  }

  Widget _build(FlutterErrorDetails details) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${details.library}",
          style: context.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text("${details.context}"),
        Divider(),
        SearchHighlightText(
          "${details.exceptionAsString()}",
          searchText: FnConst.packageName,
        ),
        Divider(),
        SearchHighlightText(
          "${details.stack}",
          searchText: FnConst.packageName,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    fnassert(() => FnErrorWidget.DETAILS_LIST.isEmpty);
    FnErrorWidget.DETAILS_LIST.add(widget.details);
  }

  @override
  void dispose() {
    super.dispose();
    FnErrorWidget.DETAILS_LIST.clear();
  }
}
