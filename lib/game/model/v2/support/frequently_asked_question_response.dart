import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'frequently_asked_question_response.g.dart';

@JsonSerializable()
class FrequentlyAskedQuestionResponse extends IModelWithId{

  @JsonKey(name: 'category')
  final FaqCategoryType category;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'modified_at')
  final DateTime? modifiedAt;

  FrequentlyAskedQuestionResponse({
    required super.id,
    required this.category,
    required this.title,
    required this.content,
    required this.createdAt,
    this.modifiedAt,
  });

  factory FrequentlyAskedQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$FrequentlyAskedQuestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FrequentlyAskedQuestionResponseToJson(this);

  FrequentlyAskedQuestionResponse copyWith({
    int? id,
    FaqCategoryType? category,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return FrequentlyAskedQuestionResponse(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
