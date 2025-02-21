import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../review/model/v2/base_host_rating_response.dart';
import 'base_user_response.dart';

part 'user_host_rating_response.g.dart';

@JsonSerializable()
class UserHostRatingResponse extends BaseUserResponse {
  @JsonKey(name: 'host_rating')
  final BaseHostRatingResponse hostRating; // 호스트 평점

  UserHostRatingResponse({
    super.id,
    required super.nickname,
    required super.profileImageUrl,
    required this.hostRating,
  });

  factory UserHostRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$UserHostRatingResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserHostRatingResponseToJson(this);

  @override
  UserHostRatingResponse copyWith({
    int? id,
    String? nickname,
    String? profileImageUrl,
    BaseHostRatingResponse? hostRating,
  }) {
    return UserHostRatingResponse(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      hostRating: hostRating ?? this.hostRating,
    );
  }
}
