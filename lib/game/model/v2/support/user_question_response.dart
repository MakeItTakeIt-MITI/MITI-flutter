import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';
import 'base_user_question_answer_response.dart';  // Import the answer response class

part 'user_question_response.g.dart';

@JsonSerializable()
class UserQuestionResponse extends IModelWithId {

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'modified_at')
  final String? modifiedAt;

  @JsonKey(name: 'num_of_answers')
  final int numOfAnswers;

  @JsonKey(name: 'answers')
  final List<BaseUserQuestionAnswerResponse> answers;

  UserQuestionResponse({
    required super.id,
    required this.title,
    required this.createdAt,
    this.modifiedAt,
    required this.numOfAnswers,
    required this.answers,
  });

  factory UserQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$UserQuestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserQuestionResponseToJson(this);

  UserQuestionResponse copyWith({
    int? id,
    String? title,
    String? createdAt,
    String? modifiedAt,
    int? numOfAnswers,
    List<BaseUserQuestionAnswerResponse>? answers,
  }) {
    return UserQuestionResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      numOfAnswers: numOfAnswers ?? this.numOfAnswers,
      answers: answers ?? this.answers,
    );
  }
}
