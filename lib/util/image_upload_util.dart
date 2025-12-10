import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miti/common/component/defalut_flashbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/dio/provider/dio_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/util/image_picker.dart';
import 'package:miti/util/model/file_upload_url_response.dart';
import 'package:miti/util/model/image_path.dart';
import 'package:miti/util/model/upload_url_response.dart';
import 'package:miti/util/param/file_upload_param.dart';
import 'package:miti/util/provider/image_upload_url_provider.dart';
import 'package:miti/util/string_extension.dart';

import '../post/provider/post_comment_form_provider.dart';
import '../post/provider/post_form_provider.dart';

/// 이미지 업로드를 위한 콜백 인터페이스
abstract class ImageUploadCallback {
  void addLocalImage(ImagePath imagePath);

  void removeLocalImage(ImagePath imagePath);

  void updateLocalImageLoading(ImagePath oldImagePath, ImagePath newImagePath);
}

/// 이미지 업로드 공통 유틸리티 클래스
class ImageUploadUtil {
  final WidgetRef ref;
  final BuildContext context;
  final ImageUploadCallback callback;

  ImageUploadUtil({
    required this.ref,
    required this.context,
    required this.callback,
  });

  /// 여러 이미지 선택 및 업로드
  Future<void> pickMultipleImages(
      {int limit = 10, required FileCategoryType category}) async {
    // todo 동일한 이미지 올릴 시 제거 또는 id 를 추가해서 변경
    final picker = MultiImagePicker();

    try {
      final List<XFile>? images = await picker.pickMultipleImages(limit: limit);

      if (images != null && images.isNotEmpty) {
        // 이미지 타입별로 개수를 계산
        Map<String, int> imageTypeCounts = _countImagesByType(images);

        final param = FileUploadParam(
          category: category,
          png: imageTypeCounts['png'],
          jpeg: imageTypeCounts['jpeg'],
          webp: imageTypeCounts['webp'],
        );

        final result =
            await ref.read(fileUploadUrlProvider(param: param).future);

        if (result is ResponseModel) {
          final model = (result as ResponseModel<FileUploadUrlResponse>).data!;

          // 타입별로 이미지 분류 및 URL 매칭
          _processImagesByType(images, model);
        }
      }

      print('선택된 이미지 개수: ${images?.length}');
    } catch (e) {
      print('이미지 선택 실패: $e');
    }
  }

  /// 타입별로 이미지를 분류하고 각각 맞는 URL로 업로드
  void _processImagesByType(List<XFile> images, FileUploadUrlResponse model) {
    // 타입별로 이미지 분류
    Map<String, List<XFile>> imagesByType = {
      'png': [],
      'jpeg': [],
      'webp': [],
    };

    for (XFile image in images) {
      String extension = getFileExtensionFromName(image).toLowerCase();

      switch (extension) {
        case '.png':
          imagesByType['png']!.add(image);
          break;
        case '.jpg':
        case '.jpeg':
          imagesByType['jpeg']!.add(image);
          break;
        case '.webp':
          imagesByType['webp']!.add(image);
          break;
        default:
          // 기본적으로 jpeg로 처리
          imagesByType['jpeg']!.add(image);
          break;
      }
    }

    // 각 타입별로 해당하는 URL과 매칭하여 업로드
    _uploadImagesByType('png', imagesByType['png']!, model.png);
    _uploadImagesByType('jpeg', imagesByType['jpeg']!, model.jpeg);
    _uploadImagesByType('webp', imagesByType['webp']!, model.webp);
  }

  /// 특정 타입의 이미지들을 해당 타입의 URL들로 업로드
  void _uploadImagesByType(
      String type, List<XFile> images, List<UploadUrlResponse> urls) {
    log("Uploading $type images: ${images.length} files with ${urls.length} URLs");

    for (int i = 0; i < images.length && i < urls.length; i++) {
      final image = images[i];
      final url = urls[i];

      final imagePath = ImagePath(
        filePath: image.path,
        imageUrl: url.fileUrl,
        isLoading: true,
      );

      // 먼저 로딩 상태로 UI에 추가
      callback.addLocalImage(imagePath);

      // 개별 이미지 업로드 처리 (비동기)
      _uploadSingleImage(image, url, imagePath);
    }
  }

  /// 이미지 타입별 개수를 계산하는 헬퍼 메서드
  Map<String, int> _countImagesByType(List<XFile> images) {
    Map<String, int> counts = {'png': 0, 'jpeg': 0, 'webp': 0};

    for (XFile image in images) {
      String extension = getFileExtensionFromName(image).toLowerCase();

      switch (extension) {
        case '.png':
          counts['png'] = (counts['png'] ?? 0) + 1;
          break;
        case '.jpg':
        case '.jpeg':
          counts['jpeg'] = (counts['jpeg'] ?? 0) + 1;
          break;
        case '.webp':
          counts['webp'] = (counts['webp'] ?? 0) + 1;
          break;
        default:
          // 기본적으로 jpeg로 처리
          counts['jpeg'] = (counts['jpeg'] ?? 0) + 1;
          break;
      }
    }

    return counts;
  }

  /// 개별 이미지 업로드를 처리하는 메서드
  Future<void> _uploadSingleImage(
      XFile image, UploadUrlResponse url, ImagePath imagePath) async {
    try {
      final dio = ref.read(dioProvider);
      final imageBytes = await image.readAsBytes();

      // 확장자 확인
      final extension = getFileExtensionFromName(image);

      // 확장자에 따른 Content-Type 설정
      final contentType = getContentTypeFromExtension(extension);

      final options = Options(contentType: contentType);

      log("request url = ${url.uploadUrl} contentType = ${contentType}");

      // 실제 업로드 요청
      final response = await dio.put(
        url.uploadUrl,
        options: options,
        data: imageBytes,
      );

      // 업로드 성공 시 로딩 상태 해제
      if (response.statusCode == 200) {
        final updatedImagePath = imagePath.copyWith(isLoading: false);
        callback.updateLocalImageLoading(imagePath, updatedImagePath);

        log("이미지 업로드 성공: ${imagePath.filePath}");
      } else {
        // 업로드 실패 시 해당 이미지 제거
        callback.removeLocalImage(imagePath);

        // 사용자에게 실패 알림
        FlashUtil.showFlash(context, '이미지 업로드에 실패했습니다.',
            textColor: V2MITIColor.red5);
      }
    } catch (e) {
      log("이미지 업로드 실패: $e");

      // 실패한 이미지 제거
      callback.removeLocalImage(imagePath);

      // 사용자에게 실패 알림
      FlashUtil.showFlash(context, '이미지 업로드에 실패했습니다.',
          textColor: V2MITIColor.red5);
    }
  }
}

/// PostFormProvider용 콜백 어댑터
class PostFormImageUploadAdapter implements ImageUploadCallback {
  final WidgetRef ref;
  final int? postId;

  PostFormImageUploadAdapter({
    required this.ref,
    this.postId,
  });

  @override
  void addLocalImage(ImagePath imagePath) {
    ref
        .read(postFormProvider(postId: postId).notifier)
        .addLocalImage(imagePath);
  }

  @override
  void removeLocalImage(ImagePath imagePath) {
    ref
        .read(postFormProvider(postId: postId).notifier)
        .removeLocalImage(imagePath);
  }

  @override
  void updateLocalImageLoading(ImagePath oldImagePath, ImagePath newImagePath) {
    ref
        .read(postFormProvider(postId: postId).notifier)
        .updateLocalImageLoading(oldImagePath, newImagePath);
  }
}

/// PostCommentFormProvider용 콜백 어댑터
class PostCommentFormImageUploadAdapter implements ImageUploadCallback {
  final WidgetRef ref;
  final bool isEdit;
  final int? postId;
  final int? commentId;
  final int? replyCommentId;

  PostCommentFormImageUploadAdapter({
    required this.ref,
    this.isEdit = false,
    this.postId,
    this.commentId,
    this.replyCommentId,
  });

  @override
  void addLocalImage(ImagePath imagePath) {
    ref
        .read(postCommentFormProvider(
          isEdit: isEdit,
          postId: postId,
          commentId: commentId,
          replyCommentId: replyCommentId,
        ).notifier)
        .addLocalImage(imagePath);
  }

  @override
  void removeLocalImage(ImagePath imagePath) {
    ref
        .read(postCommentFormProvider(
          isEdit: isEdit,
          postId: postId,
          commentId: commentId,
          replyCommentId: replyCommentId,
        ).notifier)
        .removeLocalImage(imagePath);
  }

  @override
  void updateLocalImageLoading(ImagePath oldImagePath, ImagePath newImagePath) {
    ref
        .read(postCommentFormProvider(
          isEdit: isEdit,
          postId: postId,
          commentId: commentId,
          replyCommentId: replyCommentId,
        ).notifier)
        .updateLocalImageLoading(oldImagePath, newImagePath);
  }
}
