import 'package:flutter_pasteboard/service/sync/supabase/supabase_channel.dart';
import 'package:flutter_pasteboard/service/sync/supabase/supabase_json_mixin.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:get/get.dart';

class SupabaseService extends SupaBaseMixin with SupaBaseJsonMixin, SupaBaseChannelMixin {
  static SupabaseService? get tryFind => Get.tryFind();

  SupabaseService();
}
