import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_user_question_answer_response.g.dart';

@JsonSerializable()
class BaseUserQuestionAnswerResponse extends IModelWithId{

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'modified_at')
  final String? modifiedAt;

  BaseUserQuestionAnswerResponse({
    required super.id,
    required this.content,
    required this.createdAt,
    this.modifiedAt,
  });

  factory BaseUserQuestionAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseUserQuestionAnswerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseUserQuestionAnswerResponseToJson(this);

  BaseUserQuestionAnswerResponse copyWith({
    int? id,
    String? content,
    String? createdAt,
    String? modifiedAt,
  }) {
    return BaseUserQuestionAnswerResponse(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
