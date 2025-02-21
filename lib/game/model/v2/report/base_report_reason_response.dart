import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_report_reason_response.g.dart';

@JsonSerializable()
class BaseReportReasonResponse extends IModelWithId {
  final String title;
  @JsonKey(name: 'brief_title')
  final String briefTitle;
  final String content;

  BaseReportReasonResponse({
    required super.id,
    required this.title,
    required this.briefTitle,
    required this.content,
  });

  factory BaseReportReasonResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseReportReasonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseReportReasonResponseToJson(this);

  BaseReportReasonResponse copyWith({
    int? id,
    String? title,
    String? briefTitle,
    String? content,
  }) {
    return BaseReportReasonResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      briefTitle: briefTitle ?? this.briefTitle,
      content: content ?? this.content,
    );
  }
}
