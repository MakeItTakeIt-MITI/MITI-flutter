import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/provider/secure_storage_provider.dart';
import '../../court/view/court_map_screen.dart';
import '../../game/model/v2/auth/base_token_response.dart';
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

  Future<String?> redirectLogic(GoRouterState goRouteState) async {
    log('redirect start!');

    AuthModel? tokens = ref.read(authProvider);
    if (tokens == null) {
      await ref.read(authProvider.notifier).autoLogin();
      tokens = ref.read(authProvider);
    }

    final loginIn = goRouteState.path == '/login';

    // 유저 정보가 없는데
    // 로그인중이면 그대로 로그인 페이지에 두고
    // 만약에 로그인중이 아니라면 로그인 페이지로 이동
    if (tokens == null) {
      log("로그인으로 redirect!! ${goRouteState.path}");
      if (goRouteState.path == '/home') {
        return '/login';
      }
      return loginIn ? null : '/login';
    }

    if (loginIn) {
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

  Future<String> reIssueToken() async {
    log("reIssueToken");

    final ResponseModel<BaseTokenResponse> result =
        await repository.getReIssueToken();
    state = state?.copyWith(token: result.data!);
    await storage.write(key: 'accessToken', value: state!.token?.access);
    await storage.write(key: 'refreshToken', value: state!.token?.refresh);
    return state!.token?.access ?? '';
  }

  Future<void> autoLogin({BuildContext? context}) async {
    log("autoLogin");
    final accessToken = await storage.read(key: 'accessToken');
    final refreshToken = await storage.read(key: 'refreshToken');
    final tokenType = await storage.read(key: 'tokenType');
    final id = await storage.read(key: 'id');
    final email = await storage.read(key: 'email');
    final nickname = await storage.read(key: 'nickname');
    final signUpTypeString = await storage.read(key: 'signUpType');
    if (signUpTypeString != null) {}

    ///todo 수정 필요
    final signUpType =
        SignupMethodType.stringToEnum(value: signUpTypeString ?? 'email');

    if (accessToken != null && refreshToken != null && tokenType != null) {
      state = AuthModel(
        token: BaseTokenResponse(
            access: accessToken, refresh: refreshToken, type: tokenType),
        id: int.parse(id ?? '0'),
        email: email,
        nickname: nickname,
        signUpType: signUpType,
      );
      if (context != null && context.mounted) {
        log("로그인 완료!");
        context.goNamed(CourtMapScreen.routeName);
      }
    } else {
      if (context != null && context.mounted) {
        log("로그인 필요합니다!");
        context.goNamed(LoginScreen.routeName);
      }
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
    state = null;
  }
}
