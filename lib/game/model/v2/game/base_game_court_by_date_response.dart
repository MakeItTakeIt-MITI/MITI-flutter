import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import 'base_game_response.dart';

part 'base_game_court_by_date_response.g.dart';

@JsonSerializable()
class BaseGameCourtByDateResponse extends Base {
  // The map where the key is a date string (YYYY-MM-DD) and the value is a list of games (BaseGameResponse)
  @JsonKey(name: "startdate")
  final String startDate;
  final List<BaseGameResponse> games;

  BaseGameCourtByDateResponse({
    required this.startDate,
    required this.games,
  });

  factory BaseGameCourtByDateResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseGameCourtByDateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseGameCourtByDateResponseToJson(this);

  BaseGameCourtByDateResponse copyWith({
    String? startDate,
    List<BaseGameResponse>? games,
  }) {
    return BaseGameCourtByDateResponse(
      games: games ?? this.games,
      startDate: startDate ?? this.startDate,
    );
  }
}
