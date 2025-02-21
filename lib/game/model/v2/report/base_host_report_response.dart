import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';
part 'base_host_report_response.g.dart';

@JsonSerializable()
class BaseHostReportResponse extends IModelWithId {
  @JsonKey(name: 'report_status')
  final ReportStatusType reportStatus; // Assuming ReportStatus is an enum

  @JsonKey(name: 'report_reason')
  final String reportReason;

  @JsonKey(name: 'reportee')
  final int reportee;

  @JsonKey(name: 'game')
  final int game;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  BaseHostReportResponse({
    required super.id,
    required this.reportStatus,
    required this.reportReason,
    required this.reportee,
    required this.game,
    required this.content,
    required this.createdAt,
  });


  factory BaseHostReportResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseHostReportResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseHostReportResponseToJson(this);

  BaseHostReportResponse copyWith({
    int? id,
    ReportStatusType? reportStatus,
    String? reportReason,
    int? reportee,
    int? game,
    String? content,
    DateTime? createdAt,
  }) {
    return BaseHostReportResponse(
      id: id ?? this.id,
      reportStatus: reportStatus ?? this.reportStatus,
      reportReason: reportReason ?? this.reportReason,
      reportee: reportee ?? this.reportee,
      game: game ?? this.game,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
