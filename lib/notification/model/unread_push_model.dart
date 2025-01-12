import 'package:json_annotation/json_annotation.dart';

part 'unread_push_model.g.dart';

@JsonSerializable()
class UnreadPushModel {
  @JsonKey(name: "num_of_unread_push_notifications")
  final int pushCnt;

  UnreadPushModel({
    required this.pushCnt,
  });

  UnreadPushModel copyWith({
    int? pushCnt,
  }) {
    return UnreadPushModel(
      pushCnt: pushCnt ?? this.pushCnt,
    );
  }

  factory UnreadPushModel.fromJson(Map<String, dynamic> json) =>
      _$UnreadPushModelFromJson(json);
}
