import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

QueryExecutor openConnection(String uuid) {
  return DatabaseConnection.delayed(Future(() async {
    var databaseName = '${kDebugMode ? "debug_" : ""}db_${uuid}';
    final result = await WasmDatabase.open(
      databaseName: databaseName, // prefer to only use valid identifiers here
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      // Depending how central local persistence is to your app, you may want
      // to show a warning to the user if only unrealiable implemetentations
      // are available.
      print('Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}');
    } else {
      print("init web database success:${databaseName}, ${result}");
    }

    return result.resolvedExecutor;
  }));
}
