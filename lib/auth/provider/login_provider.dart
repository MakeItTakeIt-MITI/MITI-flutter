
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/repository/auth_repository.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/notification_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/v2/auth/login_response.dart';
import '../param/auth_param.dart';
import '../param/login_param.dart';

part 'login_provider.g.dart';

@riverpod
class LoginForm extends _$LoginForm {
  @override
  LoginParam build() {
    return LoginParam(email: '', password: '');
  }

  void updateFormField({String? email, String? password}) {
    state = state.copyWith(email: email, password: password);
  }

  bool isValid() {
    final validEmail = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(state.email);
    if (validEmail && state.password.length > 7) {
      return true;
    }
    return false;
  }
}

@riverpod
Future<BaseModel> login(LoginRef ref,
    {required LoginBaseParam param, required SignupMethodType type}) async {
  final fcmToken = ref.read(fcmTokenProvider)!;
  print("login fcm_token ${fcmToken}");
  print(type);

  return await ref
      .watch(authRepositoryProvider)
      .login(
        param: param,
        provider: type,
        fcmToken: fcmToken,
      )
      .then<BaseModel>((value) async {
    logger.i('login $param!');
    final model = value.data!;
    final storage = ref.read(secureStorageProvider);

    await saveUserInfo(storage, model, ref);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    print('error!!');
    print(error.status_code);
    print(error.error_code);
    print(error.message);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

Future<void> saveUserInfo(FlutterSecureStorage storage, LoginResponse model,
    AutoDisposeFutureProviderRef ref) async {
  await Future.wait([
    storage.write(key: 'id', value: model.id.toString()),
    storage.write(key: 'email', value: model.email),
    storage.write(key: 'nickname', value: model.nickname),
    storage.write(key: 'signUpType', value: model.signupMethod.name),
    storage.write(key: 'accessToken', value: model.token.access),
    storage.write(key: 'refreshToken', value: model.token.refresh),
    storage.write(key: 'tokenType', value: model.token.type),
  ]);
  await ref.read(authProvider.notifier).autoLogin();
}
//
// @riverpod
// Future<BaseModel> oauthLogin(OauthLoginRef ref,
//     {required LoginBaseParam param, required AuthType type}) async {
//   final fcmToken = ref.read(fcmTokenProvider)!;
//   print("oauth login fcm_token ${fcmToken}");
//   return await ref
//       .watch(authRepositoryProvider)
//       .oauthLogin(param: param, provider: type, fcmToken: fcmToken)
//       .then<BaseModel>((value) async {
//         print('oauthLogin');
//     logger.i('oauthLogin $param!');
//     final model = value.data!;
//     final storage = ref.read(secureStorageProvider);
//     log('refreshToken = ${model.token.refresh}');
//     await saveUserInfo(storage, model, ref);
//
//     final refresh = await storage.read(key: 'refreshToken');
//     log('refreshrefresh = ${refresh}');
//     return value;
//   }).catchError((e) {
//     final error = ErrorModel.respToError(e);
//     print('error!!');
//     print(error.status_code);
//     print(error.error_code);
//     print(error.message);
//     logger.e(
//         'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
//     return error;
//   });
// }
