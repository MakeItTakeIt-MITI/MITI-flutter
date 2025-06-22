import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../user/model/v2/base_user_response.dart';

part 'base_post_response.g.dart';

@JsonSerializable()
class BasePostResponse extends IModelWithId {
  final PostCategoryType category;

  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;

  final String title;

  final String content;

  @JsonKey(name: 'num_of_comments')
  final int numOfComments;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final List<String> images;

  @JsonKey(name: 'liked_users')
  final List<int> likedUsers;

  final BaseUserResponse writer;

  BasePostResponse({
    required super.id,
    required this.category,
    required this.isAnonymous,
    required this.title,
    required this.content,
    required this.numOfComments,
    required this.createdAt,
    required this.images,
    required this.likedUsers,
    required this.writer,
  });

  factory BasePostResponse.fromJson(Map<String, dynamic> json) =>
      _$BasePostResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BasePostResponseToJson(this);

  BasePostResponse copyWith({
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
  }) {
    return BasePostResponse(
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
    );
  }
}