import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../account/model/account_model.dart';
import '../../auth/model/auth_model.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';

part 'user_model.g.dart';

class UserInfoModel extends LoginModel {
  final String? birthday;
  final String name;
  final String phone;

  UserInfoModel({
    required super.id,
    required super.email,
    required super.nickname,
    required super.token,
    required super.signup_method,
    required this.birthday,
    required this.name,
    required this.phone,
  });

  UserInfoModel copyWith(
    int? id,
    String? email,
    String? nickname,
    AuthType? signup_method,
    TokenModel? token,
    String? birthday,
    String? name,
    String? phone,
  ) {
    return UserInfoModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      token: token ?? this.token,
      birthday: birthday ?? this.birthday,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      signup_method: signup_method ?? this.signup_method,
    );
  }
}

@JsonSerializable()
class UserModel extends IModelWithId {
  final String email;
  final String nickname;
  final String? name;
  final String? birthday;
  final String? phone;
  final AuthType? oauth;
  final AccountModel account;
  final RatingModel rating;

  UserModel({
    required super.id,
    required this.email,
    required this.nickname,
    required this.name,
    required this.birthday,
    required this.phone,
    required this.oauth,
    required this.account,
    required this.rating,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserModel copyWith({
    int? id,
    String? email,
    String? nickname,
    String? name,
    String? birthday,
    String? phone,
    AuthType? oauth,
    AccountModel? account,
    RatingModel? rating,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      oauth: oauth ?? this.oauth,
      account: account ?? this.account,
      rating: rating ?? this.rating,
    );
  }
}

@JsonSerializable()
class UserNicknameModel extends IModelWithId {
  final String email;

  UserNicknameModel({
    required this.email,
    required super.id,
  });

  factory UserNicknameModel.fromJson(Map<String, dynamic> json) =>
      _$UserNicknameModelFromJson(json);
}
