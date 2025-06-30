import 'package:json_annotation/json_annotation.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';

import 'auth_param.dart';

part 'login_param.g.dart';

@JsonSerializable()
class LoginParam extends LoginBaseParam{
  final String email;
  final String password;

  LoginParam({
    required this.email,
    required this.password,
  });

  LoginParam copyWith({String? email, String? password}) {
    return LoginParam(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$LoginParamToJson(this);
}

@JsonSerializable()
class RequestCodeParam extends LoginParam {
  RequestCodeParam({required super.email, required super.password});

  @override
  Map<String, dynamic> toJson() => _$RequestCodeParamToJson(this);

  factory RequestCodeParam.fromLoginForm({required LoginParam model}) {
    return RequestCodeParam(
      email: model.email,
      password: model.password,
    );
  }

  factory RequestCodeParam.fromSignForm({required SignFormModel model}) {
    return RequestCodeParam(
      email: model.email!,
      password: model.password!,
    );
  }
}
