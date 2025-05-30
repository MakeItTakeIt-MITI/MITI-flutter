import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';
import '../../user/model/v2/base_user_response.dart';

part 'base_game_chat_message_response.g.dart';

@JsonSerializable()
class BaseGameChatMessageResponse extends IModelWithId {
  final String body;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'user')
  final BaseUserResponse user;

  BaseGameChatMessageResponse({
    required super.id,
    required this.body,
    required this.createdAt,
    required this.user,
  });

  factory BaseGameChatMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameChatMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameChatMessageResponseToJson(this);

  BaseGameChatMessageResponse copyWith({
    int? id,
    String? body,
    DateTime? createdAt,
    BaseUserResponse? user,
  }) {
    return BaseGameChatMessageResponse(
      id: id ?? this.id,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }


}
