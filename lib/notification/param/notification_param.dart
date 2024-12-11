import 'package:json_annotation/json_annotation.dart';

import '../../common/param/pagination_param.dart';

part 'notification_param.g.dart';
@JsonSerializable()
class NotificationParam extends DefaultParam {


  NotificationParam();

  @override
  List<Object?> get props => [];

  Map<String, dynamic> toJson() => _$NotificationParamToJson(this);
}
