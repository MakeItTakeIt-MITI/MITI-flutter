import 'package:miti/game/param/game_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_form_provider.g.dart';

@riverpod
class GameForm extends _$GameForm {
  @override
  GameCreateParam build() {
    return const GameCreateParam(
        title: '',
        startdate: '',
        starttime: '',
        enddate: '',
        endtime: '',
        min_invitation: '',
        max_invitation: '',
        info: '',
        fee: '',
        court: '');
  }

  void update({
    String? title,
    String? startdate,
    String? starttime,
    String? enddate,
    String? endtime,
    String? min_invitation,
    String? max_invitation,
    String? info,
    String? fee,
    String? court,
  }) {
    state = state.copyWith(
      title: title,
      startdate: startdate,
      starttime: starttime,
      enddate: enddate,
      endtime: endtime,
      min_invitation: min_invitation,
      max_invitation: max_invitation,
      info: info,
      fee: fee,
      court: court,
    );
  }
}
