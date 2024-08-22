import 'dart:async';

import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter_pasteboard/global_future.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/error_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/misc/purchase_utils.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/sync/account_listener.dart';
import 'package:flutter_pasteboard/service/sync/supabase/supabase_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserAccountState {
  /*unlogin=> login, login=>logout, logout=>login*/
  init(0),
  unLogin(1),
  login(2),
  logout(3);

  final int code;

  const UserAccountState(this.code);
}

class AccountService extends GetxService {
  AccountService(this._supabaseService);

  static AccountService? get tryFind => Get.tryFind();

  static Future<AccountService> get init async {
    await GlobalFuture.initAccount.future;
    return tryFind!;
  }

  String? get userName => _supabaseService.auth.currentUser?.identities?.getNullable(0)?.identityData?["username"];

  String? get email => _supabaseService.auth.currentUser?.identities?.getNullable(0)?.identityData?["email"];

  bool get isLogin => userId != null;

  User? get $innerUser => _supabaseService.auth.currentUser;

  String? get userId => _supabaseService.auth.currentUser?.id;

  DateTime? get createdAt => _supabaseService.auth.currentUser?.createdAt.fnmap((val) => DateTime.parse(val));

  final SupabaseService _supabaseService;

  Future<UserAccountState> get state => getUserAccountState();

  Future<bool> get loginSuccessFuture => _loginCompleter.future;
  late Completer<bool> _loginCompleter = Completer();

  logout() async {
    setUserAccountState(UserAccountState.logout);
    Get.deleteAll();
    await (await _supabaseService.auth).signOut();
  }

  Future<String> touchDataBaseBinder(String uuid, [String? dataBaseKey]) async {
    final key = "user_database_key_${uuid}_${$version}";
    var value = appCache.get(key);
    if (dataBaseKey != null && value == null) {
      await appCache.put(key, dataBaseKey);
    }
    return appCache.get(key);
  }

  void _initSupaAuth() {
    (_supabaseService.auth).onAuthStateChange.listen((event) async {
      var authChangeEvent = event.event;
      var session = event.session;
      logger.dd(() => "AuthState 发生变化, 应该是 登入态变化了: ${authChangeEvent},onAuthStateChange: ${session}");
      _onAuthStateChange(authChangeEvent, session);
    });
  }

  Future<void> _onAuthStateChange(AuthChangeEvent authChangeEvent, Session? session) async {
    if ((authChangeEvent == AuthChangeEvent.initialSession && session != null) ||
        authChangeEvent == AuthChangeEvent.signedIn ||
        authChangeEvent == AuthChangeEvent.tokenRefreshed) {
      /*login*/
      var state = await getUserAccountState();
      var appDatabase = AppDatabase.get;
      var userId = session!.user.id;
      late String databaseKey;
      // 如果是第一次init=> login,将已经存在的tryGet.key,放进去
      if (state == UserAccountState.init) {
        databaseKey = await touchDataBaseBinder(userId, appDatabase.key);
      } else {
        // 非第一次登入， 更新
        databaseKey = await touchDataBaseBinder(userId, userId);
      }
      await AppDatabase.setCurrentDataBaseKey(appCache, databaseKey);
      if ((appDatabase.key ?? "") != databaseKey) {
        this.log.w("key 不对 ${appDatabase.key} => ${databaseKey}, 重新初始化 database, ${state},${appDatabase}");
        await appDatabase.dispose();
        AppDatabase.register(AppDatabase.$getCurrentDataBaseKey(appCache));
      } else {
        this.log.dd(() => "key 相同 ${appDatabase.key} => ${databaseKey}, 不用重新初始化 database, ${state},${appDatabase}");
      }

      var res = await _login(session);
      if (!res) logger.e("login fail");
    } else if (authChangeEvent == AuthChangeEvent.signedOut || authChangeEvent == AuthChangeEvent.userDeleted) {
      var res = await _logout();
      if (!res) logger.e("logout fail");
    }
  }

  static final String _userAccountStateKey = "userAccountState_${$version}";

  Future<UserAccountState> getUserAccountState() async {
    int code = appCache.get(_userAccountStateKey, defaultValue: UserAccountState.init.code);
    return UserAccountState.values.firstWhere((i) => i.code == code);
  }

  static setUserAccountState(UserAccountState value) async {
    appCache.put(_userAccountStateKey, value.code);
  }

  Future<bool> _logout() async {
    setUserAccountState(UserAccountState.logout);
    _loginCompleter = Completer<bool>();
    for (var l in AccountListener.listener.toList()) {
      await l.onLogout();
    }
    return Future.value(true);
  }

  Future<bool> _login(Session? session) async {
    if (_loginCompleter.isCompleted) {
      this.log.dd(() => "_loginCompleter: 已经完成了,跳过");
      return Future.value(true);
    }

    if (session?.user == null) {
      this.log.dd(() => "session?.user ${session?.user} 为空");
      return Future.value(false);
    }
    PurchaseUtils.markLogin(userId!);
    ErrorUtils.login(userId: userId!, email: email, userName: userName!);

    setUserAccountState(UserAccountState.login);
    _loginCompleter.complete(true);
    logger.dd(() async => "用户登入成功, 之前的状态是: ${await state} , 开始执行 login 回调: ${AccountListener.listener.length}");
    for (var l in AccountListener.listener.toList()) {
      await l.onLogin();
    }
    return Future.value(true);
  }

  @override
  void onInit() {
    super.onInit();
    _initSupaAuth();
  }

  @override
  void onReady() {}
}
