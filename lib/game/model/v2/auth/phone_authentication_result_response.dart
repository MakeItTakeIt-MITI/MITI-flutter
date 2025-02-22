import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../../../auth/model/find_info_model.dart';

part 'phone_authentication_result_response.g.dart';

@JsonSerializable()
class PhoneAuthenticationResultResponse extends VerifyBaseModel {
  @JsonKey(name: 'is_authenticated')
  final bool isAuthenticated;

  @JsonKey(name: 'signup_token')
  final String signupToken;

  PhoneAuthenticationResultResponse({
    required super.phone,
    required super.purpose,
    required this.isAuthenticated,
    required this.signupToken,
  });

  factory PhoneAuthenticationResultResponse.fromJson(
          Map<String, dynamic> json) =>
      _$PhoneAuthenticationResultResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PhoneAuthenticationResultResponseToJson(this);

  PhoneAuthenticationResultResponse copyWith({
    String? phone,
    PhoneAuthenticationPurposeType? purpose,
    bool? isAuthenticated,
    String? signupToken,
  }) {
    return PhoneAuthenticationResultResponse(
      phone: phone ?? this.phone,
      purpose: purpose ?? this.purpose,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      signupToken: signupToken ?? this.signupToken,
    );
  }
}
