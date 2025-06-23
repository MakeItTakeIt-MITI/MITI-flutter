import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

part 'post_form_param.g.dart';

@JsonSerializable()
class PostFormParam extends Equatable {
  final PostCategoryType category;
  final String title;
  final String content;
  final List<String> images;
  @JsonKey(name: "is_anonymous")
  final bool isAnonymous;

  const PostFormParam({
    required this.title,
    required this.content,
    required this.category,
    required this.images,
    required this.isAnonymous,
  });

  PostFormParam copyWith({
    PostCategoryType? category,
    String? title,
    String? content,
    List<String>? images,
    bool? isAnonymous,
  }) {
    return PostFormParam(
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  Map<String, dynamic> toJson() => _$PostFormParamToJson(this);

  factory PostFormParam.fromJson(Map<String, dynamic> json) =>
      _$PostFormParamFromJson(json);

  @override
  List<Object?> get props => [
        category,
        title,
        content,
        images,
        isAnonymous,
      ];

  @override
  bool? get stringify => true;
}
