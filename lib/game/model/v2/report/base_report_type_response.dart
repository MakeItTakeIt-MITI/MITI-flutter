import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';
import 'base_report_reason_response.dart'; // Assuming BaseReportReasonResponse is in this path

part 'base_report_type_response.g.dart';

@JsonSerializable()
class BaseReportTypeResponse extends IModelWithId {
  @JsonKey(name: 'report_type')
  final ReportCategoryType reportType;

  @JsonKey(name: 'report_reasons')
  final List<BaseReportReasonResponse> reportReasons;

  BaseReportTypeResponse({
    required super.id,
    required this.reportType,
    required this.reportReasons,
  });

  factory BaseReportTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseReportTypeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseReportTypeResponseToJson(this);

  BaseReportTypeResponse copyWith({
    int? id,
    ReportCategoryType? reportType,
    List<BaseReportReasonResponse>? reportReasons,
  }) {
    return BaseReportTypeResponse(
      id: id ?? this.id,
      reportType: reportType ?? this.reportType,
      reportReasons: reportReasons ?? this.reportReasons,
    );
  }
}
