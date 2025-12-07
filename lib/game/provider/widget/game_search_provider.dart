import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/entity_enum.dart';
import '../../param/game_pagination_param.dart';

part 'game_search_provider.g.dart';

@riverpod
class GameSearch extends _$GameSearch {
  @override
  GamePaginationParam build() {
    final gameStatus = GameStatusType.values.toList();
    gameStatus.remove(GameStatusType.canceled);

    return GamePaginationParam(gameStatus: gameStatus);
  }

  GamePaginationParam update({
    String? title,
    List<GameStatusType>? gameStatus,
    List<DistrictType>? province,
    bool isAll = false,
  }) {
    state = state.copyWith(
      search: title,
      gameStatus: gameStatus,
      province: province,
      isAll: isAll,
    );
    return state;
  }

  void toggleStatus(GameStatusType status) {
    if (state.gameStatus?.contains(status) ?? false) {
      state = state.copyWith(
        gameStatus: state.gameStatus?.where((e) => e != status).toList(),
      );
    }else{
      state = state.copyWith(
        gameStatus: [...(state.gameStatus ?? []), status],
      );
    }
  }

  void toggleProvince(DistrictType province){
    if (state.province?.contains(province) ?? false) {
      state = state.copyWith(
        province: state.province?.where((e) => e != province).toList(),
      );
    }else{
      state = state.copyWith(
        province: [...(state.province ?? []), province],
      );
    }
  }

  void deleteStatus(GameStatusType status) {
    state = state.copyWith(
      gameStatus: state.gameStatus?.where((e) => e != status).toList(),
    );
  }
}
