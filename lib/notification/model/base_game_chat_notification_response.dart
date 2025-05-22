import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'base_game_chat_notification_response.g.dart';

@JsonSerializable()
class BaseGameChatNotificationResponse extends IModelWithId {
  final String title;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'modified_at')
  final DateTime? modifiedAt;

  BaseGameChatNotificationResponse({
    required super.id,
    required this.title,
    required this.createdAt,
    this.modifiedAt,
  });

  factory BaseGameChatNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameChatNotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameChatNotificationResponseToJson(this);

  BaseGameChatNotificationResponse copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return BaseGameChatNotificationResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}