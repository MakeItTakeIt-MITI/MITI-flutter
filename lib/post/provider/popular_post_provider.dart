import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../repository/post_repository.dart';

part 'popular_post_provider.g.dart';

@Riverpod(keepAlive: false)
class PopularPost extends _$PopularPost {
  @override
  BaseModel build() {
    get();
    return LoadingModel();
  }

  Future<void> get() async {
    final repository = ref.watch(postRepositoryProvider);
    repository.getPopularPosts().then((value) {
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
