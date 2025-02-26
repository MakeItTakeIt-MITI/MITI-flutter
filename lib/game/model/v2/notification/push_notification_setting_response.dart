import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

part 'push_notification_setting_response.g.dart';

@JsonSerializable()
class PushNotificationSettingResponse {
  @JsonKey(name: 'allowed_topic')
  final List<PushNotificationTopicType> allowedTopic;

  PushNotificationSettingResponse({
    required this.allowedTopic,
  });

  factory PushNotificationSettingResponse.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationSettingResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PushNotificationSettingResponseToJson(this);

  PushNotificationSettingResponse copyWith({
    List<PushNotificationTopicType>? allowedTopic,
  }) {
    return PushNotificationSettingResponse(
      allowedTopic: allowedTopic ?? this.allowedTopic,
    );
  }
}
