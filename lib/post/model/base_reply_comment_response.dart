import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';
import '../../user/model/v2/base_user_response.dart';

part 'base_reply_comment_response.g.dart';

@JsonSerializable()
class BaseReplyCommentResponse extends IModelWithId {
  final String content;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final BaseUserResponse writer;

  final List<String> images;

  @JsonKey(name: 'liked_users')
  final List<int> likedUsers;

  BaseReplyCommentResponse({
    required super.id,
    required this.content,
    required this.createdAt,
    required this.writer,
    required this.images,
    required this.likedUsers,
  });

  factory BaseReplyCommentResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseReplyCommentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseReplyCommentResponseToJson(this);

  BaseReplyCommentResponse copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    BaseUserResponse? writer,
    List<String>? images,
    List<int>? likedUsers,
  }) {
    return BaseReplyCommentResponse(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      writer: writer ?? this.writer,
      images: images ?? this.images,
      likedUsers: likedUsers ?? this.likedUsers,
    );
  }
}
