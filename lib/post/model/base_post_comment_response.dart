import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';
import '../../user/model/v2/base_user_response.dart';
import 'base_reply_comment_response.dart';

part 'base_post_comment_response.g.dart';

@JsonSerializable()
class BasePostCommentResponse extends IModelWithId {
  final String content;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final BaseUserResponse writer;

  final List<String> images;

  @JsonKey(name: 'liked_users')
  final List<int> likedUsers;

  @JsonKey(name: 'reply_comments')
  final List<BaseReplyCommentResponse> replyComments;

  BasePostCommentResponse({
    required super.id,
    required this.content,
    required this.createdAt,
    required this.writer,
    required this.images,
    required this.likedUsers,
    required this.replyComments,
  });

  factory BasePostCommentResponse.fromJson(Map<String, dynamic> json) =>
      _$BasePostCommentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BasePostCommentResponseToJson(this);

  BasePostCommentResponse copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    BaseUserResponse? writer,
    List<String>? images,
    List<int>? likedUsers,
    List<BaseReplyCommentResponse>? replyComments,
  }) {
    return BasePostCommentResponse(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      writer: writer ?? this.writer,
      images: images ?? this.images,
      likedUsers: likedUsers ?? this.likedUsers,
      replyComments: replyComments ?? this.replyComments,
    );
  }
}
