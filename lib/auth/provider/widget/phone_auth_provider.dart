import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/entity_enum.dart';

part 'phone_auth_provider.g.dart';

class PhoneAuthModel {
  final PhoneAuthenticationPurposeType type;
  final String authentication_token;
  final String code;

  PhoneAuthModel({
    required this.type,
    required this.authentication_token,
    required this.code,
  });

  PhoneAuthModel copyWith({
    PhoneAuthenticationPurposeType? type,
    String? authentication_token,
    String? code,
  }) {
    return PhoneAuthModel(
      authentication_token: authentication_token ?? this.authentication_token,
      code: code ?? this.code,
      type: type ?? this.type,
    );
  }
}

@riverpod
class PhoneAuth extends _$PhoneAuth {
  @override
  PhoneAuthModel build({required PhoneAuthenticationPurposeType type}) {
    return PhoneAuthModel(
      authentication_token: '',
      code: '',
      type: type,
    );
  }

  void update({
    String? authentication_token,
    String? code,
    PhoneAuthenticationPurposeType? type,
  }) {
    state = state.copyWith(
      authentication_token: authentication_token,
      code: code,
      type: type,
    );
  }
}
