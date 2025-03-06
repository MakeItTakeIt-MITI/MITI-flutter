import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/game_model.dart';
import '../../game/param/game_param.dart';
import '../model/review_model.dart';
import '../model/v2/guest_review_list_response.dart';
import '../model/v2/guest_review_response.dart';
import '../model/v2/host_review_list_response.dart';
import '../model/v2/host_review_response.dart';

part 'review_repository.g.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return ReviewRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class ReviewRepository {
  factory ReviewRepository(Dio dio, {String baseUrl}) = _ReviewRepository;

  /// 경기 게스트 참여자 리뷰 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/participations/{participationId}/reviews')
  Future<ResponseModel<GuestReviewListResponse>> getParticipationReviewList({
    @Path() required int gameId,
    @Path() required int participationId,
  });

  /// 경기 호스트 리뷰 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/reviews')
  Future<ResponseModel<HostReviewListResponse>> getHostReviewList({
    @Path() required int gameId,
  });

  /// 받은 호스트 리뷰 상세 조회API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/received-reviews/host-reviews/{reviewId}')
  Future<ResponseModel<HostReviewResponse>> getReceivedHostReviewDetail({
    @Path() required int userId,
    @Path() required int reviewId,
  });

  /// 받은 게스트 리뷰 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/received-reviews/guest-reviews/{reviewId}')
  Future<ResponseModel<GuestReviewResponse>> getReceivedGuestReviewDetail({
    @Path() required int userId,
    @Path() required int reviewId,
  });

  /// 작성 호스트 리뷰 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/written-reviews/host-reviews/{reviewId}')
  Future<ResponseModel<HostReviewResponse>> getWrittenHostReviewDetail({
    @Path() required int userId,
    @Path() required int reviewId,
  });

  /// 작성 호스트 리뷰 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/written-reviews/guest-reviews/{reviewId}')
  Future<ResponseModel<GuestReviewResponse>> getWrittenGuestReviewDetail({
    @Path() required int userId,
    @Path() required int reviewId,
  });
}
