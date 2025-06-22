import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/entity_enum.dart';

final selectedPostCategoryProvider = StateProvider.autoDispose<PostCategoryType>((ref) {
  return PostCategoryType.all;
});