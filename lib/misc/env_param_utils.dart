import 'package:envied/envied.dart';

part 'env_param_utils.g.dart';

@Envied(obfuscate: true, path: "lib/.env")
abstract class EnvParamUtils {
  @EnviedField(varName: "SUPABASE_URL", obfuscate: true)
  static String SUPABASE_URL = _EnvParamUtils.SUPABASE_URL;
  @EnviedField(varName: "SUPABASE_ANON_KEY", obfuscate: true)
  static String SUPABASE_ANON_KEY = _EnvParamUtils.SUPABASE_ANON_KEY;
  @EnviedField(varName: "IOS_API_KEY_PURCHASE", obfuscate: true)
  static String IOS_API_KEY = _EnvParamUtils.IOS_API_KEY;
  @EnviedField(varName: "WIREDASH_ID", obfuscate: true)
  static String WIREDASH_ID = _EnvParamUtils.WIREDASH_ID;
  @EnviedField(varName: "SENTRY_DSN", obfuscate: true)
  static String SENTRY_DSN = _EnvParamUtils.SENTRY_DSN;
  @EnviedField(varName: "WIREDASH_SECRET", obfuscate: true)
  static String WIREDASH_SECRET = _EnvParamUtils.WIREDASH_SECRET;

  static $assert() {
    assert(SUPABASE_URL.isNotEmpty, 'SUPABASE_URL不能为空');
    assert(SUPABASE_ANON_KEY.isNotEmpty, 'SUPABASE_ANON_KEY不能为空');
    assert(IOS_API_KEY.isNotEmpty, 'IOS_API_KEY不能为空');
    assert(WIREDASH_ID.isNotEmpty, 'WIREDASH_ID不能为空');
    assert(SENTRY_DSN.isNotEmpty, 'SENTRY_DSN不能为空');
    assert(WIREDASH_SECRET.isNotEmpty, 'WIREDASH_SECRET不能为空');
  }
}
