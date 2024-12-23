import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../user/param/user_profile_param.dart';
import '../model/game_model.dart';
import '../model/game_payment_model.dart';
import '../model/game_player_model.dart';
import '../model/game_recent_host_model.dart';
import '../model/game_review_model.dart';
import '../param/game_param.dart';

part 'game_repository.g.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return GameRepository(dio);
});

@RestApi(baseUrl: prodServerURL)
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
  @PATCH('/games/{gameId}/convert-free-game')
  Future<ResponseModel<GameDetailModel>> freeGame(
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

  /// 경기 피리뷰자 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/reviewees')
  Future<ResponseModel<GameRevieweesModel>> getReviewees(
      {@Path() required int gameId});

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

  @Headers({'token': 'true'})
  @GET('/users/{userId}/recent-hosted-games')
  Future<ResponseListModel<GameRecentHostModel>> getRecentHostings({
    @Path('userId') required int userId,
  });

  @Headers({'token': 'true'})
  @PUT('/games/{gameId}/cancel')
  Future<ResponseModel<GameDetailModel>> cancelRecruitGame({
    @Path('gameId') required int gameId,
  });

  ///*** 리뷰 관련 api ***
  /// 경기 게스트 참가자 리뷰 작성 API
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/participations/{participationId}/reviews')
  Future<ResponseModel<GameCreateReviewModel>> createGuestReview({
    @Path() required int gameId,
    @Path() required int participationId,
    @Body() required GameReviewParam param,
  });

  /// 경기 호스트 리뷰 작성 API
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/reviews')
  Future<ResponseModel<GameCreateReviewModel>> createHostReview({
    @Path() required int gameId,
    @Body() required GameReviewParam param,
  });

  /// 게스트 리뷰 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/participations/{participationId}/reviews/{reviewId}')
  Future<ResponseModel<ReviewDetailModel>> getGuestReview(
      {@Path() required int gameId,
      @Path() required int participationId,
      @Path() required int reviewId});

  /// 호스트 리뷰 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/reviews/{reviewId}')
  Future<ResponseModel<ReviewDetailModel>> getHostReview(
      {@Path() required int gameId, @Path() required int reviewId});
}
