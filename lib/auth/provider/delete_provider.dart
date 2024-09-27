import 'package:miti/auth/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import 'auth_provider.dart';

part 'delete_provider.g.dart';

@riverpod
Future<BaseModel> deleteUser(DeleteUserRef ref) async {
  return await ref
      .watch(authRepositoryProvider)
      .deleteUser()
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(authProvider.notifier).logout();
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
