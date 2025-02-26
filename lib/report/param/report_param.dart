import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';

part 'report_param.g.dart';

@JsonSerializable()
class ReportParam extends Equatable {
  @JsonKey(name: "report_reason")
  final int reportReason;
  final String content;

  const ReportParam({
    required this.reportReason,
    required this.content,
  });

  ReportParam copyWith({
    int? reportReason,
    String? content,
  }) {
    return ReportParam(
      reportReason: reportReason ?? this.reportReason,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() => _$ReportParamToJson(this);

  factory ReportParam.fromJson(Map<String, dynamic> json) =>
      _$ReportParamFromJson(json);

  @override
  List<Object?> get props => [reportReason, content];

  @override
  bool? get stringify => true;
}
