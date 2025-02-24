import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/entity_enum.dart';
import '../../param/game_pagination_param.dart';

part 'game_search_provider.g.dart';

@riverpod
class GameSearch extends _$GameSearch {
  @override
  GamePaginationParam build() {
    return GamePaginationParam();
  }

  GamePaginationParam update({
    String? title,
    DistrictType? district,
    bool isAll = false,
  }) {
    state = state.copyWith(
      title: title,
      district: district,
      isAll: isAll,
    );
    return state;
  }
}
