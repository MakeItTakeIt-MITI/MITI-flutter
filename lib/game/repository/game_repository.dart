import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../model/game_model.dart';
import '../model/game_payment_model.dart';
import '../model/game_player_model.dart';
import '../model/game_review_model.dart';
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

  @Headers({'token': 'true', 'required': 'false'})
  @GET('/games/{gameId}')
  Future<ResponseModel<GameDetailModel>> getGameDetail(
      {@Path() required int gameId});

  @Headers({'token': 'true'})
  @POST('/games')
  Future<ResponseModel<GameDetailModel>> createGame(
      {@Body() required GameCreateParam param});

  @Headers({'token': 'true'})
  @PATCH('/games/{gameId}')
  Future<ResponseModel<GameDetailModel>> updateGame(
      {@Body() required GameUpdateParam param, @Path() required int gameId});

  @Headers({'token': 'true'})
  @GET('/games/{gameId}/host')
  Future<ResponseModel<UserReviewModel>> getHost({@Path() required int gameId});

  @Headers({'token': 'true'})
  @GET('/games/{gameId}/payment-info')
  Future<ResponseModel<GamePaymentModel>> getPayment(
      {@Path() required int gameId});

  @Headers({'token': 'true'})
  @GET('/games/{gameId}/players')
  Future<ResponseModel<GamePlayerListModel>> getPlayers(
      {@Path() required int gameId});

  @Headers({'token': 'true'})
  @POST('/games/{gameId}/participations/{participationId}/guest-reviews')
  Future<ResponseModel<GameCreateReviewModel>> createGuestReview({
    @Path() required int gameId,
    @Path() required int participationId,
    @Body() required GameReviewParam param,
  });

  @Headers({'token': 'true'})
  @POST('/games/{gameId}/reviews')
  Future<ResponseModel<GameCreateReviewModel>> createHostReview({
    @Path() required int gameId,
    @Body() required GameReviewParam param,
  });

  @Headers({'token': 'true'})
  @DELETE('/games/{gameId}/participations/{participationId}')
  Future<ResponseModel<ParticipationModel>> cancelGame({
    @Path('gameId') required int gameId,
    @Path('participationId') required int participationId,
  });

  @Headers({'token': 'true'})
  @GET('/games/{gameId}/participations/{participationId}/refund-info')
  Future<ResponseModel<RefundModel>> refundInfo({
    @Path('gameId') required int gameId,
    @Path('participationId') required int participationId,
  });

  @Headers({'token': 'true'})
  @GET('/ratings/{ratingId}')
  Future<ResponseModel<UserReviewModel>> getRating({
    @Path('ratingId') required int ratingId,
  });
}
