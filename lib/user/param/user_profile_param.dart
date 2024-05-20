import 'package:json_annotation/json_annotation.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';

part 'user_profile_param.g.dart';

@JsonSerializable()
class UserNicknameParam {
  final String? nickname;

  UserNicknameParam({
    required this.nickname,
  });

  UserNicknameParam copyWith({
    String? nickname,
  }) {
    return UserNicknameParam(
      nickname: nickname ?? this.nickname,
    );
  }

  Map<String, dynamic> toJson() => _$UserNicknameParamToJson(this);
}

@JsonSerializable()
class UserPasswordParam {
  final String? password;
  final String? new_password;
  final String? new_password_check;

  UserPasswordParam({
    required this.password,
    required this.new_password,
    required this.new_password_check,
  });

  UserPasswordParam copyWith({
    String? password,
    String? new_password,
    String? new_password_check,
  }) {
    return UserPasswordParam(
      password: password ?? this.password,
      new_password: new_password ?? this.new_password,
      new_password_check: new_password_check ?? this.new_password_check,
    );
  }

  Map<String, dynamic> toJson() => _$UserPasswordParamToJson(this);
}

@JsonSerializable()
class UserGameParam extends DefaultParam {
  final GameStatus? game_status;

  UserGameParam({
    this.game_status,
  });

  @override
  List<Object?> get props => [game_status];

  @override
  Map<String, dynamic> toJson() => _$UserGameParamToJson(this);

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class UserReviewParam extends DefaultParam {
  final ReviewType? review_type;

  UserReviewParam({
    this.review_type,
  });

  @override
  List<Object?> get props => [review_type];

  @override
  Map<String, dynamic> toJson() => _$UserReviewParamToJson(this);

  @override
  bool? get stringify => true;
}
