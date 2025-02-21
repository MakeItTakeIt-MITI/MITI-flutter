import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_user_question_response.g.dart';

@JsonSerializable()
class BaseUserQuestionResponse extends IModelWithId {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'num_of_answers')
  final int numOfAnswers;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'modified_at')
  final String? modifiedAt;

  BaseUserQuestionResponse({
    required super.id,
    required this.title,
    required this.numOfAnswers,
    required this.createdAt,
    this.modifiedAt,
  });

  factory BaseUserQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseUserQuestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseUserQuestionResponseToJson(this);

  BaseUserQuestionResponse copyWith({
    int? id,
    String? title,
    int? numOfAnswers,
    String? createdAt,
    String? modifiedAt,
  }) {
    return BaseUserQuestionResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      numOfAnswers: numOfAnswers ?? this.numOfAnswers,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
