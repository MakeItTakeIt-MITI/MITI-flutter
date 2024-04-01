import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../model/signup_model.dart';
import '../param/signup_param.dart';

part 'signup_provider.g.dart';

//ResponseModel<SignUpCheckModel>
@riverpod
Future<BaseModel> signUpCheck(SignUpCheckRef ref,
    {required BaseParam param}) async {
  final repository = ref.watch(authRepositoryProvider);

  return await repository.signUpCheck(param: param).then<BaseModel>((value) {
    logger.i('check duplicate $param!');
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'code = ${error.status_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
@riverpod
Future<BaseModel> signUp(SignUpRef ref, {required SignUpParam param}) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.signUp(param: param).then<BaseModel>((value) {
    logger.i('signUp $param!');
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
}//김정현
