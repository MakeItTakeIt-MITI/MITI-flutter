import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/user/model/my_payment_model.dart';
import 'package:miti/user/model/review_model.dart';
import 'package:miti/user/model/user_model.dart';
import 'package:miti/user/param/user_profile_param.dart';
import 'package:retrofit/http.dart';

import '../../auth/param/signup_param.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/game_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../game/model/v2/game/base_game_court_by_date_response.dart';
import '../../game/model/v2/payment/base_payment_result_response.dart';
import '../../game/model/v2/payment/payment_result_response.dart';
import '../../review/model/v2/base_received_review_response.dart';
import '../../review/model/v2/base_written_review_response.dart';
import '../model/v2/base_player_profile_response.dart';
import '../model/v2/base_user_profile_response.dart';
import '../model/v2/user_info_response.dart';
import '../model/v2/user_player_profile_response.dart';

part 'user_repository.g.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return UserRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class UserRepository {
  factory UserRepository(Dio dio, {String baseUrl}) = _UserRepository;

  /// 유저 정보 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}')
  Future<ResponseModel<UserInfoResponse>> getUserInfo(
      {@Path() required int userId});

  /// 유저 프로필 조회 API
  /// todo error
  @Headers({'token': 'true'})
  @GET('/users/{userId}/user-profile')
  Future<ResponseModel<BaseUserProfileResponse>> getUserProfileInfo(
      {@Path() required int userId});

  /// 유저 프로필 수정 API
  /// todo error
  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/user-profile')
  Future<ResponseModel<BaseUserProfileResponse>> updateUserProfileInfo(
      {@Path() required int userId});

  /// 프로필 이미지 초기화 API
  /// todo error
  @Headers({'token': 'true'})
  @PUT('/users/{userId}/user-profile')
  Future<ResponseModel<BaseUserProfileResponse>> resetProfileImage(
      {@Path() required int userId});

  /// 선수 프로필 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/player-profile')
  Future<ResponseModel<UserPlayerProfileResponse>> getPlayerInfo({
    @Path() required int userId,
  });

  /// 선수 프로필 수정 API
  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/player-profile')
  Future<ResponseModel<UserPlayerProfileResponse>> updatePlayerInfo({
    @Path() required int userId,
    @Body() required BasePlayerProfileResponse param,
  });

  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/update-profile')
  Future<ResponseModel<UserInfoModel>> updateNickname({
    @Path() required int userId,
    @Body() required UserNicknameParam param,
  });

  // @Headers({'token': 'true'})
  @PATCH('/users/{userId}/update-password')
  Future<ResponseModel<UserNicknameModel>> updatePassword({
    @Path() required int userId,
    @Body() required UserPasswordParam param,
  });

  // @Headers({'token': 'true'})
  // @GET('/users/{userId}/written-reviews/{reviewType}/{reviewId}')
  // Future<ResponseModel<MyWrittenReviewDetailModel>> getWrittenReview({
  //   @Path() required int userId,
  //   @Path() required String reviewType,
  //   @Path() required int reviewId,
  // });
  //
  // @Headers({'token': 'true'})
  // @GET('/users/{userId}/received-reviews/{reviewType}/{reviewId}')
  // Future<ResponseModel<MyReceiveReviewDetailModel>> getReceiveReview({
  //   @Path() required int userId,
  //   @Path() required String reviewType,
  //   @Path() required int reviewId,
  // });

  /// 결제 내역 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/payment-results/{paymentResultId}')
  Future<ResponseModel<PaymentResultResponse>> getPaymentResultDetail({
    @Path() required int userId,
    @Path() required int paymentResultId,
  });
}

final userParticipationPRepositoryProvider =
    Provider<UserParticipationPRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return UserParticipationPRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class UserParticipationPRepository extends IBasePaginationRepository<
    BaseGameCourtByDateResponse, UserGameParam> {
  factory UserParticipationPRepository(Dio dio, {String baseUrl}) =
      _UserParticipationPRepository;

  /// 참여 경기 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/participated-games')
  Future<ResponseModel<PaginationModel<BaseGameCourtByDateResponse>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() UserGameParam? param,
    @Path('userId') int? path,
  });
}

final userWrittenReviewsPRepositoryProvider =
    Provider<UserWrittenReviewsPRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return UserWrittenReviewsPRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class UserWrittenReviewsPRepository
    extends IBasePaginationRepository<BaseWrittenReviewResponse, UserReviewParam> {
  factory UserWrittenReviewsPRepository(Dio dio, {String baseUrl}) =
      _UserWrittenReviewsPRepository;

  /// 작성 리뷰 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/written-reviews')
  Future<ResponseModel<PaginationModel<BaseWrittenReviewResponse>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() UserReviewParam? param,
    @Path('userId') int? path,
  });
}

final userReceiveReviewsPRepositoryProvider =
    Provider<UserReceiveReviewsPRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return UserReceiveReviewsPRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class UserReceiveReviewsPRepository
    extends IBasePaginationRepository<BaseReceivedReviewResponse, UserReviewParam> {
  factory UserReceiveReviewsPRepository(Dio dio, {String baseUrl}) =
      _UserReceiveReviewsPRepository;

  /// 받은 리뷰 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/received-reviews')
  Future<ResponseModel<PaginationModel<BaseReceivedReviewResponse>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() UserReviewParam? param,
    @Path('userId') int? path,
  });
}

final userHostingPRepositoryProvider = Provider<UserHostingPRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return UserHostingPRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class UserHostingPRepository extends IBasePaginationRepository<
    BaseGameCourtByDateResponse, UserGameParam> {
  factory UserHostingPRepository(Dio dio, {String baseUrl}) =
      _UserHostingPRepository;

  /// 호스팅 경기 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/hosted-games')
  Future<ResponseModel<PaginationModel<BaseGameCourtByDateResponse>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() UserGameParam? param,
    @Path('userId') int? path,
  });
}

final userPaymentPRepositoryProvider = Provider<UserPaymentPRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return UserPaymentPRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class UserPaymentPRepository extends IBasePaginationRepository<
    BasePaymentResultResponse, UserPaymentParam> {
  factory UserPaymentPRepository(Dio dio, {String baseUrl}) =
      _UserPaymentPRepository;

  /// 결제 내역 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/payment-results')
  Future<ResponseModel<PaginationModel<BasePaymentResultResponse>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() UserPaymentParam? param,
    @Path('userId') int? path,
  });
}
