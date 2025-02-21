import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

part 'phone_authentication_request_response.g.dart';

@JsonSerializable()
class PhoneAuthenticationRequestResponse {
  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'purpose')
  final PhoneAuthenticationPurposeType purpose;

  @JsonKey(name: 'authentication_token')
  final String authenticationToken;

  PhoneAuthenticationRequestResponse({
    required this.phone,
    required this.purpose,
    required this.authenticationToken,
  });

  factory PhoneAuthenticationRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$PhoneAuthenticationRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneAuthenticationRequestResponseToJson(this);

  PhoneAuthenticationRequestResponse copyWith({
    String? phone,
    PhoneAuthenticationPurposeType? purpose,
    String? authenticationToken,
  }) {
    return PhoneAuthenticationRequestResponse(
      phone: phone ?? this.phone,
      purpose: purpose ?? this.purpose,
      authenticationToken: authenticationToken ?? this.authenticationToken,
    );
  }
}
