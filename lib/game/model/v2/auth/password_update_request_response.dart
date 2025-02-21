import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'password_update_request_response.g.dart';

@JsonSerializable()
class PasswordUpdateRequestResponse extends IModelWithId{

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'purpose')
  final SignupMethodType purpose;

  @JsonKey(name: 'password_update_token')
  final String passwordUpdateToken;

  PasswordUpdateRequestResponse({
    required super.id,
    required this.phone,
    required this.purpose,
    required this.passwordUpdateToken,
  });

  factory PasswordUpdateRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$PasswordUpdateRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordUpdateRequestResponseToJson(this);

  PasswordUpdateRequestResponse copyWith({
    int? id,
    String? phone,
    SignupMethodType? purpose,
    String? passwordUpdateToken,
  }) {
    return PasswordUpdateRequestResponse(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      purpose: purpose ?? this.purpose,
      passwordUpdateToken: passwordUpdateToken ?? this.passwordUpdateToken,
    );
  }
}
