import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/misc/purchase_utils.dart';
import 'package:flutter_pasteboard/service/sync/DirtyMarker.dart';
import 'package:flutter_pasteboard/service/sync/sync_helper.dart';

bool _syncing = false;

void batchSync() async {
  if (!(await PurchaseUtils.checkPro())) {
    PurchaseUtils.showPurchasePage();
    return;
  }
  if (_syncing) return;
  _syncing = true;
  try {
    for (var element in SyncMangerController.instance.syncHelpers) {
      await element.fetchRecent(limit: 100);
    }
    for (DirtyMarkerController marker in dirtyMarkers) {
      await marker.markDirty(100);
    }
  } catch (e) {
    logger.e("batchSync", e);
  } finally {
    _syncing = false;
  }
}
