import 'dart:developer';

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

// @JsonEnum(valueField: 'value')
enum ItemType {
  pickup_game('pickup_game');

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

  static PhoneAuthType stringToEnum({required String value}) {
    return PhoneAuthType.values.firstWhere((e) => e.name == value);
  }
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
  updateToken,
  amount,
  fee,
}

enum PasswordFormType { password, passwordCheck, newPassword, newPasswordCheck }

enum PaymentMethodType {
  empty_pay('더미 결제 수단'),
  kakao_pay('카카오페이');

  final String displayName;

  const PaymentMethodType(this.displayName);
}

enum BankType {
  @JsonValue("KOOKMIN")
  KOOKMIN("KB국민"),
  @JsonValue("NONGHYEOP")
  NONGHYEOP("NH농협"),
  @JsonValue("SHINHAN")
  SHINHAN("신한"),
  @JsonValue("WOORI")
  WOORI("우리"),
  @JsonValue("DAEGUBANK")
  DAEGUBANK("대구"),
  @JsonValue("IBK")
  IBK("IBK기업"),
  @JsonValue("HANA")
  HANA("하나"),
  @JsonValue("KYONGNAMBANK")
  KYONGNAMBANK("경남"),
  @JsonValue("BUSANBANK")
  BUSANBANK("부산"),
  @JsonValue("TOSSBANK")
  TOSSBANK("토스뱅크"),
  @JsonValue("GWANGJUBANK")
  GWANGJUBANK("광주"),
  @JsonValue("SC")
  SC("SC제일"),
  @JsonValue("JEONBUKBANK")
  JEONBUKBANK("전북"),
  @JsonValue("KAKAOBANK")
  KAKAOBANK("카카오뱅크"),
  @JsonValue("KDBBANK")
  KDBBANK("KDB산업"),
  @JsonValue("POST")
  POST("우체국"),
  @JsonValue("SAEMAUL")
  SAEMAUL("새마을"),
  @JsonValue("SHINHYEOP")
  SHINHYEOP("신협"),
  @JsonValue("CITI")
  CITI("씨티"),
  @JsonValue("KBANK")
  KBANK("케이뱅크"),
  @JsonValue("SUHYEOP")
  SUHYEOP("수협"),
  @JsonValue("SANLIM")
  SANLIM("산림조합"),
  @JsonValue("NH_INVESTMENT_AND_SECURITIES")
  NH_INVESTMENT_AND_SECURITIES("NH투자증권"),
  @JsonValue("KOREA_INVESTMENT_AND_SECURITIES")
  KOREA_INVESTMENT_AND_SECURITIES("한국투자증권"),
  @JsonValue("KB_SECURITIES")
  KB_SECURITIES("KB증권");

  static BankType stringToEnum({required String value}) {
    return BankType.values.firstWhere((e) {
     return e.displayName == value;
    });
  }

  final String displayName;

  const BankType(this.displayName);
}

enum PushNotificationTopicType {
  general('일반 알림', true),
  game_status_changed('경기 상태 변경', true),
  new_participation('새로운 참가 알림', true),
  game_fee_changed('경기 참가비 변경', true),
  host_report_reportee('호스트 신고 알림 to 호스트', false),
  host_report_reporter('호스트 신고 알림 to 신고 사용자', false),
  host_report_dismissed('호스트 신고 기각 알림', false),
  host_report_dismissed_reportee('호스트 신고 기각 알림 to 호스트', false),
  host_report_dismissed_reporter('호스트 신고 기각 알림 to 신고 사용자', false),
  host_user_penalized('호스트 사용자 부정 사용 인정 처리 알림',false);


  const PushNotificationTopicType(this.displayName, this.canSetting);

  static PushNotificationTopicType stringToEnum({required String value}) {
    return PushNotificationTopicType.values.firstWhere((e) => e.name == value);
  }

  final String displayName;
  final bool canSetting;
}

enum ReportType {
  game_hosting_report('경기 주최자 부정 사용 신고'),
  etc('기타 신고');

  const ReportType(
    this.displayName,
  );

  final String displayName;
}

enum HostReportCategoryType {
  intentional_cheating('허위 경기 운영'),
  incorrect_information('부정확한 경기 정보'),
  etc('기타 신고 사유');

  const HostReportCategoryType(
    this.displayName,
  );

  final String displayName;
}

enum FAQType {
  all('전체'),
  game('경기'),
  settlement('정산'),
  review('리뷰'),
  report('신고'),
  etc('기타');

  const FAQType(
    this.displayName,
  );

  final String displayName;
}

enum PaymentCancelType {
  simple_cancelation('단순 변심에 의한 참가 취소'),
  game_cancelation('경기 모집 실패로 인한 취소'),
  converted_to_free_game('무료 경기 전환으로 인한 취소'),
  failed_to_participate_game('경기 참가 실패로 인한 취소'),
  payment_incomplement('최종 결제 미완료로 인한 결제 취소');

  const PaymentCancelType(
    this.displayName,
  );

  final String displayName;
}

enum PaymentResultType {
  created('결제 결과 생성'),
  requested('결제 승인 요청'),
  approved('결제 승인'),
  failed('결제 실패'),
  canceled('결제 취소');

  const PaymentResultType(
    this.displayName,
  );

  final String displayName;
}

enum ReportStatusType {
  waiting('대기중'),
  evidence_requested('관련 자료 요청 상태'),
  dismissed('기각'),
  given_penalty('처분');

  const ReportStatusType(
    this.displayName,
  );

  final String displayName;
}

enum UserGuideType {
  game('경기'),
  participation('참여'),
  settlement('정산'),
  transfer('이체'),
  review('리뷰'),
  report('신고'),
  etc('기타');

  const UserGuideType(
    this.displayName,
  );

  final String displayName;
}

enum PanaltyType {
  suspension('서비스 이용 정지'),
  warning('이용 경고');

  const PanaltyType(
    this.displayName,
  );

  final String displayName;
}

enum ReportInvesticationResultType {
  dismissed('신고 기각'),
  penalized('신고 인정 및 해당 사용자 제재');

  const ReportInvesticationResultType(
    this.displayName,
  );

  final String displayName;
}

enum PolicyType {
  policy('방침'),
  terms_and_conditions('약관'),
  user_policy('이용정책');

  const PolicyType(
    this.displayName,
  );

  final String displayName;
}

enum AgreementRequestType {
  signup('회원가입 요청시 동의 항목'),
  game_hosting('경기 생성시 사용자 동의 항목'),
  game_participation('경기 참가시 사용자 동의 항목'),
  transfer_request('이체 요청 생성시 사용자 동의 항목'),
  participation_refund('환불 사용자 동의 항목');

  const AgreementRequestType(
    this.displayName,
  );

  final String displayName;
}

enum NotificationStatusType {
  waiting('전송 대기중'),
  failed('전송 실패'),
  success('전송 완료'),
  ignored('미전송');

  const NotificationStatusType(
    this.displayName,
  );

  final String displayName;
}
