import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/provider/signup_provider.dart';
import 'package:miti/auth/provider/widget/find_info_provider.dart';
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:miti/auth/repository/auth_repository.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
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
Future<BaseModel> login(LoginRef ref) async {
  final param = ref.read(loginFormProvider);
  return await ref
      .watch(authRepositoryProvider)
      .login(param: param)
      .then<BaseModel>((value) async {
    logger.i('login $param!');
    final model = value.data!;
    final storage = ref.read(secureStorageProvider);

    await Future.wait([
      storage.write(key: 'accessToken', value: model.token.access),
      storage.write(key: 'refreshToken', value: model.token.refresh),
      storage.write(key: 'tokenType', value: model.token.type),
    ]);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'code = ${error.status_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> oauthLogin(OauthLoginRef ref, {required OauthLoginParam param}) async {
  return await ref
      .watch(authRepositoryProvider)
      .oauthLogin(param: param, provider: 'kakao')
      .then<BaseModel>((value) async {
    logger.i('oauthLogin $param!');
    final model = value.data!;
    final storage = ref.read(secureStorageProvider);

    await Future.wait([
      storage.write(key: 'accessToken', value: model.token.access),
      storage.write(key: 'refreshToken', value: model.token.refresh),
      storage.write(key: 'tokenType', value: model.token.type),
    ]);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'code = ${error.status_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}


enum PhoneAuthType { signup, login }

@riverpod
Future<BaseModel> requestSMS(LoginRef ref,
    {required PhoneAuthType type}) async {
  late final RequestCodeParam param;
  switch (type) {
    case PhoneAuthType.signup:
      param =
          RequestCodeParam.fromSignForm(model: ref.read(signUpFormProvider));
      break;
    case PhoneAuthType.login:
      param =
          RequestCodeParam.fromLoginForm(model: ref.read(loginFormProvider));
      break;
  }

  return await ref
      .watch(authRepositoryProvider)
      .requestCode(param: param)
      .then<BaseModel>((value) {
    logger.i('requestSMS $param!');
    final model = value.data!;
    ref
        .read(phoneAuthProvider.notifier)
        .update(user_info_token: model.authentication_token);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'code = ${error.status_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> sendSMS(LoginRef ref) async {
  final model = ref.read(phoneAuthProvider);
  final param = CodeParam(code: model.code);
  return await ref
      .watch(authRepositoryProvider)
      .sendCode(param: param, user_info_token: model.user_info_token)
      .then<BaseModel>((value) {
    logger.i('sendSMS $param!');
    final model = value.data!;
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'code = ${error.status_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> requestNewPassword(LoginRef ref) async {
  final email = ref.read(emailProvider);
  final param = RequestNewPasswordParam(email: email);
  return await ref
      .watch(authRepositoryProvider)
      .requestNewPassword(param: param)
      .then<BaseModel>((value) {
    logger.i('requestNewPassword $param!');
    final model = value.data;
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'code = ${error.status_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> resetPassword(LoginRef ref) async {
  final param = ResetPasswordParam(password: '', password_check: '');
  return await ref
      .watch(authRepositoryProvider)
      .resetPassword(
        param: param,
        token: '',
      )
      .then<BaseModel>((value) {
    logger.i('resetPassword $param!');
    final model = value.data;
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'code = ${error.status_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
