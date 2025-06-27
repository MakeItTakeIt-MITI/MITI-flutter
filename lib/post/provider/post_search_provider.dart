import 'package:miti/post/param/post_search_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/entity_enum.dart';

part 'post_search_provider.g.dart';

@riverpod
class PostSearch extends _$PostSearch {
  @override
  PostSearchParam build(bool isSearch) {
    return const PostSearchParam();
  }

  PostSearchParam update({
    String? search,
    PostCategoryType? category,
    bool isAll = false,
  }) {
    state = state.copyWith(
      search: search,
      category: category,
      isAll: isAll,
    );
    return state;
  }
}
