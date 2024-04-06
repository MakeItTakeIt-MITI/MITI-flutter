import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/auth/param/signup_param.dart';
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:miti/auth/repository/auth_repository.dart';
import 'package:miti/auth/view/find_info/find_info_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/logger/custom_logger.dart';
import '../../../common/model/default_model.dart';
import '../../model/find_info_model.dart';
import '../../param/auth_param.dart';
import '../../param/find_info_param.dart';

part 'find_info_provider.g.dart';

final phoneNumberProvider = StateProvider.autoDispose<String>((ref) => '');
final emailProvider = StateProvider.autoDispose<String>((ref) => '');

@riverpod
Future<BaseModel> findInfo(FindInfoRef ref,
    {required FindInfoType type}) async {
  final repository = ref.watch(authRepositoryProvider);
  final phone = ref.read(phoneNumberProvider).replaceAll('-', '');
  final FindInfoParam param = FindInfoParam(phone: phone);

  switch (type) {
    case FindInfoType.email:
      return await repository.findEmail(param: param).then<BaseModel>((value) {
        logger.i('findEmail $param!');
        final model = value.data!;
        ref
            .read(phoneAuthProvider.notifier)
            .update(user_info_token: model.authentication_token);
        log('token ${model.authentication_token}');
        return value;
      }).catchError((e) {
        final error = ErrorModel.respToError(e);
        logger.e(
            'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
        return error;
      });
    case FindInfoType.password:
      return await repository
          .findPassword(param: param)
          .then<BaseModel>((value) {
        logger.i('findPassword $param!');
        final model = value.data!;
        ref
            .read(phoneAuthProvider.notifier)
            .update(user_info_token: model.authentication_token);
        log('token ${model.authentication_token}');
        return value;
      }).catchError((e) {
        final error = ErrorModel.respToError(e);
        logger.e(
            'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
        return error;
      });
  }
}

@riverpod
Future<BaseModel> reissueForPassword(ReissueForPasswordRef ref) async {
  final user_info_token = ref.read(phoneAuthProvider).user_info_token;
  return await ref
      .watch(authRepositoryProvider)
      .reissueForPassword(user_info_token: user_info_token)
      .then<BaseModel>((value) {
    logger.i('reissueForPassword !');
    final model = value.data;
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> resetPassword(ResetPasswordRef ref) async {
  final user_info_token = ref.read(phoneAuthProvider).user_info_token;
  final model = ref.read(signUpFormProvider);
  final param = ResetPasswordParam.fromModel(model: model);
  return await ref
      .watch(authRepositoryProvider)
      .resetPassword(
        param: param,
        token: user_info_token,
      )
      .then<BaseModel>((value) {
    logger.i('resetPassword $param!');
    final model = value.data;
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
