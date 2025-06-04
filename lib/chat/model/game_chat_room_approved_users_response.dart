import 'package:json_annotation/json_annotation.dart';

import 'base_game_chat_room_response.dart';

part 'game_chat_room_approved_users_response.g.dart';

@JsonSerializable()
class GameChatRoomApprovedUsersResponse extends BaseGameChatRoomResponse {
  @JsonKey(name: 'is_expired')
  final bool isExpired;

  @JsonKey(name: 'approved_users')
  final List<int> approvedUsers;

  GameChatRoomApprovedUsersResponse({
    required super.id,
    required super.game,
    required super.createdAt,
    required super.expireAt,
    required this.isExpired,
    required this.approvedUsers,
  });

  factory GameChatRoomApprovedUsersResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GameChatRoomApprovedUsersResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$GameChatRoomApprovedUsersResponseToJson(this);

  @override
  GameChatRoomApprovedUsersResponse copyWith({
    int? id,
    int? game,
    DateTime? createdAt,
    DateTime? expireAt,
    bool? isExpired,
    List<int>? approvedUsers,
  }) {
    return GameChatRoomApprovedUsersResponse(
      id: id ?? this.id,
      game: game ?? this.game,
      createdAt: createdAt ?? this.createdAt,
      expireAt: expireAt ?? this.expireAt,
      isExpired: isExpired ?? this.isExpired,
      approvedUsers: approvedUsers ?? this.approvedUsers,
    );
  }
}
