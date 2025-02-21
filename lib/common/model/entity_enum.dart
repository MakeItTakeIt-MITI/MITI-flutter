import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum GameStatusType {
  @JsonValue('open')
  open('모집중', 'open'),
  @JsonValue('closed')
  closed('모집완료(마감)', 'closed'),
  @JsonValue('canceled')
  canceled('경기취소', 'canceled'),
  @JsonValue('completed')
  completed('경기완료', 'completed');

  const GameStatusType(this.displayName, this.value);

  final String displayName;
  final String value;

  static GameStatusType stringToEnum({required String value}) {
    return GameStatusType.values.firstWhere((e) => e.displayName == value);
  }
}

enum ParticipationStatusType {
  /// 경기 참여 요청 생성 상태
  @JsonValue('requested')
  requested('참여 요청 완료'),

  /// 경기 참여 확정 상태
  @JsonValue('confirmed')
  confirmed('참여 승인 완료'),

  // 참가자 변심으로 인한 참여 취소
  @JsonValue('withdrawn')
  withdrawn('참가자 변심으로 인한 참여 취소'),

  /// 경기 참여 취소 상태
  @JsonValue('canceled')
  canceled('경기 취소로 인한 참여 취소');

  const ParticipationStatusType(this.name);

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

enum PaymentResultStatusType {
  @JsonValue('created')
  created('요청 생성'),
  @JsonValue('requested')
  requested('PG 결제 요청 완료'),
  @JsonValue('approved')
  approved('PG 결제 승인 완료'),
  @JsonValue('failed')
  failed('PG 결제 실패'),
  @JsonValue('canceled')
  canceled('PG 결제 취소');

  const PaymentResultStatusType(this.name);

  final String name;
}

@JsonEnum(valueField: 'value')
enum ReviewType {
  @JsonValue('host_review')
  hostReview('호스트 리뷰', 'host_review'),
  @JsonValue('guest_review')
  guestReview('게스트 리뷰', 'guest_review');

  const ReviewType(this.displayName, this.value);

  final String displayName;
  final String value;

  static ReviewType stringToEnum({required String value}) {
    return ReviewType.values.firstWhere((e) => e.value == value);
  }
}

enum ItemType {
  pickup_game('픽업게임');

  const ItemType(this.value);

  final String value;
}

enum SettlementType {
  @JsonValue('hosting')
  hosting('경기 운영 정산금');

  const SettlementType(this.name);

  final String name;
}

enum SettlementStatusType {
  @JsonValue('waiting')
  waiting('대기중'),
  @JsonValue('partially_completed')
  partiallyCompleted('부분 정산'),
  @JsonValue('completed')
  completed('정산완료'),
  @JsonValue('suspended')
  suspended('정산정지'),
  @JsonValue('canceled')
  canceled('정산취소');

  const SettlementStatusType(this.name);

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
  active('활성화'),
  @JsonValue('disabled')
  disabled('비활성화');

  const AccountStatus(this.name);

  final String name;
}

enum AccountType {
  @JsonValue('personal')
  personal('개인 잔고');

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

enum SignupMethodType {
  email,
  kakao,
  apple;

  static SignupMethodType stringToEnum({required String value}) {
    return SignupMethodType.values.firstWhere((e) => e.name == value);
  }
}

enum ErrorScreenType {
  notFound,
  unAuthorization,
  server;
}

enum PhoneAuthenticationPurposeType {
  signup,
  find_email,
  password_update;

  static PhoneAuthenticationPurposeType stringToEnum({required String value}) {
    return PhoneAuthenticationPurposeType.values
        .firstWhere((e) => e.name == value);
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
  empty_pay('0원 결제 전용 결제수단'),
  card('카드'),
  kakao('카카오페이'),
  npay('네이버 페이');

  final String displayName;

  const PaymentMethodType(this.displayName);
}

enum BankType {
  @JsonValue('KOOKMIN')
  KOOKMIN('KB국민'),
  @JsonValue('SHINHAN')
  SHINHAN('신한'),
  @JsonValue('WOORI')
  WOORI('우리'),
  @JsonValue('SHINHYEOP')
  SHINHYEOP('신협'),
  @JsonValue('IBK')
  IBK('IBK기업'),
  @JsonValue('SAEMAUL')
  SAEMAUL('새마을금고'),
  @JsonValue('NONGHYEOP')
  NONGHYEOP('NH농협'),
  @JsonValue('SC')
  SC('SC제일'),
  @JsonValue('KYONGNAMBANK')
  KYONGNAMBANK('경남'),
  @JsonValue('DAEGUBANK')
  DAEGUBANK('대구'),
  @JsonValue('GWANGJUBANK')
  GWANGJUBANK('광주'),
  @JsonValue('BUSANBANK')
  BUSANBANK('부산'),
  @JsonValue('CITI')
  CITI('씨티'),
  @JsonValue('SUHYEOP')
  SUHYEOP('수협'),
  @JsonValue('KDBBANK')
  KDBBANK('KDB산업'),
  @JsonValue('JEONBUKBANK')
  JEONBUKBANK('전북'),
  @JsonValue('JEJUBANK')
  JEJUBANK('제주'),
  @JsonValue('POST')
  POST('우체국'),
  @JsonValue('HANA')
  HANA('하나'),
  @JsonValue('KBANK')
  KBANK('케이뱅크'),
  @JsonValue('TOSSBANK')
  TOSSBANK('토스뱅크'),
  @JsonValue('KAKAOBANK')
  KAKAOBANK('카카오뱅크'),
  @JsonValue('SANLIM')
  SANLIM('산림조합'),
  @JsonValue('KOREA_INVESTMENT_AND_SECURITIES')
  KOREA_INVESTMENT_AND_SECURITIES('한국투자증권'),
  @JsonValue('KB_SECURITIES')
  KB_SECURITIES('KB증권'),
  @JsonValue('NH_INVESTMENT_AND_SECURITIES')
  NH_INVESTMENT_AND_SECURITIES('NH투자증권');

  static BankType stringToEnum({required String value}) {
    return BankType.values.firstWhere((e) {
      return e.displayName == value;
    });
  }

  final String displayName;

  const BankType(this.displayName);
}

enum PushNotificationTopicType {
  @JsonValue('general')
  general('일반 알림', true),
  @JsonValue('game_status_changed')
  game_status_changed('경기 상태 변경 알림', true),
  @JsonValue('new_participation')
  new_participation('새로운 참가 알림', true),
  @JsonValue('game_fee_changed')
  game_fee_changed('경기 참가비 변경 알림', true),
  @JsonValue('host_report_reportee')
  host_report_reportee('호스트 신고 알림 to 피신고 사용자', false),
  @JsonValue('host_report_reporter')
  host_report_reporter('호스트 신고 알림 to 신고 사용자', false),
  @JsonValue('host_report_dismissed')
  host_report_dismissed('호스트 신고 기각', false),
  @JsonValue('host_user_penalized')
  host_user_penalized('호스트 신고 인정', false),
  @JsonValue('guest_report_reportee')
  guest_report_reportee('게스트 신고 알림 to 피신고 사용자', false),
  @JsonValue('guest_report_reporter')
  guest_report_reporter('게스트 신고 알림 to 신고 사용자', false),
  @JsonValue('guest_report_dismissed')
  guest_report_dismissed('게스트 신고 기각', false),
  @JsonValue('guest_user_penalized')
  guest_user_penalized('게스트 신고 인정', false);

  const PushNotificationTopicType(this.displayName, this.canSetting);

  static PushNotificationTopicType stringToEnum({required String value}) {
    return PushNotificationTopicType.values.firstWhere((e) => e.name == value);
  }

  final String displayName;
  final bool canSetting;
}

enum ReportCategoryType {
  @JsonValue('host_report')
  hostReport('호스트 신고'),
  @JsonValue('guest_report')
  guestReport('게스트 신고'),
  @JsonValue('etc')
  etc('기타 신고');

  const ReportCategoryType(
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

enum PaymentCancelationReasonType {
  @JsonValue('simple_cancelation')
  simple_cancelation('단순 결제 취소'),
  @JsonValue('game_cancelation')
  game_cancelation('경기 취소'),
  @JsonValue('converted_to_free_game')
  converted_to_free_game('무료 경기 전환'),
  @JsonValue('report_result')
  report_result('신고 처리 결과');

  const PaymentCancelationReasonType(
    this.displayName,
  );

  final String displayName;
}

enum PaymentResultType {
  created('결제 요청'),
  requested('결제 요청 완료'),
  approved('결제 완료'),
  failed('결제 실패'),
  canceled('결제 취소');

  const PaymentResultType(
    this.displayName,
  );

  final String displayName;
}

enum ReportStatusType {
  @JsonValue('waiting')
  waiting('대기중'),
  @JsonValue('evidence_requested')
  evidenceRequested('자료 요청'),
  @JsonValue('investigation_in_progress')
  investigationInProgress('조사진행중'),
  @JsonValue('concluded')
  concluded('처리완료');

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

enum PenaltyType {
  suspension('이용 정지'),
  warning('서비스 경고');

  const PenaltyType(
    this.displayName,
  );

  final String displayName;
}

enum ReportInvestigationResultType {
  dismissed('신고 기각'),
  penalized('신고 인정');

  const ReportInvestigationResultType(
    this.displayName,
  );

  final String displayName;
}

enum PolicyType {
  policy('방침'),
  @JsonValue('terms_and_conditions')
  termsAndConditions('약관'),
  @JsonValue('user_policy')
  userPolicy('이용정책');

  const PolicyType(
    this.displayName,
  );

  final String displayName;
}

enum AgreementRequestType {
  @JsonValue('signup')
  signup('회원가입'),
  @JsonValue('game_hosting')
  gameHosting('경기 생성'),
  @JsonValue('game_participation')
  gameParticipation('경기 참여'),
  @JsonValue('transfer_request')
  transferRequest('정산금 이체 요청'),
  @JsonValue('participation_refund')
  participationRefund('참여 취소');

  const AgreementRequestType(
    this.displayName,
  );

  final String displayName;
}

enum NotificationStatusType {
  waiting('전송 대기중'),
  failed('전송 실패'),
  success('전송 완료'),
  ignored('사용자 무시 주제 알림');

  const NotificationStatusType(
    this.displayName,
  );

  final String displayName;
}

enum PlayerProfileType {
  gender('성별'),
  weight('체중'),
  height('신장'),
  position('포지션'),
  role('역할');

  const PlayerProfileType(this.displayName);

  final String displayName;
}

enum PlayerPositionType {
  PG('포인트가드'),
  SG('슈팅가드'),
  SF('스몰포워드'),
  PF('파워포워드'),
  C('센터');

  const PlayerPositionType(this.displayName);

  static PlayerPositionType stringToEnum({required String value}) {
    return PlayerPositionType.values.firstWhere((e) {
      return e.displayName == value;
    });
  }

  final String displayName;
}

enum PlayerRoleType {
  swingman('스윙맨'),
  ball_handler('볼핸들러'),
  bigman('빅맨'),
  stretch_bigman('스트레치빅맨'),
  control_tower('컨트롤나워'),
  point_forward('포인트포워드'),
  allrounder('올라운더'),
  tweener('트위너'),
  dual_guard('듀얼가드'),
  slasher('슬래셔'),
  shooter('슈터'),
  @JsonValue('3point_and_defense')
  three_point_and_defense('3&D'),
  blueworker('블루워커');

  const PlayerRoleType(this.displayName);

  static PlayerRoleType stringToEnum({required String value}) {
    return PlayerRoleType.values.firstWhere((e) {
      return e.displayName == value;
    });
  }

  final String displayName;
}

enum GenderType {
  male('남성'),
  female('여성');

  const GenderType(this.displayName);

  static GenderType stringToEnum({required String value}) {
    return GenderType.values.firstWhere((e) {
      return e.displayName == value;
    });
  }

  final String displayName;
}

enum BankTransferStatusType {
  @JsonValue('이체 완료')
  completed('이체 완료'),
  @JsonValue('대기중')
  waiting('대기중'),
  @JsonValue('이체거절')
  declined('이체거절');

  const BankTransferStatusType(this.displayName);

  static GenderType stringToEnum({required String value}) {
    return GenderType.values.firstWhere((e) {
      return e.displayName == value;
    });
  }

  final String displayName;
}

enum RatingType {
  @JsonValue('host_rating')
  hostRating('호스트 평점'),
  @JsonValue('guest_rating')
  guestRating('게스트 평점');

  const RatingType(this.displayName);

  final String displayName;
}

enum AdvertisementStatusType {
  active('활성화 상태'),
  expired('광고 만료 상태');

  const AdvertisementStatusType(this.displayName);

  final String displayName;
}

enum FaqCategoryType {
  game('경기'),
  participation('참가'),
  settlement('정산'),
  review('리뷰'),
  report('신고'),
  etc('기타');

  const FaqCategoryType(this.displayName);

  final String displayName;
}

enum UserGuideCategoryType {
  game('경기'),
  participation('참여'),
  settlement('정산'),
  transfer('이체'),
  review('리뷰'),
  report('신고'),
  etc('기타');

  const UserGuideCategoryType(this.displayName);

  final String displayName;
}
