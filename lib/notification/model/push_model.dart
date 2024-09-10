import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'push_model.g.dart';

@JsonSerializable()
class PushDataModel {
  @JsonKey(name: 'game_id')
  final String gameId;

  PushDataModel({required this.gameId});

  factory PushDataModel.fromJson(Map<String, dynamic> json) =>
      _$PushDataModelFromJson(json);
}

@JsonSerializable()
class PushModel extends IModelWithId {
  final PushNotificationTopicType topic;
  final String title;
  final String body;
  final PushDataModel data;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;

  PushModel({
    required super.id,
    required this.title,
    required this.createdAt,
    required this.topic,
    required this.body,
    required this.data,
    required this.isRead,
  });

  factory PushModel.fromJson(Map<String, dynamic> json) =>
      _$PushModelFromJson(json);
}

@JsonSerializable()
class PushAllowModel {
  @JsonKey(name: 'allowed_topic')
  final List<PushNotificationTopicType> allowedTopic;

  PushAllowModel({
    required this.allowedTopic,
  });

  factory PushAllowModel.fromJson(Map<String, dynamic> json) =>
      _$PushAllowModelFromJson(json);

  Map<String, dynamic> toJson() => _$PushAllowModelToJson(this);
}
