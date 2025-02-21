import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'user_authentication_info_response.g.dart';

@JsonSerializable()
class UserAuthenticationInfoResponse extends IModelWithId{

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'purpose')
  final SignupMethodType purpose;

  @JsonKey(name: 'password_update_token')
  final String passwordUpdateToken;

  UserAuthenticationInfoResponse({
    required super.id,
    required this.email,
    required this.phone,
    required this.purpose,
    required this.passwordUpdateToken,
  });

  factory UserAuthenticationInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$UserAuthenticationInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserAuthenticationInfoResponseToJson(this);

  UserAuthenticationInfoResponse copyWith({
    int? id,
    String? email,
    String? phone,
    SignupMethodType? purpose,
    String? passwordUpdateToken,
  }) {
    return UserAuthenticationInfoResponse(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      purpose: purpose ?? this.purpose,
      passwordUpdateToken: passwordUpdateToken ?? this.passwordUpdateToken,
    );
  }
}
