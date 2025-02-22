import 'package:miti/user/model/user_model.dart';
import 'package:miti/user/param/user_profile_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../util/util.dart';
import '../model/v2/base_player_profile_response.dart';

part 'user_form_provider.g.dart';

@riverpod
class UserNicknameForm extends _$UserNicknameForm {
  @override
  UserNicknameParam build() {
    return UserNicknameParam(
      nickname: '',
    );
  }

  void update({
    String? nickname,
  }) {
    state = state.copyWith(
      nickname: nickname,
    );
  }

  bool validNickname() {
    return ValidRegExp.userNickname(state.nickname);
  }
}

@riverpod
class UserPasswordForm extends _$UserPasswordForm {
  bool valid = false;

  @override
  UserPasswordParam build() {
    return UserPasswordParam(
      new_password_check: null,
      new_password: null,
      password_update_token: null,
    );
  }

  void update({
    String? new_password,
    String? new_password_check,
    String? password_update_token,
  }) {
    state = state.copyWith(
      new_password_check: new_password,
      new_password: new_password_check,
      password_update_token: password_update_token,
    );
    valid = validForm();
  }

  bool getValid() {
    return valid;
  }

  bool validForm() {
    if (state.new_password_check != null &&
        state.new_password != null &&
        state.password_update_token != null) {
      return ValidRegExp.userPassword(state.new_password_check!) &&
          ValidRegExp.userPassword(state.new_password!) &&
          state.new_password! == state.new_password_check!;
    }
    return false;
  }
}

@riverpod
class UserPlayerProfileForm extends _$UserPlayerProfileForm {
  @override
  BasePlayerProfileResponse build() {
    return BasePlayerProfileResponse(
      gender: null,
      weight: null,
      height: null,
      position: null,
      role: null,
    );
  }

  void update({
    GenderType? gender,
    int? weight,
    int? height,
    PlayerPositionType? position,
    PlayerRoleType? role,
  }) {
    state = state.copyWith(
      gender: gender,
      weight: weight,
      height: height,
      position: position,
      role: role,
    );
  }

  void updateByModel(BasePlayerProfileResponse model) {
    state = model;
  }

  bool validWeight() {
    if (state.weight != null) {
      return 30 <= state.weight! && state.weight! <= 150;
    }
    return true;
  }

  bool validHeight() {
    if (state.height != null) {
      return 50 <= state.height! && state.height! <= 230;
    }
    return true;
  }

  bool validForm() {
    return validHeight() && validWeight();
  }
}
