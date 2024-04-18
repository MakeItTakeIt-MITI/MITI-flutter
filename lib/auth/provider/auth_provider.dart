import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/secure_storage_provider.dart';
import '../../court/view/court_map_screen.dart';
import '../model/auth_model.dart';
import '../param/signup_param.dart';
import '../repository/auth_repository.dart';

final tokenProvider = ChangeNotifierProvider<TokenProvider>((ref) {
  return TokenProvider(ref: ref);
});

class TokenProvider extends ChangeNotifier {
  final Ref ref;

  TokenProvider({
    required this.ref,
  }) {
    ref.listen(authProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  Future<void> logout() async {
    await ref.read(authProvider.notifier).logout();
  }

  String? redirectLogic(GoRouterState goRouteState) {
    log('redirect start!');
    final tokens = ref.read(authProvider);
    final loginIn = goRouteState.path == '/login';

    // 유저 정보가 없는데
    // 로그인중이면 그대로 로그인 페이지에 두고
    // 만약에 로그인중이 아니라면 로그인 페이지로 이동
    if (tokens == null) {
      log("로그인으로 redirect!!");
      return loginIn ? null : '/home';
    }

    if (loginIn) {
      log("로그인 된 사용자 홀로 이동 !!");
      return '/home';
    }
    return null;
  }
}


final authProvider = StateNotifierProvider<AuthStateNotifier, AuthModel?>(
    (StateNotifierProviderRef<AuthStateNotifier, AuthModel?> ref) {
  final repository = ref.watch(authRepositoryProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthStateNotifier(
    repository: repository,
    storage: storage,
    ref: ref,
  );
});

class AuthStateNotifier extends StateNotifier<AuthModel?> {
  final AuthRepository repository;
  final FlutterSecureStorage storage;
  final StateNotifierProviderRef<AuthStateNotifier, AuthModel?> ref;

  AuthStateNotifier({
    required this.repository,
    required this.storage,
    required this.ref,
  }) : super(null) {
    // autoLogin();
  }

  Future<void> reIssueToken() async {
    log("reIssueToken");

    final ResponseModel<TokenModel> result = await repository.getReIssueToken();
    state = state?.copyWith(token: result.data!);
    await storage.write(key: 'accessToken', value: state!.token?.access);
    await storage.write(key: 'refreshToken', value: state!.token?.refresh);
  }

  Future<void> autoLogin({BuildContext? context}) async {
    log("autoLogin");
    final accessToken = await storage.read(key: 'accessToken');
    final refreshToken = await storage.read(key: 'refreshToken');
    final tokenType = await storage.read(key: 'tokenType');
    final id = await storage.read(key: 'id');
    final email = await storage.read(key: 'email');
    final nickname = await storage.read(key: 'nickname');
    final is_authenticated = await storage.read(key: 'is_authenticated');
    if (accessToken != null){
      state = AuthModel(
        token: TokenModel(
            access: accessToken, refresh: refreshToken, type: tokenType),
        id: int.parse(id ?? '0'),
        email: email,
        nickname: nickname,
        is_authenticated: bool.parse(is_authenticated!),
      );
    }

    if(context != null && context.mounted){
      context.goNamed(CourtMapScreen.routeName);
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
    // ref.read(memberProvider.notifier).logout();
    state = null;
  }

}
