import 'package:miti/game/param/game_param.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/game/repository/game_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';

part 'game_provider.g.dart';

@Riverpod(keepAlive: true)
class GameList extends _$GameList {
  @override
  BaseModel build({required GameListParam param}) {
    getList(param: param);
    return LoadingModel();
  }

  Future<void> getList({required GameListParam param}) async {
    final repository = ref.watch(gameRepositoryProvider);
    repository.getGameList(param: param).then((value) {
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

@Riverpod(keepAlive: false)
class GameDetail extends _$GameDetail {
  @override
  BaseModel build({required int gameId}) {
    get(gameId: gameId);
    return LoadingModel();
  }

  Future<void> get({required int gameId}) async {
    final repository = ref.watch(gameRepositoryProvider);
    repository.getGameDetail(gameId: gameId).then((value) {
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

@riverpod
Future<BaseModel> gameCreate(GameCreateRef ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  final param = ref.watch(gameFormProvider);
  return await repository.createGame(param: param).then<BaseModel>((value) {
    logger.i(value);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
