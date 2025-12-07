import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../common/model/model_id.dart';

part 'base_game_meta_response.g.dart';

@JsonSerializable()
class BaseGameMetaResponse extends IModelWithId {
  @JsonKey(name: 'game_status')
  final GameStatusType gameStatus;

  final String title; // 수정: titile → title

  @JsonKey(name: 'startdate')
  final String startDate;

  @JsonKey(name: 'starttime')
  final String startTime;

  @JsonKey(name: 'enddate')
  final String endDate;

  @JsonKey(name: 'endtime')
  final String endTime;

  @JsonKey(name: 'min_invitation')
  final int minInvitation;

  @JsonKey(name: 'max_invitation')
  final int maxInvitation;

  @JsonKey(name: 'num_of_participations')
  final int numOfParticipations;

  final int fee;

  @JsonKey(name: 'court_name')
  final String courtName;

  final String address;

  @JsonKey(name: 'address_detail')
  final String? addressDetail; // null 가능

  final String latitude;
  final String longitude;

  BaseGameMetaResponse({
    required this.gameStatus,
    required this.title,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.minInvitation,
    required this.maxInvitation,
    required this.numOfParticipations,
    required this.fee,
    required this.courtName,
    required this.address,
    this.addressDetail,
    required this.latitude,
    required this.longitude,
    required super.id,
  });

  factory BaseGameMetaResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameMetaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameMetaResponseToJson(this);

  // copyWith 메서드 (상태 업데이트용)
  BaseGameMetaResponse copyWith({
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
    String? courtName,
    String? address,
    String? addressDetail,
    String? latitude,
    String? longitude,
  }) {
    return BaseGameMetaResponse(
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
      courtName: courtName ?? this.courtName,
      address: address ?? this.address,
      addressDetail: addressDetail ?? this.addressDetail,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseGameMetaResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BaseGameMetaResponse(id: $id, title: $title)';
}
