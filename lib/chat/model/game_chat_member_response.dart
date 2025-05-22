import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';
import '../../user/model/v2/user_player_profile_response.dart';

part 'game_chat_member_response.g.dart';

@JsonSerializable()
class GameChatMemberResponse extends IModelWithId {
  @JsonKey(name: 'host')
  final UserPlayerProfileResponse host;

  @JsonKey(name: 'participants')
  final List<UserPlayerProfileResponse> participants;

  GameChatMemberResponse({
    required super.id,
    required this.host,
    required this.participants,
  });

  factory GameChatMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$GameChatMemberResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GameChatMemberResponseToJson(this);

  GameChatMemberResponse copyWith({
    int? id,
    UserPlayerProfileResponse? host,
    List<UserPlayerProfileResponse>? participants,
  }) {
    return GameChatMemberResponse(
      id: id ?? this.id,
      host: host ?? this.host,
      participants: participants ?? this.participants,
    );
  }
}
