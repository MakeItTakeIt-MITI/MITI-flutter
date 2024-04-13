import 'package:intl/intl.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/user/repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/model/auth_model.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../model/user_model.dart';

part 'user_provider.g.dart';

enum UserGameType {
  host,
  participation,
}

@Riverpod(keepAlive: false)
class UserHosting extends _$UserHosting {
  @override
  BaseModel build({required UserGameType type}) {
    getHosting(paginationParam: const PaginationParam(page: 1), type: type);
    return LoadingModel();
  }

  void getHosting(
      {required UserGameType type,
      required PaginationParam paginationParam,
      GameStatus? game_status}) async {
    state = LoadingModel();
    final repository = ref.watch(userRepositoryProvider);
    final id = ref.read(authProvider)!.id!;
    ResponseModel<PaginationModel<GameModel>> model;
    switch (type) {
      case UserGameType.host:
        model = await repository.getHostGame(
            userId: id,
            paginationParam: paginationParam,
            game_status: game_status);
        break;
      default:
        model = await repository.getParticipationGame(
            userId: id,
            paginationParam: paginationParam,
            game_status: game_status);
        break;
    }

    Map<String, List<GameModel>> models = {};
    for (GameModel v in model.data!.page_content) {
      final formatDate =
          DateFormat('yyyy년 MM월 dd일', 'ko').format(DateTime.parse(v.startdate));
      if (models.containsKey(formatDate)) {
        models[formatDate]!.add(v);
      } else {
        models[formatDate] = [v];
      }
    }
    List<GameListByDateModel> insertData = [];
    for (var key in models.keys) {
      insertData.add(GameListByDateModel(datetime: key, models: models[key]!));
    }
    state = PaginationModel<GameListByDateModel>(
      start_index: model.data?.start_index ?? 1,
      end_index: model.data?.end_index ?? 1,
      current_index: model.data?.current_index ?? 1,
      page_content: insertData,
    );
  }
}
