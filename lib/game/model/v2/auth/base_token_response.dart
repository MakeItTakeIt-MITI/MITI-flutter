import 'package:json_annotation/json_annotation.dart';

part 'base_token_response.g.dart';

@JsonSerializable()
class BaseTokenResponse {
  @JsonKey(name: 'access')
  final String access;

  @JsonKey(name: 'refresh')
  final String refresh;

  @JsonKey(name: 'type')
  final String type;

  BaseTokenResponse({
    required this.access,
    required this.refresh,
    required this.type,
  });

  factory BaseTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseTokenResponseToJson(this);

  BaseTokenResponse copyWith({
    String? access,
    String? refresh,
    String? type,
  }) {
    return BaseTokenResponse(
      access: access ?? this.access,
      refresh: refresh ?? this.refresh,
      type: type ?? this.type,
    );
  }
}
