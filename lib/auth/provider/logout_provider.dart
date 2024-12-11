import 'dart:developer';

import 'package:miti/auth/provider/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/provider/secure_storage_provider.dart';
import '../../notification_provider.dart';
import '../param/auth_param.dart';
import '../repository/auth_repository.dart';

part "logout_provider.g.dart";

@riverpod
Future<BaseModel> logout(LogoutRef ref) async {
  return await ref
      .watch(authRepositoryProvider)
      .logout()
      .then<BaseModel>((value) async {
    logger.i('logout!!');
    ref.read(authProvider.notifier).logout();
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
