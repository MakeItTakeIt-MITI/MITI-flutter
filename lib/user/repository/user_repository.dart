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

  @Headers({'token': 'true'})
  @GET('/users/{userId}')
  Future<ResponseModel<UserModel>> getUserInfo({@Path() required int userId});

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

  @Headers({'token': 'true'})
  @GET('/users/{userId}/written-reviews/{reviewType}/{reviewId}')
  Future<ResponseModel<MyWrittenReviewDetailModel>> getWrittenReview({
    @Path() required int userId,
    @Path() required String reviewType,
    @Path() required int reviewId,
  });

  @Headers({'token': 'true'})
  @GET('/users/{userId}/received-reviews/{reviewType}/{reviewId}')
  Future<ResponseModel<MyReceiveReviewDetailModel>> getReceiveReview({
    @Path() required int userId,
    @Path() required String reviewType,
    @Path() required int reviewId,
  });

  @Headers({'token': 'true'})
  @GET('/users/{userId}/payment-results/{paymentResultId}')
  Future<ResponseModel<MyPaymentDetailModel>> getPaymentResultDetail({
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
abstract class UserParticipationPRepository
    extends IBasePaginationRepository<GameListByDateModel, UserGameParam> {
  factory UserParticipationPRepository(Dio dio, {String baseUrl}) =
      _UserParticipationPRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/participated-games')
  Future<ResponseModel<PaginationModel<GameListByDateModel>>> paginate({
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
    extends IBasePaginationRepository<WrittenReviewModel, UserReviewParam> {
  factory UserWrittenReviewsPRepository(Dio dio, {String baseUrl}) =
      _UserWrittenReviewsPRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/written-reviews')
  Future<ResponseModel<PaginationModel<WrittenReviewModel>>> paginate({
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
    extends IBasePaginationRepository<ReceiveReviewModel, UserReviewParam> {
  factory UserReceiveReviewsPRepository(Dio dio, {String baseUrl}) =
      _UserReceiveReviewsPRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/received-reviews')
  Future<ResponseModel<PaginationModel<ReceiveReviewModel>>> paginate({
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
abstract class UserHostingPRepository
    extends IBasePaginationRepository<GameListByDateModel, UserGameParam> {
  factory UserHostingPRepository(Dio dio, {String baseUrl}) =
      _UserHostingPRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/hosted-games')
  Future<ResponseModel<PaginationModel<GameListByDateModel>>> paginate({
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
abstract class UserPaymentPRepository
    extends IBasePaginationRepository<MyPaymentModel, UserPaymentParam> {
  factory UserPaymentPRepository(Dio dio, {String baseUrl}) =
      _UserPaymentPRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/payment-results')
  Future<ResponseModel<PaginationModel<MyPaymentModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() UserPaymentParam? param,
    @Path('userId') int? path,
  });
}
