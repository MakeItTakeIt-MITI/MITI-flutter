import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum GameStatus {
  @JsonValue('open')
  open('모집중', 'open'),
  @JsonValue('closed')
  closed('모집 완료', 'closed'),
  @JsonValue('canceled')
  canceled('경기 취소', 'canceled'),
  // @JsonValue('completed')
  completed('경기 완료', 'completed');

  const GameStatus(this.displayName, this.value);

  final String displayName;
  final String value;

  static GameStatus stringToEnum({required String value}) {
    return GameStatus.values.firstWhere((e) => e.displayName == value);
  }
}

enum ParticipationStatus {
  /// 참여가 생성되었지만 결제가 이루어지지 않음
  @JsonValue('참여요청')
  apply('참여요청'),

  /// 참여 생성 및 결제 완료
  @JsonValue('참여확정')
  complete('참여확정'),

  /// 결제 완료 후 결제 취소
  @JsonValue('참여취소')
  cancel('참여취소');

  const ParticipationStatus(this.name);

  final String name;
}

enum PaymentRequestStatus {
  @JsonValue('요청생성')
  create('요청생성'),
  @JsonValue('요청확인')
  confirm('요청확인');

  const PaymentRequestStatus(this.name);

  final String name;
}

enum PaymentResultStatus {
  @JsonValue('생성')
  create('생성'),
  @JsonValue('요청')
  request('요청'),
  @JsonValue('승인')
  complete('승인'),
  @JsonValue('취소')
  cancel('취소'),
  @JsonValue('실패')
  fail('실패');

  const PaymentResultStatus(this.name);

  final String name;
}

@JsonEnum(valueField: 'value')
enum ReviewType {
  @JsonValue('host_review')
  host('호스트리뷰', 'host_review'),
  @JsonValue('guest_review')
  guest('게스트리뷰', 'guest_review');
  // @JsonValue('all')
  // all('전체보기', 'all');

  const ReviewType(this.displayName, this.value);

  final String displayName;
  final String value;
}

@JsonEnum(valueField: 'value')
enum ItemType {
  pickUp('픽업게임');

  const ItemType(this.value);

  final String value;
}

enum SettlementType {
  @JsonValue('waiting')
  waiting('대기중'),
  @JsonValue('partial_completed')
  partial_completed('부분 정산'),
  @JsonValue('completed')
  completed('정산 완료');

  const SettlementType(this.name);

  final String name;
}

enum BankType {
  @JsonValue('waiting')
  waiting('대기중'),
  @JsonValue('completed')
  completed('정산 완료');

  const BankType(this.name);

  final String name;
}

enum AccountStatus {
  @JsonValue('active')
  active('정상 상태'),
  @JsonValue('disabled')
  disabled('정지 상태');

  const AccountStatus(this.name);

  final String name;
}

enum AccountType {
  @JsonValue('personal')
  personal('개인');

  const AccountType(this.name);

  final String name;
}

enum DistrictType {
  @JsonValue('서울')
  seoul('서울'),
  @JsonValue('경기')
  gyeonggi('경기'),
  @JsonValue('인천')
  incheon('인천'),
  @JsonValue('부산')
  busan('부산'),
  @JsonValue('대구')
  daegu('대구'),
  @JsonValue('광주')
  gwangju('광주'),
  @JsonValue('울산')
  ulsan('울산'),
  @JsonValue('세종')
  sejong('세종'),
  @JsonValue('강원')
  gangwon('강원'),
  @JsonValue('충북')
  chungbuk('충북'),
  @JsonValue('충남')
  chungnam('충남'),
  @JsonValue('전북')
  jeonbuk('전북'),
  @JsonValue('전남')
  jeonnam('전남'),
  @JsonValue('경북')
  gyeongbuk('경북'),
  @JsonValue('경남')
  gyeongnam('경남'),
  @JsonValue('제주')
  jeju('제주'),
  @JsonValue('대전')
  daejeon('대전');

  const DistrictType(this.name);

  final String name;

  static DistrictType? stringToEnum({required String value}) {
    if (value == '전체 보기') {
      return null;
    }
    return DistrictType.values.firstWhere((e) => e.name == value);
  }
}

enum AuthType {
  email,
  kakao,
  apple;

  static AuthType stringToEnum({required String value}) {
    return AuthType.values.firstWhere((e) => e.name == value);
  }
}

enum ErrorScreenType {
  notFound,
  unAuthorization,
  server;
}

enum PhoneAuthType {
  signup,
  find_email,
  password_update;
}

enum FormType {
  email,
  password;
}

enum InputFormType {
  login,
  passwordCode,
  nickname,
  email,
  password,
  passwordCheck,
  signUpEmail,
  signUpPassword,
  phone,
  signup,
  find_email,
  password_update,
}

enum PasswordFormType { password, passwordCheck, newPassword, newPasswordCheck }
