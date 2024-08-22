import 'package:bot_toast/bot_toast.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/tag/tag_share.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';

class TagPageMobile extends StatefulWidget {
  const TagPageMobile({super.key});

  @override
  State<TagPageMobile> createState() => _TagPageMobileState();
}

class _TagPageMobileState extends State<TagPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("修改标签".i18n),
        actions: [
          if (kDebugMode)
            IconButton(
                onPressed: () {
                  var cnt = AppDatabase.get.tagTb.deleteAll();
                  BotToast.showText(text: "delete %s".i18n.fill([cnt]));
                },
                icon: Icon(Icons.delete_outline)),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return TagsWidget();
  }
}

class TagsWidget extends StatelessWidget {
  const TagsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        autofocus: true,
        onPressed: () {
          requestEditTag(Tag.empty(""));
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        var all = TagStore.find.all;
        var children = all.mapToList(
          (e) => ListTile(
            leading: Container(
              height: 12,
              width: 12,
              color: e.color,
            ),
            title: Text(e.value),
            onTap: () {
              requestEditTag(e);
            },
            trailing: IconButton(
              onPressed: () {
                TagStore.find.delete(e.id);
              },
              color: context.cs.error,
              icon: Icon(
                Icons.delete_outline,
              ),
            ),
          ),
        );
        return ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return children.getNullable(index);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: children.length,
        );
      }),
    );
  }
}
