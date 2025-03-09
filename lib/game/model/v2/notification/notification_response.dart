import 'package:json_annotation/json_annotation.dart';
import 'base_notification_response.dart';

part 'notification_response.g.dart';

abstract class BaseNotificationModel{

}


@JsonSerializable(includeIfNull: true)
class NotificationDataModel extends BaseNotificationModel {
  @JsonKey(name: "notification_id")
  final String? notificationId;

  NotificationDataModel({
     this.notificationId,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataModelFromJson(json);
}

@JsonSerializable()
class NotificationResponse extends BaseNotificationResponse {
  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'data')
  final NotificationDataModel data;

  NotificationResponse({
    required super.id,
    required super.title,
    required this.content,
    required this.data,
    required super.createdAt,
    required super.modifiedAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);

  @override
  NotificationResponse copyWith({
    int? id,
    String? title,
    String? content,
    NotificationDataModel? data,
    String? createdAt,
    String? modifiedAt,
  }) {
    return NotificationResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
