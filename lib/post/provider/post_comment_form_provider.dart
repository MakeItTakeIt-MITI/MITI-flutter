import 'package:bootpay/bootpay_webview.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/post/provider/post_comment_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/base_post_comment_response.dart';
import '../param/post_comment_param.dart';

import 'package:collection/collection.dart';

part 'post_comment_form_provider.g.dart';

@riverpod
class PostCommentForm extends _$PostCommentForm {
  @override
  PostCommentParam build({
    int? postId,
    int? commentId,
    int? replyCommentId,
  }) {
    if (replyCommentId != null && postId != null && commentId != null) {
      final result = ref.read(postCommentListProvider(postId: postId));
      final model =
          (result as ResponseListModel<BasePostCommentResponse>).data!;
      final comment = model.firstWhereOrNull((c) => c.id == commentId);
      if (comment == null) {
        return const PostCommentParam(content: '', images: []);
      }

      final replyComment = comment.replyComments
          .firstWhereOrNull((rc) => rc.id == replyCommentId);

      return PostCommentParam(
          content: replyComment?.content ?? '',
          images: replyComment?.images ?? []);
    } else if (postId != null && commentId != null) {
      final result = ref.read(postCommentListProvider(postId: postId));
      final model =
          (result as ResponseListModel<BasePostCommentResponse>).data!;
      final comment = model.firstWhereOrNull((c) => c.id == commentId);
      return PostCommentParam(
          content: comment?.content ?? '', images: comment?.images ?? []);
    }

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
