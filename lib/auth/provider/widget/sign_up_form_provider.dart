import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/default_model.dart';
import '../../../common/model/entity_enum.dart';
import '../../../report/model/agreement_policy_model.dart';
import '../../../report/provider/report_provider.dart';
import '../../../user/model/v2/base_player_profile_response.dart';
import '../../../util/util.dart';

part 'sign_up_form_provider.g.dart';

class ValidTimer {
  final bool isShow;
  final int sec;

  ValidTimer({required this.isShow, required this.sec});

  ValidTimer copyWith({
    bool? isShow,
    int? sec,
  }) {
    return ValidTimer(isShow: isShow ?? this.isShow, sec: sec ?? this.sec);
  }
}

@Riverpod(keepAlive: false)
class TimerForm extends _$TimerForm {
  @override
  ValidTimer build({required int sec}) {
    return ValidTimer(isShow: false, sec: sec);
  }

  void updateTimer({bool? isShow, int? sec}) {
    state = state.copyWith(isShow: isShow, sec: sec);
  }

  void timer() {
    state = state.copyWith(sec: state.sec - 1);
  }

  bool isComplete() {
    return state.sec == 0 ? true : false;
  }
}

class SignFormModel extends Equatable {
  final String nickname;
  final String? email;
  final String? password;
  final String? checkPassword;
  final String name;
  final String birthDate;
  final String? phoneNumber;
  final int? validCode;
  final bool showAutoComplete;
  final List<bool> checkBoxes;
  final String? signup_token;
  final String? userinfo_token;
  final BasePlayerProfileResponse? playerProfile;

  SignFormModel({
    required this.nickname,
    this.email,
    required this.name,
    this.password,
    this.checkPassword,
    required this.birthDate,
    this.phoneNumber,
    required this.validCode,
    required this.showAutoComplete,
    required this.checkBoxes,
    // required this.showDetail,
    // required this.detailDesc,
    this.signup_token,
    this.userinfo_token,
    this.playerProfile,
  });

  SignFormModel copyWith({
    String? nickname,
    String? email,
    String? password,
    String? checkPassword,
    String? name,
    String? birthDate,
    String? phoneNumber,
    int? validCode,
    bool? showAutoComplete,
    List<bool>? checkBoxes,
    List<bool>? showDetail,
    List<String>? detailDesc,
    String? signup_token,
    String? userinfo_token,
    BasePlayerProfileResponse? playerProfile,
  }) {
    return SignFormModel(
      nickname: nickname ?? this.nickname,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      validCode: validCode ?? this.validCode,
      email: email ?? this.email,
      showAutoComplete: showAutoComplete ?? this.showAutoComplete,
      password: password ?? this.password,
      checkPassword: checkPassword ?? this.checkPassword,
      checkBoxes: checkBoxes ?? this.checkBoxes,
      // showDetail: showDetail ?? this.showDetail,
      // detailDesc: detailDesc ?? this.detailDesc,
      signup_token: signup_token ?? this.signup_token,
      userinfo_token: userinfo_token ?? this.userinfo_token,
      playerProfile: playerProfile ?? this.playerProfile,
    );
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        nickname,
        email,
        password,
        checkPassword,
        name,
        birthDate,
        phoneNumber,
        validCode,
        showAutoComplete,
        checkBoxes,
        signup_token,
        userinfo_token,
        playerProfile,
      ];
}

@Riverpod(keepAlive: false)
class SignUpForm extends _$SignUpForm {
  @override
  SignFormModel build() {
    log("signUpFormProvider build!!");
    final result =
        ref.watch(agreementPolicyProvider(type: AgreementRequestType.signup));
    if (result is ResponseListModel<AgreementPolicyModel>) {
      final List<bool> checkBoxes =
          List.generate(result.data!.length, (e) => false);
      return SignFormModel(
          name: '',
          birthDate: '',
          phoneNumber: '',
          validCode: null,
          nickname: '',
          email: '',
          showAutoComplete: true,
          password: '',
          checkPassword: '',
          checkBoxes: checkBoxes,
          playerProfile: null);
    }

    return SignFormModel(
      name: '',
      birthDate: '',
      phoneNumber: '',
      validCode: null,
      nickname: '',
      email: '',
      showAutoComplete: true,
      password: '',
      checkPassword: '',
      checkBoxes: const [false, false, false, false, false],
      playerProfile: null,
    );
  }

  List<bool> onCheck(int idx) {
    final checkBoxes = state.checkBoxes;
    checkBoxes[idx] = !checkBoxes[idx];
    updateForm(checkBoxes: checkBoxes.toList());
    return state.checkBoxes;
  }

  void updateForm({
    String? nickname,
    String? email,
    String? password,
    String? checkPassword,
    String? name,
    String? birthDate,
    String? phoneNumber,
    int? validCode,
    bool? showAutoComplete,
    List<bool>? checkBoxes,
    String? signup_token,
    String? userinfo_token,
    BasePlayerProfileResponse? playerProfile,
  }) {
    state = state.copyWith(
      nickname: nickname,
      email: email,
      password: password,
      checkPassword: checkPassword,
      name: name,
      birthDate: birthDate,
      phoneNumber: phoneNumber,
      validCode: validCode,
      showAutoComplete: showAutoComplete,
      checkBoxes: checkBoxes,
      signup_token: signup_token,
      userinfo_token: userinfo_token,
      playerProfile: playerProfile,
    );
  }

  /// todo nullable 값들에서 valid 강제 ! 수정 필요
  bool isRequestValidCode() {
    return RegExp(r'^01(?:0|1|[6-9])(?:\d{3}|\d{4})\d{4}$')
        .hasMatch(state.phoneNumber!);
  }

  bool validNickname() {
    return ValidRegExp.userNickname(state.nickname);
  }

  bool validEmail() {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(state.email!);
  }

  bool validPassword({required isPassword}) {
    return ValidRegExp.userPassword(
        isPassword! ? state.password! : state.checkPassword!);
    // return RegExp(
    //         r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$%^&]).{8,}$")
    //     .hasMatch(isPassword ? state.password : state.checkPassword);
  }

  bool isSamePassword() {
    final valid = ValidRegExp.userPassword(state.password!);
    if (state.password == state.checkPassword && valid) {
      return true;
    }
    return false;
  }

  bool validName() {
    return ValidRegExp.userName(state.name);
  }

  bool validPhoneNumber() {
    return RegExp(r"^\d{3}-\d{4}-\d{4}$").hasMatch(state.phoneNumber!);
  }

  bool validBirth() {
    log('state.birthDate ${state.birthDate}');
    return RegExp(r"^\d{4} / (0[1-9]|1[0-2]) / (0[1-9]|[1-2][0-9]|3[0-1])$")
        .hasMatch(state.birthDate);
  }

  bool validCheckBox() {
    log('state.checkBoxes.length = ${state.checkBoxes.length}');
    return state.checkBoxes
            .sublist(0, state.checkBoxes.length)
            .where((e) => e)
            .length ==
        state.checkBoxes.length;
  }

  void showDetail({required int idx}) {
    // final List<bool> newShowDetail = List.from(state.showDetail);
    // newShowDetail[idx] = !newShowDetail[idx];
    // state = state.copyWith(showDetail: newShowDetail);
  }

  bool validPersonalInfo(SignupMethodType type) {
    if (type != SignupMethodType.kakao) {
      return validName() && validBirth() && validPhoneNumber();
    }
    return validName() && validBirth();
  }
}

class ProgressModel {
  final int progress;
  final bool validNext;

  ProgressModel({required this.progress, required this.validNext});

  ProgressModel copyWith({
    int? progress,
    bool? validNext,
  }) {
    return ProgressModel(
      progress: progress ?? this.progress,
      validNext: validNext ?? this.validNext,
    );
  }
}

@riverpod
class Progress extends _$Progress {
  @override
  ProgressModel build() {
    return ProgressModel(progress: 1, validNext: false);
  }

  void nextProgress() {
    state = state.copyWith(progress: state.progress + 1, validNext: false);
  }

  void updateValidNext({required bool validNext}) {
    state = state.copyWith(validNext: validNext);
  }

  void hideDetail() {
    // // final details = ref.read(signUpFormProvider).showDetail;
    // final checkBoxes = ref.read(signUpFormProvider).checkBoxes;
    // final index = details.indexOf(true);
    // final List<bool> newCheckBoxes = List.from(checkBoxes);
    // newCheckBoxes[index + 1] = true;
    // ref.read(signUpFormProvider.notifier).updateForm(
    //     checkBoxes: newCheckBoxes, showDetail: [false, false, false, false]);
    // if (ref.read(signUpFormProvider.notifier).validCheckBox()) {
    //   state = state.copyWith(validNext: true);
    // } else {
    //   state = state.copyWith(validNext: false);
    // }
  }
}
