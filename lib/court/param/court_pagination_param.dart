import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';

part 'court_pagination_param.g.dart';

@JsonSerializable()
class CourtPaginationParam extends DefaultParam {
  final String? search;
  final DistrictType? district;

  CourtPaginationParam({
    this.search,
    this.district,
  });

  @override
  List<Object?> get props => [search, district];

  @override
  Map<String, dynamic> toJson() => _$CourtPaginationParamToJson(this);

  CourtPaginationParam copyWith({
    String? search,
    DistrictType? district,
    bool isAll = false,
  }) {
    if (isAll) {
      return CourtPaginationParam(
        search: search ?? this.search,
        district: null,
      );
    }
    return CourtPaginationParam(
      search: search ?? this.search,
      district: district ?? this.district,
    );
  }

  @override
  bool? get stringify => true;
}
