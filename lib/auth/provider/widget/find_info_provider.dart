import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:miti/auth/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/logger/custom_logger.dart';
import '../../../common/model/default_model.dart';
import '../../../common/model/entity_enum.dart';
import '../../model/find_info_model.dart';
import '../../param/phone_verify_param.dart';

part 'find_info_provider.g.dart';

final phoneNumberProvider = StateProvider.family
    .autoDispose<String, PhoneAuthenticationPurposeType>((ref, type) => '');
final emailProvider = StateProvider.autoDispose<String>((ref) => '');

@riverpod
Future<BaseModel> sendCode(SendCodeRef ref,
    {required PhoneAuthenticationPurposeType authType}) async {
  final repository = ref.watch(authRepositoryProvider);
  final phone = ref.read(phoneNumberProvider(authType)).replaceAll('-', '');
  final SendCodeParam param = SendCodeParam(phone: phone, purpose: authType);

  switch (authType) {
    case PhoneAuthenticationPurposeType.find_email:
      return await repository.sendCode(param: param).then<BaseModel>((value) {
        logger.i('findEmail $param!');
        final model = value.data!;
        ref.read(phoneAuthProvider(type: authType).notifier).update(
              authentication_token: model.authenticationToken,
              type: authType,
            );
        log('token ${model.authenticationToken}');
        return value;
      }).catchError((e) {
        final error = ErrorModel.respToError(e);
        logger.e(
            'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
        return error;
      });

    case PhoneAuthenticationPurposeType.password_update:
      return await repository.sendCode(param: param).then<BaseModel>((value) {
        logger.i('findPassword $param!');
        final model = value.data!;
        ref.read(phoneAuthProvider(type: authType).notifier).update(
              authentication_token: model.authenticationToken,
              type: authType,
            );
        log('token ${model.authenticationToken}');
        return value;
      }).catchError((e) {
        final error = ErrorModel.respToError(e);
        logger.e(
            'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
        return error;
      });

    /// todo
    case PhoneAuthenticationPurposeType.signup:
      return await repository.sendCode(param: param).then<BaseModel>((value) {
        logger.i('findPassword $param!');
        final model = value.data!;
        ref.read(phoneAuthProvider(type: authType).notifier).update(
              authentication_token: model.authenticationToken,
              type: authType,
            );
        log('token ${model.authenticationToken}');
        return value;
      }).catchError((e) {
        final error = ErrorModel.respToError(e);
        logger.e(
            'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
        return error;
      });
  }
}

@Riverpod(keepAlive: false)
class FindEmail extends _$FindEmail {
  @override
  EmailVerifyModel? build() {
    return null;
  }

  void update(EmailVerifyModel model) {
    state = model;
  }
}

@Riverpod(keepAlive: false)
class FindPassword extends _$FindPassword {
  @override
  PasswordVerifyModel? build() {
    return null;
  }

  void update(PasswordVerifyModel model) {
    state = model;
  }
}

@riverpod
Future<BaseModel> verifyPhone(VerifyPhoneRef ref,
    {required PhoneAuthenticationPurposeType type}) async {
  final model = ref.read(phoneAuthProvider(type: type));

  final param = PhoneVerifyParam(
      code: model.code,
      purpose: model.type,
      authentication_token: model.authentication_token);

  switch (type) {
    case PhoneAuthenticationPurposeType.signup:
      return await ref
          .watch(authRepositoryProvider)
          .verifySignPhone(param: param)
          .then<BaseModel>((value) {
        logger.i('verifyPhone!!');
        final model = value.data!;
        ref
            .read(signUpFormProvider.notifier)
            .updateForm(signup_token: model.signupToken);
        return value;
      }).catchError((e) {
        final error = ErrorModel.respToError(e);
        logger.e(
            'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
        return error;
      });
    case PhoneAuthenticationPurposeType.find_email:
      return await ref
          .watch(authRepositoryProvider)
          .verifyEmailPhone(param: param)
          .then<BaseModel>((value) {
        logger.i('verifyPhone!!');
        ref.read(findEmailProvider.notifier).update(value.data!);
        return value;
      }).catchError((e) {
        final error = ErrorModel.respToError(e);
        logger.e(
            'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
        return error;
      });
    case PhoneAuthenticationPurposeType.password_update:
      return await ref
          .watch(authRepositoryProvider)
          .verifyPasswordPhone(param: param)
          .then<BaseModel>((value) {
        logger.i('verifyPhone!!');
        ref.read(findPasswordProvider.notifier).update(value.data!);
        return value;
      }).catchError((e) {
        final error = ErrorModel.respToError(e);
        logger.e(
            'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
        return error;
      });
  }
}
