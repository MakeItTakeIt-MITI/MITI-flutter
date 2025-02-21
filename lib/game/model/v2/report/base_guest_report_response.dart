import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_guest_report_response.g.dart';

@JsonSerializable()
class BaseGuestReportResponse extends IModelWithId{

  @JsonKey(name: 'report_status')
  final ReportStatusType reportStatus;

  @JsonKey(name: 'report_reason')
  final int reportReason;  // Assuming ReportStatus is an enum

  @JsonKey(name: 'reportee')
  final int reportee;

  @JsonKey(name: 'participation')
  final int participation;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  BaseGuestReportResponse({
    required super.id,
    required this.reportStatus,
    required this.reportReason,
    required this.reportee,
    required this.participation,
    required this.content,
    required this.createdAt,
  });

  factory BaseGuestReportResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGuestReportResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGuestReportResponseToJson(this);

  BaseGuestReportResponse copyWith({
    int? id,
    ReportStatusType? reportStatus,
    int? reportReason,
    int? reportee,
    int? participation,
    String? content,
    DateTime? createdAt,
  }) {
    return BaseGuestReportResponse(
      id: id ?? this.id,
      reportStatus: reportStatus ?? this.reportStatus,
      reportReason: reportReason ?? this.reportReason,
      reportee: reportee ?? this.reportee,
      participation: participation ?? this.participation,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
