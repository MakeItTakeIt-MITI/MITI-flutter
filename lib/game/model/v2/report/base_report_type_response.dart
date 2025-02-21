import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';
import 'base_report_reason_response.dart'; // Assuming BaseReportReasonResponse is in this path

part 'base_report_type_response.g.dart';

@JsonSerializable()
class BaseReportTypeResponse extends IModelWithId{
  @JsonKey(name: 'report_type')
  final String reportType;

  @JsonKey(name: 'report_reason')
  final List<BaseReportReasonResponse> reportReason;

  BaseReportTypeResponse({
    required super.id,
    required this.reportType,
    required this.reportReason,
  });

  factory BaseReportTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseReportTypeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseReportTypeResponseToJson(this);

  BaseReportTypeResponse copyWith({
    int? id,
    String? reportType,
    List<BaseReportReasonResponse>? reportReason,
  }) {
    return BaseReportTypeResponse(
      id: id ?? this.id,
      reportType: reportType ?? this.reportType,
      reportReason: reportReason ?? this.reportReason,
    );
  }
}
