import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/post/provider/post_provider.dart';
import 'package:miti/util/model/image_path.dart';
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
        final localImages = model.images.map((e)=> ImagePath(imageUrl: e)).toList();

        return PostFormParam(
          title: model.title,
          content: model.content,
          category: model.category,
          images: [],
          isAnonymous: model.isAnonymous,
          localImages: localImages
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
        e.filePath == imagePath.filePath || e.imageUrl == imagePath.imageUrl);

    localImages.remove(image);

    List<String> images = state.images.toList();
    images.removeWhere((i) => i == image.imageUrl);
    state = state.copyWith(localImages: localImages, images: images);
  }

  // 특정 이미지의 로딩 상태를 업데이트하는 메서드
  void updateLocalImageLoading(ImagePath oldImagePath, ImagePath newImagePath) {
    List<ImagePath> localImages = state.localImages.toList();

    // 기존 이미지를 찾아서 새로운 이미지로 교체
    final index = localImages.indexWhere((img) =>
    img.filePath == oldImagePath.filePath &&
        img.imageUrl == oldImagePath.imageUrl
    );

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
