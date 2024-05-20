import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../../game/model/game_model.dart';
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

class UserHostingPageStateNotifier extends PaginationProvider<GameListByDateModel,
    UserGameParam, UserHostingPRepository> {
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

class UserParticipationPageStateNotifier extends PaginationProvider<GameListByDateModel,
    UserGameParam, UserParticipationPRepository> {
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

class UserWrittenReviewsPageStateNotifier extends PaginationProvider<WrittenReviewModel,
    UserReviewParam, UserWrittenReviewsPRepository> {
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

class UserReceiveReviewsPageStateNotifier extends PaginationProvider<ReceiveReviewModel,
    UserReviewParam, UserReceiveReviewsPRepository> {
  UserReceiveReviewsPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}
