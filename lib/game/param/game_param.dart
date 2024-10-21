import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';

part 'game_param.g.dart';

@JsonSerializable()
class GameListParam extends Equatable {
  final String? startdate;
  final String? starttime;
  @JsonKey(name: "game_status")
  final List<GameStatus> gameStatus;

  const GameListParam({
    this.startdate,
    this.starttime,
    required this.gameStatus,
  });

  Map<String, dynamic> toJson() => _$GameListParamToJson(this);

  @override
  List<Object?> get props => [startdate, starttime, gameStatus];

  @override
  bool? get stringify => true;

  GameListParam copyWith({
    String? startdate,
    String? starttime,
    List<GameStatus>? gameStatus,
  }) {
    return GameListParam(
      startdate: startdate ?? this.startdate,
      starttime: starttime ?? this.starttime,
      gameStatus: gameStatus ?? this.gameStatus,
    );
  }
}

@JsonSerializable()
class GameCreateParam extends Equatable {
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final String min_invitation;
  final String max_invitation;
  final String info;
  final String fee;
  final GameCourtParam court;
  @JsonKey(includeToJson: false)
  final List<bool> checkBoxes;

  const GameCreateParam({
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.min_invitation,
    required this.max_invitation,
    required this.info,
    required this.fee,
    required this.court,
    required this.checkBoxes,
  });

  GameCreateParam copyWith({
    String? title,
    String? startdate,
    String? starttime,
    String? enddate,
    String? endtime,
    String? min_invitation,
    String? max_invitation,
    String? info,
    String? fee,
    GameCourtParam? court,
    List<bool>? checkBoxes,
  }) {
    return GameCreateParam(
      title: title ?? this.title,
      startdate: startdate ?? this.startdate,
      starttime: starttime ?? this.starttime,
      enddate: enddate ?? this.enddate,
      endtime: endtime ?? this.endtime,
      min_invitation: min_invitation ?? this.min_invitation,
      max_invitation: max_invitation ?? this.max_invitation,
      info: info ?? this.info,
      fee: fee ?? this.fee,
      court: court ?? this.court,
      checkBoxes: checkBoxes ?? this.checkBoxes,
    );
  }

  Map<String, dynamic> toJson() => _$GameCreateParamToJson(this);

  @override
  List<Object?> get props => [
        title,
        startdate,
        starttime,
        enddate,
        endtime,
        min_invitation,
        max_invitation,
        info,
        fee,
        court,
      ];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class GameCourtParam extends Equatable {
  final String name;
  final String address;
  final String? address_detail;

  // final String? info;

  const GameCourtParam({
    required this.name,
    required this.address,
    this.address_detail,
    // this.info,
  });

  GameCourtParam copyWith({
    String? name,
    String? address,
    String? address_detail,
    String? info,
  }) {
    return GameCourtParam(
      name: name ?? this.name,
      address: address ?? this.address,
      address_detail: address_detail ?? this.address_detail,
      // info: info ?? this.info,
    );
  }

  Map<String, dynamic> toJson() => _$GameCourtParamToJson(this);

  factory GameCourtParam.fromJson(Map<String, dynamic> json) =>
      _$GameCourtParamFromJson(json);

  @override
  List<Object?> get props => [name, address, address_detail];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class GameUpdateParam extends Equatable {
  final int min_invitation;
  final int max_invitation;
  final String info;

  const GameUpdateParam({
    required this.min_invitation,
    required this.max_invitation,
    required this.info,
  });

  factory GameUpdateParam.fromForm({required GameCreateParam form}) {
    return GameUpdateParam(
      min_invitation: int.parse(form.min_invitation),
      max_invitation: int.parse(form.max_invitation),
      info: form.info,
    );
    // if (form.min_invitation.isNotEmpty && form.max_invitation.isNotEmpty) {
    //   return GameUpdateParam(
    //     min_invitation: int.parse(form.min_invitation),
    //     max_invitation: int.parse(form.max_invitation),
    //   );
    // } else if (form.info.isNotEmpty) {
    //   return GameUpdateParam(info: form.info);
    // } else {
    //
    // }
  }

  Map<String, dynamic> toJson() => _$GameUpdateParamToJson(this);

  factory GameUpdateParam.fromJson(Map<String, dynamic> json) =>
      _$GameUpdateParamFromJson(json);

  @override
  List<Object?> get props => [min_invitation, max_invitation];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class GameReviewParam extends Equatable {
  final int rating;
  final List<PlayerReviewTagType> tags;
  final String? comment;

  const GameReviewParam({
    required this.rating,
    this.comment,
    required this.tags,
  });

  GameReviewParam copyWith({
    int? rating,
    String? comment,
    List<PlayerReviewTagType>? tags,
  }) {
    return GameReviewParam(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => _$GameReviewParamToJson(this);

  factory GameReviewParam.fromJson(Map<String, dynamic> json) =>
      _$GameReviewParamFromJson(json);

  @override
  List<Object?> get props => [rating, comment, tags];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class GameParticipationParam extends Equatable {
  final int gameId;
  final PaymentMethodType type;
  @JsonKey(includeToJson: false)
  final List<bool> isCheckBoxes;

  const GameParticipationParam({
    required this.gameId,
    required this.type,
    required this.isCheckBoxes,
  });

  GameParticipationParam copyWith({
    int? gameId,
    PaymentMethodType? type,
    List<bool>? isCheckBoxes,
  }) {
    return GameParticipationParam(
        gameId: gameId ?? this.gameId,
        type: type ?? this.type,
        isCheckBoxes: isCheckBoxes ?? this.isCheckBoxes);
  }

  Map<String, dynamic> toJson() => _$GameParticipationParamToJson(this);

  factory GameParticipationParam.fromJson(Map<String, dynamic> json) =>
      _$GameParticipationParamFromJson(json);

  @override
  List<Object?> get props => [gameId, type];

  @override
  bool? get stringify => true;
}


@JsonSerializable()
class GameRefundParam extends Equatable {
  @JsonKey(includeToJson: false)
  final List<bool> isCheckBoxes;

  const GameRefundParam({
    required this.isCheckBoxes,
  });

  GameRefundParam copyWith({
    List<bool>? isCheckBoxes,
  }) {
    return GameRefundParam(
        isCheckBoxes: isCheckBoxes ?? this.isCheckBoxes);
  }

  Map<String, dynamic> toJson() => _$GameRefundParamToJson(this);

  factory GameRefundParam.fromJson(Map<String, dynamic> json) =>
      _$GameRefundParamFromJson(json);

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}