import 'package:json_annotation/json_annotation.dart';

import '../../../../common/model/entity_enum.dart';
import '../../../../common/model/model_id.dart';
import '../../../../notification/model/push_model.dart';

part 'base_push_notification_response.g.dart';

@JsonSerializable()
class BasePushNotificationResponse extends IModelWithId {
  @JsonKey(name: 'topic')
  final PushNotificationTopicType topic;

  @JsonKey(name: 'is_read')
  final bool isRead;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'body')
  final String body;

  @JsonKey(name: 'data')
  final PushDataModel data;

  @JsonKey(name: 'created_at')
  final String createdAt;

  BasePushNotificationResponse({
    required super.id,
    required this.topic,
    required this.isRead,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
  });

  factory BasePushNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$BasePushNotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BasePushNotificationResponseToJson(this);

  BasePushNotificationResponse copyWith({
    int? id,
    PushNotificationTopicType? topic,
    bool? isRead,
    String? title,
    String? body,
    PushDataModel? data,
    String? createdAt,
  }) {
    return BasePushNotificationResponse(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      isRead: isRead ?? this.isRead,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
