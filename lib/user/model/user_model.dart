import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../account/model/account_model.dart';
import '../../auth/model/auth_model.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends IModelWithId {
  final String email;
  final String nickname;
  final String? name;
  final String? birthday;
  final String? phone;
  final AuthType signup_method;
  final RatingModel rating;

  UserModel({
    required super.id,
    required this.email,
    required this.nickname,
    required this.name,
    required this.birthday,
    required this.phone,
    required this.signup_method,
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
    AuthType? signup_method,
    RatingModel? rating,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      signup_method: signup_method ?? this.signup_method,
      rating: rating ?? this.rating,
    );
  }
}


@JsonSerializable()
class UserInfoModel {
  final String email;
  final String nickname;

  UserInfoModel({
    required this.email,
    required this.nickname,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
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
