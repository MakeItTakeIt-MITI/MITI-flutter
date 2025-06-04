import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/court/param/court_pagination_param.dart';
import 'package:miti/court/repository/court_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../../game/model/game_model.dart';
import '../../game/model/v2/game/base_game_court_by_date_response.dart';
import '../../user/provider/user_pagination_provider.dart';
import '../../user/repository/user_repository.dart';
import '../model/court_model.dart';
import '../model/v2/court_map_response.dart';
part 'court_pagination_provider.g.dart';

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

class CourtPageStateNotifier extends PaginationProvider<CourtMapResponse,
    CourtPaginationParam, CourtPaginationRepository> {
  final searchDebounce = Debouncer(const Duration(milliseconds: 300),
      initialValue: CourtPaginationParam(), checkEquality: false);

  CourtPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  }) {
    searchDebounce.values.listen((CourtPaginationParam state) {
      paginate(
          paginationParams: const PaginationParam(page: 1),
          forceRefetch: true,
          param: state);
    });
  }

  void updateDebounce({required CourtPaginationParam param}){
    searchDebounce.setValue(param);
  }
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

class CourtGamePageStateNotifier extends PaginationProvider<BaseGameCourtByDateResponse,
    CourtPaginationParam, CourtGamePaginationRepository> {
  CourtGamePageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}



@riverpod
Future<BaseModel> courtSinglePage(CourtSinglePageRef ref,
    {required CourtPaginationParam param}) async {
  final repository = ref.watch(courtPaginationRepositoryProvider);

  return await repository
      .paginate(
      paginationParams: const PaginationParam(page: 1),
      param: param)
      .then<BaseModel>((value) {
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}