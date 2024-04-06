import 'package:json_annotation/json_annotation.dart';

enum GameStatus {
  open('모집중'),
  closed('모집 완료'),
  cancelled('경기 완료'),
  completed('경기 취소');

  const GameStatus(this.name);

  final String name;
}

enum ParticipationStatus {
  @JsonValue('참여요청')
  apply('참여 신청'),
  @JsonValue('참여확정')
  paymentComplete('결제 완료'),/// 참여 확정
  @JsonValue('참여취소')
  cancel('취소 상태');

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