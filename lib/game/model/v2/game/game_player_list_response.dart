import 'package:json_annotation/json_annotation.dart';

import '../../../../common/model/model_id.dart';
import '../../../../user/model/v2/private_participation_guest_player_response.dart';
import '../../../../user/model/v2/private_user_guest_player_response.dart';
import '../../../../user/model/v2/private_user_host_player_response.dart';

part 'game_player_list_response.g.dart';

@JsonSerializable()
class GamePlayerListResponse extends Base {
  final PrivateUserHostPlayerResponse host;

  final List<PrivateParticipationGuestPlayerResponse> participants;

  GamePlayerListResponse({
    required this.host,
    required this.participants,
  });

  factory GamePlayerListResponse.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GamePlayerListResponseToJson(this);

  GamePlayerListResponse copyWith({
    PrivateUserHostPlayerResponse? host,
    List<PrivateParticipationGuestPlayerResponse>? participants,
  }) {
    return GamePlayerListResponse(
      host: host ?? this.host,
      participants: participants ?? this.participants,
    );
  }
}
