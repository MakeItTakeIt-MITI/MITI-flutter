import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

import '../../game/model/v2/notification/notification_response.dart';

part 'push_model.g.dart';

@JsonSerializable()
class PushDataModel extends BaseNotificationModel{
  @JsonKey(name: "game_id")
  final String? gameId;
  @JsonKey(name: "push_notification_id")
  final String pushId;
  final PushNotificationTopicType topic;

  PushDataModel({
    this.gameId,
    required this.pushId,
    required this.topic,
  });

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

  PushModel copyWith({
    int? id,
    PushNotificationTopicType? topic,
    String? title,
    String? body,
    PushDataModel? data,
    bool? isRead,
    String? createdAt,
  }) {
    return PushModel(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PushModel.fromJson(Map<String, dynamic> json) =>
      _$PushModelFromJson(json);
}

@JsonSerializable()
class PushDetailModel extends PushModel {
  final String status;
  final String content;
  @JsonKey(name: 'is_sent')
  final bool isSent;
  @JsonKey(name: 'modified_at')
  final String modifiedAt;
  @JsonKey(name: 'expire_at')
  final String? expireAt;

  PushDetailModel({
    required super.id,
    required super.topic,
    required this.status,
    required super.title,
    required super.body,
    required this.content,
    required super.data,
    required super.isRead,
    required this.isSent,
    required super.createdAt,
    required this.modifiedAt,
    this.expireAt,
  });

  PushDetailModel copyWith({
    int? id,
    PushNotificationTopicType? topic,
    String? status,
    String? title,
    String? body,
    String? content,
    PushDataModel? data,
    bool? isRead,
    bool? isSent,
    String? createdAt,
    String? modifiedAt,
    String? expireAt,
  }) {
    return PushDetailModel(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      title: title ?? this.title,
      body: body ?? this.body,
      content: content ?? this.content,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  factory PushDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PushDetailModelFromJson(json);
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
