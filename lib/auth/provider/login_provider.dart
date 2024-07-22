import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miti/auth/model/auth_model.dart';
import 'package:miti/auth/param/phone_verify_param.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/provider/signup_provider.dart';
import 'package:miti/auth/provider/widget/find_info_provider.dart';
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:miti/auth/repository/auth_repository.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/notification_provider.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../param/auth_param.dart';
import '../param/login_param.dart';
import '../param/signup_param.dart';

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
    {required LoginBaseParam param, required AuthType type}) async {
  final fcmToken = ref.read(fcmTokenProvider)!;

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
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error
            .error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

Future<void> saveUserInfo(FlutterSecureStorage storage, LoginModel model,
    AutoDisposeFutureProviderRef ref) async {
  await Future.wait([
    storage.write(key: 'id', value: model.id.toString()),
    storage.write(key: 'email', value: model.email),
    storage.write(key: 'nickname', value: model.nickname),
    storage.write(key: 'signUpType', value: model.signup_method.name),
    storage.write(key: 'accessToken', value: model.token.access),
    storage.write(key: 'refreshToken', value: model.token.refresh),
    storage.write(key: 'tokenType', value: model.token.type),
  ]);
  ref.read(authProvider.notifier).autoLogin();
}

@riverpod
Future<BaseModel> oauthLogin(OauthLoginRef ref,
    {required LoginBaseParam param, required AuthType type}) async {
  return await ref
      .watch(authRepositoryProvider)
      .oauthLogin(param: param, provider: type)
      .then<BaseModel>((value) async {
    logger.i('oauthLogin $param!');
    final model = value.data!;
    final storage = ref.read(secureStorageProvider);
    log('refreshToken = ${model.token.refresh}');
    await saveUserInfo(storage, model, ref);

    final refresh = await storage.read(key: 'refreshToken');
    log('refreshrefresh = ${refresh}');
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error
            .error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

enum PhoneAuthType { signup, login }

// @riverpod
// Future<BaseModel> requestSMS(RequestSMSRef ref,
//     {required PhoneAuthType type}) async {
//   late final RequestCodeParam param;
//   switch (type) {
//     case PhoneAuthType.signup:
//       param =
//           RequestCodeParam.fromSignForm(model: ref.read(signUpFormProvider));
//       break;
//     case PhoneAuthType.login:
//       param =
//           RequestCodeParam.fromLoginForm(model: ref.read(loginFormProvider));
//       break;
//   }
//
//   return await ref
//       .watch(authRepositoryProvider)
//       .requestCode(param: param)
//       .then<BaseModel>((value) {
//     logger.i('requestSMS $param!');
//     final model = value.data!;
//     // ref
//     //     .read(phoneAuthProvider.notifier)
//     //     .update(user_info_token: model.authentication_token);
//     return value;
//   }).catchError((e) {
//     final error = ErrorModel.respToError(e);
//     logger.e(
//         'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
//     return error;
//   });
// }

@riverpod
Future<BaseModel> sendSMS(SendSMSRef ref) async {
  // final model = ref.read(phoneAuthProvider);
  // final param = CodeParam(code: model.code);
  return LoadingModel();
  // return await ref
  //     .watch(authRepositoryProvider)
  //     .sendCode(param: param, user_info_token: model.user_info_token)
  //     .then<BaseModel>((value) {
  //   logger.i('sendSMS $param!');
  //   final model = value.data!;
  //   return value;
  // }).catchError((e) {
  //   final error = ErrorModel.respToError(e);
  //
  //   logger.e(
  //       'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
  //   return error;
  // });
}
