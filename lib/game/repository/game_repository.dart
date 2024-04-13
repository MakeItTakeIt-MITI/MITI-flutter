import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../model/game_model.dart';
import '../param/game_param.dart';

part 'game_repository.g.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return GameRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class GameRepository {
  factory GameRepository(Dio dio) = _GameRepository;

  // @Headers({'token': 'true'})
  @GET('/games')
  Future<ResponseListModel<GameModel>> getGameList(
      {@Queries() required GameListParam param});

  // @Headers({'token': 'true'})
  @GET('/games/{gameId}')
  Future<ResponseModel<GameDetailModel>> getGameDetail(
      {@Path() required int gameId});

  @Headers({'token': 'true'})
  @POST('/games')
  Future<ResponseModel<GameDetailModel>> createGame(
      {@Body() required GameCreateParam param});
}
