import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_param.g.dart';

@JsonSerializable()
class GameListParam extends Equatable {
  final String? startdate;

  // final String? starttime;

  const GameListParam({
    this.startdate,
    // this.starttime,
  });

  Map<String, dynamic> toJson() => _$GameListParamToJson(this);

  @override
  List<Object?> get props => [startdate];

  @override
  bool? get stringify => true;
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
  final String address_detail;

  const GameCourtParam({
    required this.name,
    required this.address,
    required this.address_detail,
  });

  GameCourtParam copyWith({
    String? name,
    String? address,
    String? address_detail,
  }) {
    return GameCourtParam(
      name: name ?? this.name,
      address: address ?? this.address,
      address_detail: address_detail ?? this.address_detail,
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
  final int? rating;
  final String comment;

  const GameReviewParam({
    required this.rating,
    required this.comment,
  });

  GameReviewParam copyWith({
    int? rating,
    String? comment,
  }) {
    return GameReviewParam(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toJson() => _$GameReviewParamToJson(this);

  factory GameReviewParam.fromJson(Map<String, dynamic> json) =>
      _$GameReviewParamFromJson(json);

  @override
  List<Object?> get props => [rating, comment];

  @override
  bool? get stringify => true;
}
