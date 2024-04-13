import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/user/model/user_model.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/game_model.dart';

part 'user_repository.g.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class UserRepository {
  factory UserRepository(Dio dio) = _UserRepository;

  @Headers({'token': 'true'})
  @GET('/users/{userId}')
  Future<ResponseModel<UserModel>> getUserInfo({@Path() required int userId});

  @Headers({'token': 'true'})
  @GET('/users/{userId}/hostings')
  Future<ResponseModel<PaginationModel<GameModel>>> getHostGame({
    @Path() required int userId,
    @Queries() required PaginationParam paginationParam,
    @Query('game_status') GameStatus? game_status,
  });

  @Headers({'token': 'true'})
  @GET('/users/{userId}/participated-games')
  Future<ResponseModel<PaginationModel<GameModel>>> getParticipationGame({
    @Path() required int userId,
    @Queries() required PaginationParam paginationParam,
    @Query('game_status') GameStatus? game_status,
  });
}
