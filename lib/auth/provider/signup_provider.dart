import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../model/signup_model.dart';
import '../param/signup_param.dart';

part 'signup_provider.g.dart';

@riverpod
Future<BaseModel> emailCheck(EmailCheckRef ref,
    {required EmailCheckParam param}) async {
  final repository = ref.watch(authRepositoryProvider);

  return await repository
      .duplicateCheckEmail(param: param)
      .then<BaseModel>((value) {
    logger.i('check duplicate ${value.data!.email.is_duplicated}!');
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> signUp(SignUpRef ref,
    {required SignUpBaseParam param, required AuthType type}) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository
      .signUp(param: param, provider: type)
      .then<BaseModel>((value) {
    logger.i('signUp $param!');
    final model = value.data!;
    // ref
    //     .read(phoneAuthProvider.notifier)
    //     .update(user_info_token: model.authentication_token);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
