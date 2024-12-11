import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

part 'notice_model.g.dart';

@JsonSerializable()
class NoticeModel extends IModelWithId {
  final String title;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'modified_at')
  final String modifiedAt;

  NoticeModel({
    required super.id,
    required this.title,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);
}

@JsonSerializable(
  genericArgumentFactories: true,
)
class NoticeDetailModel<T> extends NoticeModel {
  final String content;
  final T data;

  NoticeDetailModel({
    required super.id,
    required super.title,
    required this.content,
    required this.data,
    required super.createdAt,
    required super.modifiedAt,
  });

  factory NoticeDetailModel.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return _$NoticeDetailModelFromJson(json, fromJsonT);
  }
}
