import 'package:miti/common/model/entity_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../param/post_form_param.dart';

part 'post_form_provider.g.dart';

@riverpod
class PostForm extends _$PostForm {
  @override
  PostFormParam build() {
    return const PostFormParam(
        title: '',
        content: '',
        category: PostCategoryType.all,
        images: [],
        isAnonymous: false);
  }

  void update(
      {String? title,
      String? content,
      PostCategoryType? category,
      bool? isAnonymous}) {
    state = state.copyWith(
      title: title,
      content: content,
      category: category,
      isAnonymous: isAnonymous,
    );
  }

  void addImage(String image) {
    List<String> images = state.images.toList();
    images.add(image);
    state = state.copyWith(images: images);
  }

  void removeImage(String image) {
    List<String> images = state.images.toList();
    images.remove(image);
    state = state.copyWith(images: images);
  }
}
