import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/support/repository/advertise_repository.dart';
import 'package:miti/util/repository/image_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';

part 'image_upload_url_provider.g.dart';

@Riverpod(keepAlive: false)
class ImageUploadUrl extends _$ImageUploadUrl {
  @override
  BaseModel build({required ImageType category, required int count}) {
    get(category: category, count: count);
    return LoadingModel();
  }

  Future<void> get({required ImageType category, required int count}) async {
    final repository = ref.watch(imageRepositoryProvider);
    repository
        .getImageUploadUrls(category: category, count: count)
        .then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}
