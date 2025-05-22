import 'package:json_annotation/json_annotation.dart';

import '../../user/model/v2/base_user_response.dart';
import 'base_game_chat_notification_response.dart';

part 'game_chat_notification_response.g.dart';

@JsonSerializable()
class GameChatNotificationResponse extends BaseGameChatNotificationResponse {
  final String body;

  @JsonKey(name: 'host')
  final BaseUserResponse host;

  GameChatNotificationResponse({
    required super.id,
    required super.title,
    required super.createdAt,
    super.modifiedAt,
    required this.body,
    required this.host,
  });

  factory GameChatNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$GameChatNotificationResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GameChatNotificationResponseToJson(this);

  @override
  GameChatNotificationResponse copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? body,
    BaseUserResponse? host,
  }) {
    return GameChatNotificationResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      body: body ?? this.body,
      host: host ?? this.host,
    );
  }
}