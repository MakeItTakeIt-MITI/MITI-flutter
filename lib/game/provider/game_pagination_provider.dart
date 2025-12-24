import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/cursor_pagination_provider.dart';
import '../model/base_game_meta_response.dart';
import '../param/game_pagination_param.dart';
import '../repository/game_repository.dart';

final gamePageProvider = StateNotifierProvider.family.autoDispose<
    GamePageStateNotifier,
    BaseModel,
    PaginationStateParam<GamePaginationParam>>((ref, param) {
  final repository = ref.watch(gameCursorPaginationRepositoryProvider);
  return GamePageStateNotifier(
    repository: repository,
    cursorPageParams: const CursorPaginationParam(),
    param: param.param,
    path: param.path,
  );
});

class GamePageStateNotifier extends CursorPaginationProvider<BaseGameMetaResponse,
    GamePaginationParam, GamePRepository> {
  final searchDebounce = Debouncer(const Duration(milliseconds: 300),
      initialValue: GamePaginationParam(), checkEquality: false);

  GamePageStateNotifier({
    required super.repository,
    required super.cursorPageParams,
    super.param,
    super.path,
  }) {
    searchDebounce.values.listen((GamePaginationParam state) {
      paginate(
          cursorPaginationParams: const CursorPaginationParam(),
          forceRefetch: true,
          param: state);
    });
  }

  void updateDebounce({required GamePaginationParam param}) {
    searchDebounce.setValue(param);
  }
}
