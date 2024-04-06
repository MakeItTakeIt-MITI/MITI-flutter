import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_param.g.dart';

@JsonSerializable()
class GameListParam extends Equatable {
  final String? startdate;
  final String? starttime;

  const GameListParam({
    this.startdate,
    this.starttime,
  });

  Map<String, dynamic> toJson() => _$GameListParamToJson(this);

  @override
  List<Object?> get props => [startdate, starttime];

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
  final String court;

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
    String? court,
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

  @override
  List<Object?> get props => [name, address, address_detail];

  @override
  bool? get stringify => true;
}
