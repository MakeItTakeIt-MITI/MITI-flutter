import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel extends IModelWithId {
  final ReportType category;
  final ReportSubType subcategory;

  ReportModel({
    required super.id,
    required this.category,
    required this.subcategory,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);
}


@JsonSerializable()
class ReportDetailModel extends ReportModel {
  final String content;

  ReportDetailModel({
    required super.id,
    required super.category,
    required super.subcategory,
    required this.content,
  });

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ReportDetailModelFromJson(json);
}

