import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../param/post_comment_param.dart';
part 'post_comment_form_provider.g.dart';

@riverpod
class PostCommentForm extends _$PostCommentForm {
  @override
  PostCommentParam build() {
    return const PostCommentParam(
      content: '',
      images: [],
    );
  }

  void update({
    String? content,
  }) {
    state = state.copyWith(
      content: content,
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
