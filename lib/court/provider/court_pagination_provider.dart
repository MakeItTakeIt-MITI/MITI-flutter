import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/court/param/court_pagination_param.dart';
import 'package:miti/court/repository/court_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/cursor_pagination_provider.dart';
import '../../game/model/v2/game/base_game_court_by_date_response.dart';
import '../model/v2/court_map_response.dart';

part 'court_pagination_provider.g.dart';

final courtPageProvider = StateNotifierProvider.family.autoDispose<
    CourtCursorPageStateNotifier,
    BaseModel,
    PaginationStateParam<CourtPaginationParam>>((ref, param) {
  final repository = ref.watch(courtCursorPaginationRepositoryProvider);
  return CourtCursorPageStateNotifier(
    repository: repository,
    cursorPageParams: const CursorPaginationParam(),
    param: param.param,
    path: param.path,
  );
});

class CourtCursorPageStateNotifier extends CursorPaginationProvider<
    CourtMapResponse, CourtPaginationParam, CourtCursorPaginationRepository> {
  final searchDebounce = Debouncer(const Duration(milliseconds: 300),
      initialValue: CourtPaginationParam(), checkEquality: false);

  CourtCursorPageStateNotifier({
    required super.repository,
    required super.cursorPageParams,
    super.param,
    super.path,
  }) {
    searchDebounce.values.listen((CourtPaginationParam state) {
      paginate(
          cursorPaginationParams: const CursorPaginationParam(),
          forceRefetch: true,
          param: state);
    });
  }

  void updateDebounce({required CourtPaginationParam param}) {
    searchDebounce.setValue(param);
  }
}

final courtGamePageProvider = StateNotifierProvider.family.autoDispose<
    CourtGamePageStateNotifier,
    BaseModel,
    PaginationStateParam<CourtPaginationParam>>((ref, param) {
  final repository = ref.watch(courtGameCursorPaginationRepositoryProvider);
  return CourtGamePageStateNotifier(
    repository: repository,
    cursorPageParams: const CursorPaginationParam(),
    param: param.param,
    path: param.path,
  );
});

class CourtGamePageStateNotifier extends CursorPaginationProvider<
    BaseGameCourtByDateResponse,
    CourtPaginationParam,
    CourtGameCursorPaginationRepository> {
  CourtGamePageStateNotifier({
    required super.repository,
    required super.cursorPageParams,
    super.param,
    super.path,
  });
}

@riverpod
Future<BaseModel> courtSinglePage(Ref ref,
    {required CourtPaginationParam param}) async {
  final repository = ref.watch(courtCursorPaginationRepositoryProvider);

  return await repository
      .paginate(
          cursorPaginationParams: const CursorPaginationParam(), param: param)
      .then<BaseModel>((value) {
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
