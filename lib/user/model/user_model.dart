import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../auth/model/auth_model.dart';

part 'user_model.g.dart';

class UserInfoModel extends LoginModel {
  final String? birthday;
  final String name;
  final String phone;

  UserInfoModel({
    required super.id,
    required super.email,
    required super.nickname,
    required super.is_authenticated,
    required super.token,
    required this.birthday,
    required this.name,
    required this.phone,
  });

  UserInfoModel copyWith(
    int? id,
    String? email,
    String? nickname,
    bool? is_authenticated,
    TokenModel? token,
    String? birthday,
    String? name,
    String? phone,
  ) {
    return UserInfoModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      is_authenticated: is_authenticated ?? this.is_authenticated,
      token: token ?? this.token,
      birthday: birthday ?? this.birthday,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}

@JsonSerializable()
class UserModel extends IModelWithId {
  final String email;
  final String nickname;
  final String name;
  final String? birthday;
  final String phone;

  UserModel({
    required super.id,
    required this.email,
    required this.nickname,
    required this.name,
    required this.birthday,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
