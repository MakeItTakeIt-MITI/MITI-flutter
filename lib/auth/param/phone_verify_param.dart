import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';

part 'phone_verify_param.g.dart';

@JsonSerializable()
class SendCodeParam {
  final String phone;
  final PhoneAuthenticationPurposeType purpose;

  SendCodeParam({
    required this.phone,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => _$SendCodeParamToJson(this);
}

@JsonSerializable()
class PhoneVerifyParam {
  final String code;
  final PhoneAuthenticationPurposeType purpose;
  final String authentication_token;

  PhoneVerifyParam({
    required this.code,
    required this.purpose,
    required this.authentication_token,
  });

  Map<String, dynamic> toJson() => _$PhoneVerifyParamToJson(this);
}
