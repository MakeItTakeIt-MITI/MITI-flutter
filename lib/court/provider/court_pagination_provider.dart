import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/court/param/court_pagination_param.dart';
import 'package:miti/court/repository/court_repository.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../../game/model/game_model.dart';
import '../../user/provider/user_pagination_provider.dart';
import '../../user/repository/user_repository.dart';
import '../model/court_model.dart';

final courtPageProvider = StateNotifierProvider.family.autoDispose<
    CourtPageStateNotifier,
    BaseModel,
    PaginationStateParam<CourtPaginationParam>>((ref, param) {
  final repository = ref.watch(courtPaginationRepositoryProvider);
  return CourtPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class CourtPageStateNotifier extends PaginationProvider<CourtSearchModel,
    CourtPaginationParam, CourtPaginationRepository> {
  CourtPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}

final courtGamePageProvider = StateNotifierProvider.family.autoDispose<
    CourtGamePageStateNotifier,
    BaseModel,
    PaginationStateParam<CourtPaginationParam>>((ref, param) {
  final repository = ref.watch(courtGamePaginationRepositoryProvider);
  return CourtGamePageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class CourtGamePageStateNotifier extends PaginationProvider<GameListByDateModel,
    CourtPaginationParam, CourtGamePaginationRepository> {
  CourtGamePageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}