import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/entity_enum.dart';

part 'game_status_filter_provider.g.dart';

@riverpod
class GameStatusFilter extends _$GameStatusFilter {
  @override
  List<GameStatusType> build() {
    // 초기 상태: 모든 enum 값들을 포함
    return GameStatusType.values;
  }

  // 개별 상태 토글
  void toggleStatus(GameStatusType status) {
    if (state.contains(status)) {
      state = state.where((element) => element != status).toList();
    } else {
      state = [...state, status];
    }
  }

  // 모든 상태 선택
  void selectAll() {
    state = GameStatusType.values;
  }

  // 모든 상태 해제
  void clearAll() {
    state = [];
  }

  // 특정 상태들만 선택
  void setSelectedStatuses(List<GameStatusType> statuses) {
    state = statuses;
  }

  // 특정 상태가 선택되어 있는지 확인
  bool isSelected(GameStatusType status) {
    return state.contains(status);
  }

  // 모든 상태가 선택되어 있는지 확인
  bool get isAllSelected => state.length == GameStatusType.values.length;

  // 아무것도 선택되어 있지 않은지 확인
  bool get isEmpty => state.isEmpty;
}
