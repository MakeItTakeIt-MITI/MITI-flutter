import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../user/model/v2/base_user_response.dart';
import 'base_post_response.dart';

part 'post_response.g.dart';

@JsonSerializable()
class PostResponse extends BasePostResponse {
  @JsonKey(name: 'is_writer')
  final bool isWriter;

  PostResponse({
    required super.id,
    required super.category,
    required super.isAnonymous,
    required super.title,
    required super.content,
    required super.numOfComments,
    required super.createdAt,
    required super.images,
    required super.likedUsers,
    required super.writer,
    required this.isWriter,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) =>
      _$PostResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PostResponseToJson(this);

  @override
  PostResponse copyWith({
    int? id,
    PostCategoryType? category,
    bool? isAnonymous,
    String? title,
    String? content,
    int? numOfComments,
    DateTime? createdAt,
    List<String>? images,
    List<int>? likedUsers,
    BaseUserResponse? writer,
    bool? isWriter,
  }) {
    return PostResponse(
      id: id ?? this.id,
      category: category ?? this.category,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      title: title ?? this.title,
      content: content ?? this.content,
      numOfComments: numOfComments ?? this.numOfComments,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
      likedUsers: likedUsers ?? this.likedUsers,
      writer: writer ?? this.writer,
      isWriter: isWriter ?? this.isWriter,
    );
  }
}
