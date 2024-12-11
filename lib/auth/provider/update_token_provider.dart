import 'dart:developer';

import 'package:miti/auth/param/update_token_param.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../repository/auth_repository.dart';

part 'update_token_provider.g.dart';

@riverpod
Future<BaseModel> updateToken(UpdateTokenRef ref,
    {required String password}) async {
  final UpdateTokenParam param = UpdateTokenParam(password: password);

  return await ref
      .watch(authRepositoryProvider)
      .getUpdateToken(param: param)
      .then<BaseModel>((value) async {
    logger.i('getUpdateToken $param!');

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
