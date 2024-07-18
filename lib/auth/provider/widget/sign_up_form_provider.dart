import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

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

class SignFormModel {
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
  final List<bool> showDetail;
  final List<String> detailDesc;
  final String? signup_token;
  final String? userinfo_token;

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
    required this.showDetail,
    required this.detailDesc,
    this.signup_token,
    this.userinfo_token,
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
      showDetail: showDetail ?? this.showDetail,
      detailDesc: detailDesc ?? this.detailDesc,
      signup_token: signup_token ?? this.signup_token,
      userinfo_token: userinfo_token ?? this.userinfo_token,
    );
  }
}

@Riverpod(keepAlive: false)
class SignUpForm extends _$SignUpForm {
  @override
  SignFormModel build() {
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
      checkBoxes: [false, false, false, false, false],
      showDetail: [false, false, false, false],
      detailDesc: [
        '제 1 장 총칙 제1조 (목적) 본 약관은 (주)핀업 (이하 \'회사\' 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 \'사이트\' (이하 합쳐서 \'사이트\'이라 한다)에서 제공하는 인터넷 관련 서비스(이하 \'서비스\'라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다. 제 2조 (약관 등의 명시와 설명 및 개정) ① \'사이트\'는 이 약관의 내용과 상호 및 대표자 성명, 영업소 소재지 주소(소비자의 불만을 처리할 수 있는 곳의 주소를 포함), 전화번호, 전자우편주소, 사업자등록번호, 통신판매업신고번호, 개인정보보호책임자 등을 이용자가 쉽게 알 수 있도록 ‘사이트’의 초기 서비스 화면(전면)에 게시합니다. 다만, 약관의 내용은 이용자가 연결 화면을 통하여 볼 수 있도록 할 수 있습니다. ② \'사이트\'는 이용자가 약관에 동의하기에 앞서 약관에 정하여져 있는 내용 중 결제 취소, 청약 철회, 환불 조건 등과 같은 중요한 내용을 이용자가 이해할 수 있도록 별도의 연결 화면 또는 팝업 화면 등을 제공 하여 이용자의 확인을 구하여야 합니다. ③ \'사이트\'는 「전자상거래 등에서의 소비자보호에 관한 법률」, 「약관의 규제에 관한 법률」, 「전자문서 및 전자거래기본법」, 「전자금융거래법」, 「전자서명법」, 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」, 「방문판매 등에 관한 법률」, 「소비자기본법」 등 관련 법을 위배하지 않는 범위에서 이 약관을 개정할 수 있습니다. ④ \'사이트\'가 약관을 개정할 경우에는 적용 일자 및 개정 사유를 명시하여 현행 약관과 함께 \'사이트\'의 초기 화면에 그 적용 일자 7일 전부터 적용일자 전일까지 공지합니다. 다만, 이용자에게 불리하게 약관 내용을 변경하는 경우에는 최소한 30일 이상의 사전 유예 기간을 두고 공지합니다제 1 장 총칙 제1조 (목적) 본 약관은 (주)핀업 (이하 \'회사\' 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 \'사이트\' (이하 합쳐서 \'사이트\'이라 한다)에서 제공하는 인터넷 관련 서비스(이하 \'서비스\'라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다. 제 2조 (약관 등의 명시와 설명 및 개정) ① \'사이트\'는 이 약관의 내용과 상호 및 대표자 성명, 영업소 소재지 주소(소비자의 불만을 처리할 수 있는 곳의 주소를 포함), 전화번호, 전자우편주소, 사업자등록번호, 통신판매업신고번호, 개인정보보호책임자 등을 이용자가 쉽게 알 수 있도록 ‘사이트’의 초기 서비스 화면(전면)에 게시합니다. 다만, 약관의 내용은 이용자가 연결 화면을 통하여 볼 수 있도록 할 수 있습니다. ② \'사이트\'는 이용자가 약관에 동의하기에 앞서 약관에 정하여져 있는 내용 중 결제 취소, 청약 철회, 환불 조건 등과 같은 중요한 내용을 이용자가 이해할 수 있도록 별도의 연결 화면 또는 팝업 화면 등을 제공 하여 이용자의 확인을 구하여야 합니다. ③ \'사이트\'는 「전자상거래 등에서의 소비자보호에 관한 법률」, 「약관의 규제에 관한 법률」, 「전자문서 및 전자거래기본법」, 「전자금융거래법」, 「전자서명법」, 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」, 「방문판매 등에 관한 법률」, 「소비자기본법」 등 관련 법을 위배하지 않는 범위에서 이 약관을 개정할 수 있습니다. ④ \'사이트\'가 약관을 개정할 경우에는 적용 일자 및 개정 사유를 명시하여 현행 약관과 함께 \'사이트\'의 초기 화면에 그 적용 일자 7일 전부터 적용일자 전일까지 공지합니다. 다만, 이용자에게 불리하게 약관 내용을 변경하는 경우에는 최소한 30일 이상의 사전 유예 기간을 두고 공지합니다',
        '내용2',
        '내용3',
        '내용4',
      ],
    );
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
    List<bool>? showDetail,
    String? signup_token,
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
      showDetail: showDetail,
      signup_token: signup_token,
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
    return state.checkBoxes.sublist(0, 4).where((e) => e).length == 4;
  }

  void showDetail({required int idx}) {
    final List<bool> newShowDetail = List.from(state.showDetail);
    newShowDetail[idx] = !newShowDetail[idx];
    state = state.copyWith(showDetail: newShowDetail);
  }

  bool validPersonalInfo() {
    return validName() && validBirth() && validPhoneNumber();
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
    final details = ref.read(signUpFormProvider).showDetail;
    final checkBoxes = ref.read(signUpFormProvider).checkBoxes;
    final index = details.indexOf(true);
    final List<bool> newCheckBoxes = List.from(checkBoxes);
    newCheckBoxes[index + 1] = true;
    ref.read(signUpFormProvider.notifier).updateForm(
        checkBoxes: newCheckBoxes, showDetail: [false, false, false, false]);
    if (ref.read(signUpFormProvider.notifier).validCheckBox()) {
      state = state.copyWith(validNext: true);
    } else {
      state = state.copyWith(validNext: false);
    }
  }
}
