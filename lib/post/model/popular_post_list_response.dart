import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'popular_post_list_response.g.dart';

@JsonSerializable()
class PopularPostListResponse extends IModelWithId {
  final String title;

  @JsonKey(name: 'count_likes')
  final int countLikes;

  @JsonKey(name: 'count_comments')
  final int countComments;

  @JsonKey(name: 'count_viewers')
  final int countViewers;

  PopularPostListResponse({
    required super.id,
    required this.title,
    required this.countLikes,
    required this.countComments,
    required this.countViewers,
  });

  factory PopularPostListResponse.fromJson(Map<String, dynamic> json) =>
      _$PopularPostListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PopularPostListResponseToJson(this);

  PopularPostListResponse copyWith({
    int? id,
    String? title,
    int? countLikes,
    int? countComments,
    int? countViewers,
  }) {
    return PopularPostListResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      countLikes: countLikes ?? this.countLikes,
      countComments: countComments ?? this.countComments,
      countViewers: countViewers ?? this.countViewers,
    );
  }
}