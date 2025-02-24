import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';

part 'game_pagination_param.g.dart';

@JsonSerializable()
class GamePaginationParam extends DefaultParam {
  final String? title;
  final DistrictType? district;

  GamePaginationParam({
    this.title,
    this.district,
  });

  @override
  List<Object?> get props => [title, district];

  Map<String, dynamic> toJson() => _$GamePaginationParamToJson(this);

  GamePaginationParam copyWith({
    String? search,
    DistrictType? district,
    bool isAll = false,
  }) {
    if (isAll) {
      return GamePaginationParam(
        title: search ?? this.title,
        district: null,
      );
    }
    return GamePaginationParam(
      title: search ?? this.title,
      district: district ?? this.district,
    );
  }

  @override
  bool? get stringify => true;
}
