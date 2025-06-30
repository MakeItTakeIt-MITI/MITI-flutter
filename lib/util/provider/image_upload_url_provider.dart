import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/support/repository/advertise_repository.dart';
import 'package:miti/util/repository/file_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../param/file_upload_param.dart';

part 'image_upload_url_provider.g.dart';

@riverpod
Future<BaseModel> fileUploadUrl(FileUploadUrlRef ref,
    {required FileUploadParam param}) async {
  final repository = ref.watch(fileRepositoryProvider);
  return await repository
      .getFileUploadUrls(
    param: param,
  )
      .then<BaseModel>((value) {
    logger.i(value);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
