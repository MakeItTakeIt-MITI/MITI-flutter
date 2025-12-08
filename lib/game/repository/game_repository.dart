import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/provider/dio_provider.dart';
import '../../review/model/v2/game_reviewee_list_response.dart';
import '../../review/model/v2/guest_review_response.dart';
import '../model/game_model.dart';
import '../model/participation_payment_detail_response.dart';
import '../model/v2/game/game_detail_response.dart';
import '../model/v2/game/game_player_list_response.dart';
import '../model/v2/game/game_with_court_map_response.dart';
import '../model/v2/game/game_with_court_response.dart';
import '../model/v2/participation/participation_game_response.dart';
import '../model/v2/payment/participation_refund_info_response.dart';
import '../param/game_pagination_param.dart';
import '../param/game_param.dart';

part 'game_repository.g.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return GameRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class GameRepository {
  factory GameRepository(Dio dio, {String baseUrl}) = _GameRepository;

  /// 경기 지도 목록 조회 API
  @GET('/games/map')
  Future<ResponseListModel<GameWithCourtMapResponse>> getMapGameList(
      {@Queries() required GameListParam param});

  /// 경기 상세 조회 API
  @Headers({'token': 'true', 'required': 'false'})
  @GET('/games/{gameId}')
  Future<ResponseModel<GameDetailResponse>> getGameDetail(
      {@Path() required int gameId});

  /// 경기 무료 전환 API
  @Headers({'token': 'true'})
  @PATCH('/games/{gameId}/convert-free-game')
  Future<ResponseModel<GameDetailResponse>> freeGame(
      {@Path() required int gameId});

  /// 경기 모집 생성 API
  @Headers({'token': 'true'})
  @POST('/games')
  Future<ResponseModel<GameDetailResponse>> createGame(
      {@Body() required GameCreateParam param});

  /// 경기 정보 수정 API
  @Headers({'token': 'true'})
  @PATCH('/games/{gameId}')
  Future<ResponseModel<GameDetailResponse>> updateGame(
      {@Body() required GameUpdateParam param, @Path() required int gameId});

  @Headers({'token': 'true'})
  @GET('/games/{gameId}/host')
  Future<ResponseModel<UserReviewModel>> getHost({@Path() required int gameId});

  /// 경기 참여 결제 정보 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/payment-info')
  Future<ResponseModel<ParticipationPaymentDetailResponse>> getPayment(
      {@Path() required int gameId});

  /// 경기 피리뷰자 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/reviewees')
  Future<ResponseModel<GameRevieweeListResponse>> getReviewees(
      {@Path() required int gameId});

  /// 경기 참여 취소 및 환불 API
  @Headers({'token': 'true'})
  @DELETE('/games/{gameId}/participations/{participationId}')
  Future<ResponseModel<ParticipationGameResponse>> cancelGame({
    @Path('gameId') required int gameId,
    @Path('participationId') required int participationId,
  });

  /// 경기 참여 환불 정보 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/participations/{participationId}/refund-info')
  Future<ResponseModel<ParticipationRefundInfoResponse>> refundInfo({
    @Path('gameId') required int gameId,
    @Path('participationId') required int participationId,
  });

  @Headers({'token': 'true'})
  @GET('/ratings/{ratingId}')
  Future<ResponseModel<UserReviewModel>> getRating({
    @Path('ratingId') required int ratingId,
  });

  /// 최근 호스팅 경기 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/recent-hosted-games')
  Future<ResponseListModel<GameWithCourtResponse>> getRecentHostings({
    @Path('userId') required int userId,
  });

  /// 경기 모집 취소 API
  @Headers({'token': 'true'})
  @PUT('/games/{gameId}/cancel')
  Future<ResponseModel<GameDetailResponse>> cancelRecruitGame({
    @Path('gameId') required int gameId,
  });

  ///*** 리뷰 관련 api ***
  /// 경기 게스트 참가자 리뷰 작성 API
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/participations/{participationId}/reviews')
  Future<ResponseModel<GameRevieweeListResponse>> createGuestReview({
    @Path() required int gameId,
    @Path() required int participationId,
    @Body() required GameReviewParam param,
  });

  /// 경기 호스트 리뷰 작성 API
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/reviews')
  Future<ResponseModel<GameRevieweeListResponse>> createHostReview({
    @Path() required int gameId,
    @Body() required GameReviewParam param,
  });

  /// 경기 참가자 선수 프로필 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/participations')
  Future<ResponseModel<GamePlayerListResponse>>
      getParticipationProfile({
    @Path() required int gameId,
  });

  /// 게스트 리뷰 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/participations/{participationId}/reviews/{reviewId}')
  Future<ResponseModel<GuestReviewResponse>> getGuestReview(
      {@Path() required int gameId,
      @Path() required int participationId,
      @Path() required int reviewId});

  /// 호스트 리뷰 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/reviews/{reviewId}')
  Future<ResponseModel<GuestReviewResponse>> getHostReview(
      {@Path() required int gameId, @Path() required int reviewId});
}

final gameCursorPaginationRepositoryProvider = Provider<GamePRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return GamePRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class GamePRepository extends IBaseCursorPaginationRepository<
    GameWithCourtMapResponse, GamePaginationParam> {
  factory GamePRepository(Dio dio, {String baseUrl}) = _GamePRepository;

  /// 경기 리스트 목록 조회 API
  @override
  @GET('/games/list')
  Future<ResponseModel<CursorPaginationModel<GameWithCourtMapResponse>>> paginate({
    @Queries() required CursorPaginationParam cursorPaginationParams,
    @Queries() GamePaginationParam? param,
    @Path('userId') int? path,
  });
}
