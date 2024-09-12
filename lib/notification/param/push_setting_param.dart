import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/param/pagination_param.dart';

part 'push_setting_param.g.dart';

@JsonSerializable()
class PushSettingParam extends DefaultParam {
  final PushNotificationTopicType topic;

  PushSettingParam({required this.topic});

  @override
  List<Object?> get props => [topic];

  Map<String, dynamic> toJson() => _$PushSettingParamToJson(this);
}
