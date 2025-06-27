import 'package:miti/support/repository/advertise_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';

part 'advertise_provider.g.dart';

@Riverpod(keepAlive: false)
class Advertise extends _$Advertise {
  @override
  BaseModel build({required int advertisementId}) {
    get(advertisementId: advertisementId);
    return LoadingModel();
  }

  Future<void> get({required int advertisementId}) async {
    final repository = ref.watch(advertiseRepositoryProvider);
    repository
        .getAdvertiseDetail(advertisementId: advertisementId)
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
