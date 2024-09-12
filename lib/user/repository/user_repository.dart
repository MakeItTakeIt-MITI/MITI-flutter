import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
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
  @DELETE('/users/{userId}')
  Future<ResponseModel<UserModel>> deleteUser({@Path() required int userId});

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
}

final userParticipationPRepositoryProvider =
    Provider<UserParticipationPRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserParticipationPRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class UserParticipationPRepository
    extends IBasePaginationRepository<GameListByDateModel, UserGameParam> {
  factory UserParticipationPRepository(Dio dio) = _UserParticipationPRepository;

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
  final dio = ref.watch(dioProvider);
  return UserWrittenReviewsPRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class UserWrittenReviewsPRepository
    extends IBasePaginationRepository<WrittenReviewModel, UserReviewParam> {
  factory UserWrittenReviewsPRepository(Dio dio) =
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
  final dio = ref.watch(dioProvider);
  return UserReceiveReviewsPRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class UserReceiveReviewsPRepository
    extends IBasePaginationRepository<ReceiveReviewModel, UserReviewParam> {
  factory UserReceiveReviewsPRepository(Dio dio) =
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
  final dio = ref.watch(dioProvider);
  return UserHostingPRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class UserHostingPRepository
    extends IBasePaginationRepository<GameListByDateModel, UserGameParam> {
  factory UserHostingPRepository(Dio dio) = _UserHostingPRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/hosted-games')
  Future<ResponseModel<PaginationModel<GameListByDateModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() UserGameParam? param,
    @Path('userId') int? path,
  });
}
