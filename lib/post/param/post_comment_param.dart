import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

part 'post_comment_param.g.dart';

@JsonSerializable()
class PostCommentParam extends Equatable {
  final String content;
  final List<String> images;

  const PostCommentParam({
    required this.content,
    required this.images,
  });

  PostCommentParam copyWith({
    String? content,
    List<String>? images,
  }) {
    return PostCommentParam(
      content: content ?? this.content,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toJson() => _$PostCommentParamToJson(this);

  factory PostCommentParam.fromJson(Map<String, dynamic> json) =>
      _$PostCommentParamFromJson(json);

  @override
  List<Object?> get props => [
        content,
        images,
      ];

  @override
  bool? get stringify => true;
}
