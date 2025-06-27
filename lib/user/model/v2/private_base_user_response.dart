import 'package:json_annotation/json_annotation.dart';

import 'base_user_response.dart';

part 'private_base_user_response.g.dart';

@JsonSerializable()
class PrivateBaseUserResponse extends BaseUserResponse {
  final String name;

  PrivateBaseUserResponse({
    super.id,
    required this.name,
    required super.nickname,
    required super.profileImageUrl,
  });

  factory PrivateBaseUserResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivateBaseUserResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrivateBaseUserResponseToJson(this);

  @override
  PrivateBaseUserResponse copyWith({
    int? id,
    String? name,
    String? nickname,
    String? profileImageUrl,
  }) {
    return PrivateBaseUserResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}