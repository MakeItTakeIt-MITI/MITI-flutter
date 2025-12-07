import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';

part 'game_pagination_param.g.dart';

@JsonSerializable()
class GamePaginationParam extends DefaultParam {
  final String? search;
  @JsonKey(name: "game_status")
  final List<GameStatusType>? gameStatus;
  final List<DistrictType>? province;

  GamePaginationParam({
    this.search,
    this.gameStatus,
    this.province,
  });

  @override
  List<Object?> get props => [search, gameStatus, province];

  Map<String, dynamic> toJson() => _$GamePaginationParamToJson(this);

  GamePaginationParam copyWith({
    String? search,
    List<GameStatusType>? gameStatus,
    List<DistrictType>? province,
    bool isAll = false,
  }) {
    if (isAll) {
      return GamePaginationParam(
        search: search ?? this.search,
        gameStatus: null,
        province: null,
      );
    }
    return GamePaginationParam(
      search: search ?? this.search,
      gameStatus: gameStatus ?? this.gameStatus,
      province: province ?? this.province,
    );
  }

  @override
  bool? get stringify => true;
}
