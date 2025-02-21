import 'package:json_annotation/json_annotation.dart';

import '../../../../common/model/entity_enum.dart';
import '../../../../court/model/v2/base_court_response.dart';
import 'game_participation_payment_response.dart';
import 'game_response.dart';

part 'game_participation_payment_detail_response.g.dart';

@JsonSerializable()
class GameParticipationPaymentDetailResponse extends GameResponse {
  @JsonKey(name: "is_free_game")
  final bool isFreeGame;
  final BaseCourtResponse court;
  @JsonKey(name: "payment_information")
  final GameParticipationPaymentResponse paymentInformation;

  GameParticipationPaymentDetailResponse({
    required super.id,
    required super.gameStatus,
    required super.title,
    required super.startDate,
    required super.startTime,
    required super.endDate,
    required super.endTime,
    required super.minInvitation,
    required super.maxInvitation,
    required super.numOfParticipations,
    required super.fee,
    required super.info,
    required this.isFreeGame,
    required this.court,
    required this.paymentInformation,
  });

  factory GameParticipationPaymentDetailResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GameParticipationPaymentDetailResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$GameParticipationPaymentDetailResponseToJson(this);

  // CopyWith method
  @override
  GameParticipationPaymentDetailResponse copyWith({
    int? id,
    GameStatusType? gameStatus,
    String? title,
    String? startDate,
    String? startTime,
    String? endDate,
    String? endTime,
    int? minInvitation,
    int? maxInvitation,
    int? numOfParticipations,
    int? fee,
    String? info,
    bool? isFreeGame,
    BaseCourtResponse? court,
    GameParticipationPaymentResponse? paymentInformation,
  }) {
    return GameParticipationPaymentDetailResponse(
      id: id ?? this.id,
      gameStatus: gameStatus ?? this.gameStatus,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      minInvitation: minInvitation ?? this.minInvitation,
      maxInvitation: maxInvitation ?? this.maxInvitation,
      numOfParticipations: numOfParticipations ?? this.numOfParticipations,
      fee: fee ?? this.fee,
      info: info ?? this.info,
      isFreeGame: isFreeGame ?? this.isFreeGame,
      court: court ?? this.court,
      paymentInformation: paymentInformation ?? this.paymentInformation,
    );
  }
}
