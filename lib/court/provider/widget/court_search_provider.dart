import 'package:miti/court/param/court_pagination_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/entity_enum.dart';

part 'court_search_provider.g.dart';

@riverpod
class CourtSearch extends _$CourtSearch {
  @override
  CourtPaginationParam build() {
    return CourtPaginationParam();
  }

  CourtPaginationParam update({
    String? search,
    DistrictType? district,
    bool isAll = false,
  }) {
    state = state.copyWith(
      search: search ,
      district: district,
      isAll: isAll,
    );
    return state;
  }
}
