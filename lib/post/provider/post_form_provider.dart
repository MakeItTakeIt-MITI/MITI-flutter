import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/post/provider/post_comment_provider.dart';
import 'package:miti/post/provider/post_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/post_response.dart';
import '../param/post_form_param.dart';

part 'post_form_provider.g.dart';

@riverpod
class PostForm extends _$PostForm {
  @override
  PostFormParam build({int? postId}) {
    if (postId != null) {
      final result = ref.read(postDetailProvider(postId: postId));
      if (result is ResponseModel<PostResponse>) {
        final model = (result).data!;

        return PostFormParam(
          title: model.title,
          content: model.content,
          category: model.category,
          images: model.images,
          isAnonymous: model.isAnonymous,
        );
      }
    }

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
