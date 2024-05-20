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
  final String? oauth;
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
    String? oauth,
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
class UserNicknameModel {
  final String email;
  final String nickname;

  UserNicknameModel({
    required this.email,
    required this.nickname,
  });

  factory UserNicknameModel.fromJson(Map<String, dynamic> json) =>
      _$UserNicknameModelFromJson(json);
}
