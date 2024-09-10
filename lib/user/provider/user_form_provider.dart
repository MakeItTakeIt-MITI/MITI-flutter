import 'package:miti/user/param/user_profile_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../util/util.dart';

part 'user_form_provider.g.dart';

@riverpod
class UserNicknameForm extends _$UserNicknameForm {
  @override
  UserNicknameParam build() {
    return UserNicknameParam(
      nickname: null,
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
    if (state.nickname != null) {
      return ValidRegExp.userNickname(state.nickname!);
    } else {
      return false;
    }
  }

// bool validForm() {
//   if (state.password != null && state.new_password != null && state.new_password_check != null) {
//     return ValidRegExp.userPassword(state.password!) &&
//         ValidRegExp.userPassword(state.new_password!) &&
//         ValidRegExp.userPassword(state.new_password_check!) &&
//         state.new_password! == state.new_password_check!;
//   }
//   return false;
// }
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

  bool getValid(){
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
