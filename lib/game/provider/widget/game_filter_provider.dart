import 'package:intl/intl.dart';
import 'package:miti/game/param/game_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/entity_enum.dart';

part 'game_filter_provider.g.dart';

enum FilterType { date, time, status, province }

@Riverpod()
class GameFilter extends _$GameFilter {
  @override
  GameListParam build({required String routeName}) {
    return _init();
  }

  void update({
    String? startdate,
    String? starttime,
    List<GameStatusType>? gameStatus,
    List<DistrictType>? province,
  }) {
    state = state.copyWith(
      startdate: startdate ?? state.startdate,
      starttime: starttime ?? state.starttime,
      gameStatus: gameStatus ?? state.gameStatus,
      province: province ?? state.province,
    );
  }

  GameListParam _init() {
    final now = DateTime.now();
    final df = DateFormat('yyyy-MM-dd');
    final startDate = df.format(now);
    const hour = '00';
    const min = '00';
    final gameStatus = GameStatusType.values
        .where((status) => status != GameStatusType.canceled)
        .toList();



    return GameListParam(
        startdate: startDate,
        starttime: '$hour:$min',
        gameStatus: gameStatus,
        province: DistrictType.values.toList());
  }

  void rollback(GameListParam filter) {
    state = filter;
  }

  void clear() {
    state = _init();
  }

  void addProvince(DistrictType pro) {
    state.province.add(pro);
    final province = state.province.toList();
    state = state.copyWith(province: province);
  }

  void deleteProvince(DistrictType pro) {
    state.province.removeWhere((s) => s.name == pro.name);
    final province = state.province.toList();
    state = state.copyWith(province: province);
  }

  void deleteStatus(GameStatusType status) {
    state.gameStatus.removeWhere((s) => s.value == status.value);
    final gameStatus = state.gameStatus.toList();
    state = state.copyWith(gameStatus: gameStatus);
  }

  void addStatus(GameStatusType status) {
    state.gameStatus.add(status);
    final gameStatus = state.gameStatus.toList();

    state = state.copyWith(gameStatus: gameStatus);
  }

  void initStatus(GameStatusType status) {
    state = state.copyWith(gameStatus: [status]);
  }

  void removeFilter(FilterType type) {
    final now = DateTime.now();
    final df = DateFormat('yyyy-MM-dd');
    final startDate = df.format(now);
    final hour = DateTime.now().hour.toString().padLeft(2, '0');
    final min = ((DateTime.now().minute ~/ 10) * 10).toString().padLeft(2, '0');
    switch (type) {
      case FilterType.date:
        state = GameListParam(
            startdate: startDate,
            starttime: state.starttime,
            gameStatus: state.gameStatus,
            province: state.province);
        break;
      case FilterType.time:
        state = GameListParam(
            startdate: state.startdate,
            starttime: '$hour:$min',
            gameStatus: state.gameStatus,
            province: state.province);
        break;
      case FilterType.status:
        state = _init();
        break;
      case FilterType.province:
        state = _init();
        break;
    }
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
}
