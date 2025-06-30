import 'package:collection/collection.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/post/provider/post_comment_provider.dart';
import 'package:miti/util/model/image_path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/base_post_comment_response.dart';
import '../param/post_comment_param.dart';

part 'post_comment_form_provider.g.dart';

@riverpod
class PostCommentForm extends _$PostCommentForm {
  @override
  PostCommentParam build({
    bool isEdit = false,
    int? postId,
    int? commentId,
    int? replyCommentId,
  }) {
    // 대댓글 수정인 경우
    if (replyCommentId != null &&
        postId != null &&
        commentId != null &&
        isEdit) {
      final result = ref.read(postCommentListProvider(postId: postId));
      final model =
          (result as ResponseListModel<BasePostCommentResponse>).data!;
      final comment = model.firstWhereOrNull((c) => c.id == commentId);
      if (comment == null) {
        return const PostCommentParam(content: '', images: []);
      }

      final replyComment = comment.replyComments
          .firstWhereOrNull((rc) => rc.id == replyCommentId);

      // 기존 이미지들을 localImages로 변환
      final localImages = (replyComment?.images ?? [])
          .map((e) => ImagePath(imageUrl: e))
          .toList();


      return PostCommentParam(
          content: replyComment?.content ?? '',
          images: replyComment?.images ?? [],
          localImages: localImages);
    } else if (postId != null && commentId != null && isEdit) {
      // 댓글 수정인 경우
      final result = ref.read(postCommentListProvider(postId: postId));
      final model =
          (result as ResponseListModel<BasePostCommentResponse>).data!;
      final comment = model.firstWhereOrNull((c) => c.id == commentId);

      // 기존 이미지들을 localImages로 변환
      final localImages =
          (comment?.images ?? []).map((e) => ImagePath(imageUrl: e)).toList();

      return PostCommentParam(
          content: comment?.content ?? '',
          images: comment?.images ?? [],
          localImages: localImages);
    }

    return const PostCommentParam(
      content: '',
      images: [],
      localImages: [],
    );
  }

  void update({
    String? content,
  }) {
    state = state.copyWith(
      content: content,
    );
  }

  // 기존 메서드들
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

  // PostFormProvider와 동일한 로컬 이미지 관리 메서드들 추가
  void setImages() {
    final images =
        state.localImages.map((e) => e.imageUrl).whereType<String>().toList();
    state = state.copyWith(images: images);
  }

  // 로컬 이미지 추가
  void addLocalImage(ImagePath imagePath) {
    List<ImagePath> images = state.localImages.toList();
    images.add(imagePath);
    state = state.copyWith(localImages: images);
  }

  // 로컬 이미지 삭제
  void removeLocalImage(ImagePath imagePath) {
    List<ImagePath> localImages = state.localImages.toList();
    final image = localImages.singleWhere((e) =>
        (e.filePath != null && e.filePath == imagePath.filePath) ||
        (e.imageUrl != null && e.imageUrl == imagePath.imageUrl));

    localImages.remove(image);

    List<String> images = state.images.toList();
    images.removeWhere((i) => image.imageUrl != null && i == image.imageUrl);
    state = state.copyWith(localImages: localImages, images: images);
  }

  // 특정 이미지의 로딩 상태를 업데이트하는 메서드
  void updateLocalImageLoading(ImagePath oldImagePath, ImagePath newImagePath) {
    List<ImagePath> localImages = state.localImages.toList();

    // 기존 이미지를 찾아서 새로운 이미지로 교체
    final index = localImages.indexWhere((img) =>
        img.filePath == oldImagePath.filePath &&
        img.imageUrl == oldImagePath.imageUrl);

    if (index != -1) {
      localImages[index] = newImagePath;

      // 업로드 완료된 경우 images 배열에도 추가
      if (!newImagePath.isLoading && newImagePath.imageUrl != null) {
        List<String> images = state.images.toList();
        if (!images.contains(newImagePath.imageUrl)) {
          images.add(newImagePath.imageUrl!);
        }
        state = state.copyWith(localImages: localImages, images: images);
      } else {
        state = state.copyWith(localImages: localImages);
      }
    }
  }

  void reset() {
    state = const PostCommentParam(
      content: '',
      images: [],
      localImages: [],
    );
  }
}
