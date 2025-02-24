import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/user/model/my_payment_model.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../../game/model/game_model.dart';
import '../../game/model/v2/game/base_game_court_by_date_response.dart';
import '../../game/model/v2/payment/base_payment_result_response.dart';
import '../../review/model/v2/base_received_review_response.dart';
import '../../review/model/v2/base_written_review_response.dart';
import '../model/review_model.dart';
import '../param/user_profile_param.dart';
import '../repository/user_repository.dart';

final userHostingPProvider = StateNotifierProvider.family.autoDispose<
    UserHostingPageStateNotifier,
    BaseModel,
    PaginationStateParam<UserGameParam>>((ref, param) {
  final repository = ref.watch(userHostingPRepositoryProvider);
  return UserHostingPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class UserHostingPageStateNotifier extends PaginationProvider<
    BaseGameCourtByDateResponse, UserGameParam, UserHostingPRepository> {
  UserHostingPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}

final userParticipationPProvider = StateNotifierProvider.family.autoDispose<
    UserParticipationPageStateNotifier,
    BaseModel,
    PaginationStateParam<UserGameParam>>((ref, param) {
  final repository = ref.watch(userParticipationPRepositoryProvider);
  return UserParticipationPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class UserParticipationPageStateNotifier extends PaginationProvider<
    BaseGameCourtByDateResponse, UserGameParam, UserParticipationPRepository> {
  UserParticipationPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}

final userWrittenReviewsPProvider = StateNotifierProvider.family.autoDispose<
    UserWrittenReviewsPageStateNotifier,
    BaseModel,
    PaginationStateParam<UserReviewParam>>((ref, param) {
  final repository = ref.watch(userWrittenReviewsPRepositoryProvider);
  return UserWrittenReviewsPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class UserWrittenReviewsPageStateNotifier extends PaginationProvider<
    BaseWrittenReviewResponse, UserReviewParam, UserWrittenReviewsPRepository> {
  UserWrittenReviewsPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}

final userReceiveReviewsPProvider = StateNotifierProvider.family.autoDispose<
    UserReceiveReviewsPageStateNotifier,
    BaseModel,
    PaginationStateParam<UserReviewParam>>((ref, param) {
  final repository = ref.watch(userReceiveReviewsPRepositoryProvider);
  return UserReceiveReviewsPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class UserReceiveReviewsPageStateNotifier extends PaginationProvider<
    BaseReceivedReviewResponse, UserReviewParam, UserReceiveReviewsPRepository> {
  UserReceiveReviewsPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}

final userPaymentPProvider = StateNotifierProvider.family.autoDispose<
    UserPaymentPageStateNotifier,
    BaseModel,
    PaginationStateParam<UserPaymentParam>>((ref, param) {
  final repository = ref.watch(userPaymentPRepositoryProvider);
  return UserPaymentPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class UserPaymentPageStateNotifier extends PaginationProvider<BasePaymentResultResponse,
    UserPaymentParam, UserPaymentPRepository> {
  UserPaymentPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}
