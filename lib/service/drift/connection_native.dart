import 'package:universal_io/io.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection(String uuid) {
// the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
// put the database file, called db.sqlite here, into the documents folder
// for your app.
    final path = (await getApplicationDocumentsDirectory()).path;
    var sub = appCache.get("account");
    final file = File(p.join(path, kDebugMode ? "debug" : "", sub ?? "", "db_${uuid}"));
    print("_openConnection line(37): ${file.path}");
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}
