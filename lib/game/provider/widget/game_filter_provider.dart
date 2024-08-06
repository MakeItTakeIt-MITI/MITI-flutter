import 'dart:developer';

import 'package:miti/game/param/game_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/entity_enum.dart';

part 'game_filter_provider.g.dart';

@Riverpod()
class GameFilter extends _$GameFilter {
  @override
  GameListParam build() {
    return const GameListParam();
  }

  void update({
    String? startdate,
    String? starttime,
    List<GameStatus>? gameStatus,}
  ) {
    state = state.copyWith(
      startdate: startdate ?? state.startdate,
      starttime: starttime ?? state.starttime,
      gameStatus: gameStatus ?? state.gameStatus,
    );
  }
  void clear(){
    state = const GameListParam();
  }
}
