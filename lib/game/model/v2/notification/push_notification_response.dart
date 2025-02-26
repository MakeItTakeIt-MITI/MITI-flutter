import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import '../../../../common/model/model_id.dart';

part 'push_notification_response.g.dart';

@JsonSerializable()
class PushNotificationResponse extends IModelWithId {
  @JsonKey(name: 'topic')
  final PushNotificationTopicType topic;

  @JsonKey(name: 'status')
  final NotificationStatusType status;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'body')
  final String body;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'data')
  final Map<String, dynamic> data;

  @JsonKey(name: 'is_read')
  final bool isRead;

  @JsonKey(name: 'is_sent')
  final bool isSent;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'modified_at')
  final String modifiedAt;

  @JsonKey(name: 'expire_at')
  final String expireAt;

  PushNotificationResponse({
    required int id,
    required this.topic,
    required this.status,
    required this.title,
    required this.body,
    required this.content,
    required this.data,
    required this.isRead,
    required this.isSent,
    required this.createdAt,
    required this.modifiedAt,
    required this.expireAt,
  }) : super(id: id);

  factory PushNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PushNotificationResponseToJson(this);

  PushNotificationResponse copyWith({
    int? id,
    PushNotificationTopicType? topic,
    NotificationStatusType? status,
    String? title,
    String? body,
    String? content,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isSent,
    String? createdAt,
    String? modifiedAt,
    String? expireAt,
  }) {
    return PushNotificationResponse(
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
      expireAt: expireAt ?? this.expireAt,
    );
  }
}
