import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';

part 'report_param.g.dart';

@JsonSerializable()
class ReportParam extends Equatable {
  final HostReportCategoryType category;
  final String content;

  const ReportParam({
    required this.category,
    required this.content,
  });

  ReportParam copyWith({
    HostReportCategoryType? category,
    String? content,
  }) {
    return ReportParam(
      category: category ?? this.category,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() => _$ReportParamToJson(this);

  factory ReportParam.fromJson(Map<String, dynamic> json) =>
      _$ReportParamFromJson(json);

  @override
  List<Object?> get props => [category, content];

  @override
  bool? get stringify => true;
}
