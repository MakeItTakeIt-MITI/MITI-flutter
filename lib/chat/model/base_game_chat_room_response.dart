import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'base_game_chat_room_response.g.dart';

@JsonSerializable()
class BaseGameChatRoomResponse extends IModelWithId {
  final int game;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'expire_at')
  final DateTime expireAt;

  BaseGameChatRoomResponse({
    required super.id,
    required this.game,
    required this.createdAt,
    required this.expireAt,
  });

  factory BaseGameChatRoomResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameChatRoomResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameChatRoomResponseToJson(this);

  BaseGameChatRoomResponse copyWith({
    int? id,
    int? game,
    DateTime? createdAt,
    DateTime? expireAt,
  }) {
    return BaseGameChatRoomResponse(
      id: id ?? this.id,
      game: game ?? this.game,
      createdAt: createdAt ?? this.createdAt,
      expireAt: expireAt ?? this.expireAt,
    );
  }
}
