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
  @override
  UserPasswordParam build() {
    return UserPasswordParam(
      password: null,
      new_password: null,
      new_password_check: null,
    );
  }

  void update({
    String? password,
    String? new_password,
    String? new_password_check,
  }) {
    state = state.copyWith(
      password: password,
      new_password: new_password,
      new_password_check: new_password_check,
    );
  }

  bool validForm() {
    if (state.password != null &&
        state.new_password != null &&
        state.new_password_check != null) {
      return ValidRegExp.userPassword(state.password!) &&
          ValidRegExp.userPassword(state.new_password!) &&
          ValidRegExp.userPassword(state.new_password_check!) &&
          state.new_password! == state.new_password_check!;
    }
    return false;
  }
}
