import 'package:json_annotation/json_annotation.dart';
import '../../../../common/model/model_id.dart';

part 'base_notification_response.g.dart';

@JsonSerializable()
class BaseNotificationResponse extends IModelWithId {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'modified_at')
  final String modifiedAt;

  BaseNotificationResponse({
    required super.id,
    required this.title,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory BaseNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseNotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseNotificationResponseToJson(this);

  BaseNotificationResponse copyWith({
    int? id,
    String? title,
    String? createdAt,
    String? modifiedAt,
  }) {
    return BaseNotificationResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
