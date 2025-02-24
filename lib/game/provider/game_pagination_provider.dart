import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../model/v2/game/game_with_court_map_response.dart';
import '../param/game_pagination_param.dart';
import '../repository/game_repository.dart';

final gamePageProvider = StateNotifierProvider.family.autoDispose<
    GamePageStateNotifier,
    BaseModel,
    PaginationStateParam<GamePaginationParam>>((ref, param) {
  final repository = ref.watch(gamePaginationRepositoryProvider);
  return GamePageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class GamePageStateNotifier extends PaginationProvider<GameWithCourtMapResponse,
    GamePaginationParam, GamePRepository> {
  final searchDebounce = Debouncer(const Duration(milliseconds: 300),
      initialValue: GamePaginationParam(), checkEquality: false);

  GamePageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  }) {
    searchDebounce.values.listen((GamePaginationParam state) {
      paginate(
          paginationParams: const PaginationParam(page: 1),
          forceRefetch: true,
          param: state);
    });
  }

  void updateDebounce({required GamePaginationParam param}) {
    searchDebounce.setValue(param);
  }
}
