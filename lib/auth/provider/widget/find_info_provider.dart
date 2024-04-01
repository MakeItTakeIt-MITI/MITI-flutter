import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/logger/custom_logger.dart';
import '../../../common/model/default_model.dart';
import '../../param/find_email_param.dart';

part 'find_info_provider.g.dart';

final phoneNumberProvider = StateProvider.autoDispose<String>((ref) => '');
final emailProvider = StateProvider.autoDispose<String>((ref) => '');

@riverpod
Future<BaseModel> findEmail(FindEmailRef ref) async {
  final repository = ref.watch(authRepositoryProvider);
  final phone = ref.read(phoneNumberProvider).replaceAll('-', '');
  final FindEmailParam param = FindEmailParam(phone: phone);

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
        'code = ${error.status_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
