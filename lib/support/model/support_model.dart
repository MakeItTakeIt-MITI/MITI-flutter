import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'support_model.g.dart';

@JsonSerializable()
class SupportModel extends IModelWithId {
  final String title;
  final int num_of_answers;
  final DateTime created_at;
  final DateTime modified_at;

  SupportModel({
    required super.id,
    required this.title,
    required this.num_of_answers,
    required this.created_at,
    required this.modified_at,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) =>
      _$SupportModelFromJson(json);
}

@JsonSerializable()
class QuestionModel extends SupportModel {
  final String content;
  final List<AnswerModel> answers;
  final int user;

  QuestionModel({
    required super.id,
    required super.title,
    required super.num_of_answers,
    required super.created_at,
    required super.modified_at,
    required this.answers,
    required this.user,
    required this.content,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}

@JsonSerializable()
class AnswerModel extends IModelWithId {
  final String content;
  final DateTime created_at;
  final DateTime modified_at;
  final DateTime? deleted_at;
  final int question;

  AnswerModel({
    required super.id,
    required this.content,
    required this.created_at,
    required this.modified_at,
    required this.deleted_at,
    required this.question,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);
}

@JsonSerializable()
class FAQModel extends IModelWithId {
  final String title;
  final String content;
  final DateTime created_at;
  final DateTime modified_at;

  FAQModel({
    required super.id,
    required this.title,
    required this.created_at,
    required this.modified_at,
    required this.content,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) =>
      _$FAQModelFromJson(json);
}
