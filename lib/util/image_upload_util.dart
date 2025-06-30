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
  Future<void> pickMultipleImages() async {
    final picker = MultiImagePicker();

    try {
      final List<XFile>? images = await picker.pickMultipleImages();

      if (images != null && images.isNotEmpty) {
        // 이미지 타입별로 개수를 계산
        Map<String, int> imageTypeCounts = _countImagesByType(images);

        final param = FileUploadParam(
          category: FileCategoryType.post_image,
          png: imageTypeCounts['png'],
          jpeg: imageTypeCounts['jpeg'],
          webp: imageTypeCounts['webp'],
        );

        final result =
        await ref.read(fileUploadUrlProvider(param: param).future);

        if (result is ResponseModel) {
          final model = (result as ResponseModel<FileUploadUrlResponse>).data!;

          // 타입별로 URL 리스트를 합쳐서 순서대로 처리
          List<UploadUrlResponse> allUrls = [];
          allUrls.addAll(model.png);
          allUrls.addAll(model.jpeg);
          allUrls.addAll(model.webp);

          // 각 이미지를 개별적으로 처리
          for (int i = 0; i < images.length && i < allUrls.length; i++) {
            final url = allUrls[i];
            final imagePath = ImagePath(
              filePath: images[i].path,
              imageUrl: url.fileUrl,
              isLoading: true,
            );

            // 먼저 로딩 상태로 UI에 추가
            callback.addLocalImage(imagePath);

            // 개별 이미지 업로드 처리 (비동기)
            _uploadSingleImage(images[i], url, imagePath);
          }
        }
      }

      print('선택된 이미지 개수: ${images?.length}');
    } catch (e) {
      print('이미지 선택 실패: $e');
    }
  }

  /// 이미지 타입별 개수를 계산하는 헬퍼 메서드
  Map<String, int> _countImagesByType(List<XFile> images) {
    Map<String, int> counts = {'png': 0, 'jpeg': 0, 'webp': 0};

    for (XFile image in images) {
      String extension = getFileExtensionFromName(image).toLowerCase();

      switch (extension) {
        case 'png':
          counts['png'] = (counts['png'] ?? 0) + 1;
          break;
        case 'jpg':
        case 'jpeg':
          counts['jpeg'] = (counts['jpeg'] ?? 0) + 1;
          break;
        case 'webp':
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
            textColor: MITIColor.error);
      }
    } catch (e) {
      log("이미지 업로드 실패: $e");

      // 실패한 이미지 제거
      callback.removeLocalImage(imagePath);

      // 사용자에게 실패 알림
      FlashUtil.showFlash(context, '이미지 업로드에 실패했습니다.',
          textColor: MITIColor.error);
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
  final int? postId;
  final int? commentId;
  final int? replyCommentId;

  PostCommentFormImageUploadAdapter({
    required this.ref,
    this.postId,
    this.commentId,
    this.replyCommentId,
  });

  @override
  void addLocalImage(ImagePath imagePath) {
    ref
        .read(postCommentFormProvider(
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
      postId: postId,
      commentId: commentId,
      replyCommentId: replyCommentId,
    ).notifier)
        .updateLocalImageLoading(oldImagePath, newImagePath);
  }
}