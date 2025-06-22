import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';
import 'base_post_response.dart';

part 'post_list_response.g.dart';

@JsonSerializable()
class PostListResponse extends Base {
  @JsonKey(name: 'earliest_cursor')
  final int? earliestCursor;

  @JsonKey(name: 'latest_cursor')
  final int? latestCursor;

  @JsonKey(name: 'first_cursor')
  final int? firstCursor;

  @JsonKey(name: 'last_cursor')
  final int? lastCursor;

  final List<BasePostResponse> posts;

  PostListResponse({
    this.earliestCursor,
    this.latestCursor,
    this.firstCursor,
    this.lastCursor,
    required this.posts,
  });

  factory PostListResponse.fromJson(Map<String, dynamic> json) =>
      _$PostListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PostListResponseToJson(this);

  PostListResponse copyWith({
    int? earliestCursor,
    int? latestCursor,
    int? firstCursor,
    int? lastCursor,
    List<BasePostResponse>? posts,
  }) {
    return PostListResponse(
      earliestCursor: earliestCursor ?? this.earliestCursor,
      latestCursor: latestCursor ?? this.latestCursor,
      firstCursor: firstCursor ?? this.firstCursor,
      lastCursor: lastCursor ?? this.lastCursor,
      posts: posts ?? this.posts,
    );
  }
}