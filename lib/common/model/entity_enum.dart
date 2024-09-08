import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum GameStatus {
  @JsonValue('open')
  open('모집 중', 'open'),
  @JsonValue('closed')
  closed('모집 완료', 'closed'),
  completed('경기 완료', 'completed'),
  @JsonValue('canceled')
  canceled('경기 취소', 'canceled');
  // @JsonValue('completed')

  const GameStatus(this.displayName, this.value);

  final String displayName;
  final String value;

  static GameStatus stringToEnum({required String value}) {
    return GameStatus.values.firstWhere((e) => e.displayName == value);
  }
}

enum ParticipationStatus {
  /// 경기 참여 요청 생성 상태
  @JsonValue('requested')
  requested('참여요청'),

  /// 경기 참여 확정 상태
  @JsonValue('confirmed')
  confirmed('참여확정'),

  /// 경기 참여 취소 상태
  @JsonValue('canceled')
  canceled('참여취소');

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

  static ReviewType stringToEnum({required String value}) {
    return ReviewType.values.firstWhere((e) => e.value == value);
  }
}

@JsonEnum(valueField: 'value')
enum ItemType {
  pickUp('pickup_game');

  const ItemType(this.value);

  final String value;
}

enum SettlementType {
  @JsonValue('waiting')
  waiting('정산 대기중'),
  @JsonValue('partially_completed')
  partiallyCompleted('부분 정산 완료'),
  @JsonValue('completed')
  completed('정산 완료'),
  @JsonValue('suspended')
  suspended('정산 정지'),
  @JsonValue('canceled')
  canceled('정산 취소');

  const SettlementType(this.name);

  final String name;
}

enum TransferType {
  @JsonValue('waiting')
  waiting('이체 대기중'),
  @JsonValue('declined')
  declined('이체 거부됨'),
  @JsonValue('completed')
  completed('이체 완료');

  const TransferType(this.name);

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

enum PlayerReviewTagType {
  @JsonValue('scoring_ability')
  scoringAbility('득점능력'),
  @JsonValue('ball_handling')
  ballHandling('볼핸들링'),
  @JsonValue('defensive_aggressiveness')
  defensiveAggressiveness('수비적극성'),
  @JsonValue('passing')
  passing('패스'),
  @JsonValue('shooting_accuracy')
  shootingAccuracy('슛정확도'),
  @JsonValue('space_creation')
  spaceCreation('공간창출'),
  @JsonValue('shoot_blocking')
  shootBlocking('블로킹'),
  @JsonValue('man_to_man_defence')
  manToManDefence('1:1수비'),
  @JsonValue('sportsmanship')
  sportsmanship('스포츠맨쉽'),
  @JsonValue('manners')
  manners('매너'),
  @JsonValue('politeness')
  politeness('인사성'),
  @JsonValue('leadership')
  leadership('리더쉽'),
  @JsonValue('teamwork')
  teamwork('팀워크');

  const PlayerReviewTagType(this.name);

  final String name;
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

enum PaymentMethodType {
  empty_pay,
  kakao_pay;
}

enum BankType {
  @JsonValue("KOOKMIN")
  KOOKMIN("KB국민"),
  @JsonValue("SHINHAN")
  SHINHAN("신한"),
  @JsonValue("WOORI")
  WOORI("우리"),
  @JsonValue("SHINHYEOP")
  SHINHYEOP("신협"),
  @JsonValue("IBK")
  IBK("IBK기업"),
  @JsonValue("SAEMAUL")
  SAEMAUL("새마을금고"),
  @JsonValue("NONGHYEOP")
  NONGHYEOP("NH농협"),
  @JsonValue("SC")
  SC("SC제일"),
  @JsonValue("KYONGNAMBANK")
  KYONGNAMBANK("경남"),
  @JsonValue("DAEGUBANK")
  DAEGUBANK("대구"),
  @JsonValue("GWANGJUBANK")
  GWANGJUBANK("광주"),
  @JsonValue("BUSANBANK")
  BUSANBANK("부산"),
  @JsonValue("CITI")
  CITI("씨티"),
  @JsonValue("SUHYEOP")
  SUHYEOP("수협"),
  @JsonValue("KDBBANK")
  KDBBANK("KDB산업"),
  @JsonValue("JEONBUKBANK")
  JEONBUKBANK("전북"),
  @JsonValue("POST")
  POST("우체국"),
  @JsonValue("HANA")
  HANA("하나"),
  @JsonValue("KBANK")
  KBANK("케이뱅크"),
  @JsonValue("TOSSBANK")
  TOSSBANK("토스뱅크"),
  @JsonValue("KAKAOBANK")
  KAKAOBANK("카카오뱅크"),
  @JsonValue("SANLIM")
  SANLIM("산림조합"),
  @JsonValue("KOREA_INVESTMENT_AND_SECURITIES")
  KOREA_INVESTMENT_AND_SECURITIES("한국투자증권"),
  @JsonValue("KB_SECURITIES")
  KB_SECURITIES("KB증권"),
  @JsonValue("NH_INVESTMENT_AND_SECURITIES")
  NH_INVESTMENT_AND_SECURITIES("NH투자증권");

  final String displayName;

  const BankType(this.displayName);
}
