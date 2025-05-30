
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:miti/chat/repository/chat_repository.dart';
import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';

part 'chat_approve_provider.g.dart';


@Riverpod(keepAlive: false)
class ChatApprove extends _$ChatApprove {
  @override
  BaseModel build({required int gameId}) {
    get(gameId: gameId);
    return LoadingModel();
  }

  Future<void> get({required int gameId}) async {
    final repository = ref.watch(chatRepositoryProvider);
    repository.getChatApproveInfo(gameId: gameId).then((value) {
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
