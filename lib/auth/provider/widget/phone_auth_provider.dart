import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phone_auth_provider.g.dart';

class PhoneAuthModel {
  final String user_info_token;
  final String code;

  PhoneAuthModel({
    required this.user_info_token,
    required this.code,
  });

  PhoneAuthModel copyWith({
    String? user_info_token,
    String? code,
  }) {
    return PhoneAuthModel(
      user_info_token: user_info_token ?? this.user_info_token,
      code: code ?? this.code,
    );
  }
}

@riverpod
class PhoneAuth extends _$PhoneAuth {
  @override
  PhoneAuthModel build() {
    return PhoneAuthModel(user_info_token: '', code: '');
  }

  void update({
    String? user_info_token,
    String? code,
  }) {
    state = state.copyWith(user_info_token: user_info_token, code: code);
  }
}
