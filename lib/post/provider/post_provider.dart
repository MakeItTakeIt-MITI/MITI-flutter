import 'dart:developer';

import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/post/provider/post_form_provider.dart';
import 'package:miti/post/provider/post_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../model/post_response.dart';
import '../repository/post_repository.dart';

part 'post_provider.g.dart';

@Riverpod(keepAlive: false)
class PostDetail extends _$PostDetail {
  @override
  BaseModel build({required int postId}) {
    get(postId: postId);
    return LoadingModel();
  }

  Future<void> get({required int postId}) async {
    final repository = ref.watch(postRepositoryProvider);
    repository.getPostDetail(postId: postId).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

  void toggleLike() {
    if (state is ResponseModel<PostResponse>) {
      final userId = ref.read(authProvider)?.id;
      final pState = (state as ResponseModel<PostResponse>);
      final data = pState.data!;
      final likes = pState.data!.likedUsers.toList();

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId ?? 0);
      }

      state = pState.copyWith(data: data.copyWith(likedUsers: likes));
    }
  }
}

@riverpod
Future<BaseModel> postCreate(PostCreateRef ref) async {
  final repository = ref.watch(postRepositoryProvider);
  final param = ref.watch(postFormProvider());
  return await repository.createPost(param: param).then<BaseModel>((value) {
    logger.i(value);
    ref.read(postPaginationProvider().notifier).getPostPagination();

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postUpdate(PostUpdateRef ref, {required int postId}) async {
  final repository = ref.watch(postRepositoryProvider);
  final param = ref.watch(postFormProvider(postId: postId));
  return await repository
      .patchPost(param: param, postId: postId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(postDetailProvider(postId: postId).notifier).get(postId: postId);
    ref.read(postPaginationProvider().notifier).getPostPagination(forceRefetch: true);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postDelete(PostDeleteRef ref, {required int postId}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository.deletePost(postId: postId).then<BaseModel>((value) {
    logger.i(value);
    ref.read(postPaginationProvider().notifier).getPostPagination(forceRefetch: true);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postLike(PostLikeRef ref, {required int postId}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository.postLike(postId: postId).then<BaseModel>((value) {
    logger.i(value);
    ref.read(postDetailProvider(postId: postId).notifier).toggleLike();
    ref.read(postPaginationProvider().notifier).getPostPagination(forceRefetch: true);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postUnLike(PostUnLikeRef ref, {required int postId}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository.deleteLike(postId: postId).then<BaseModel>((value) {
    logger.i(value);
    ref.read(postDetailProvider(postId: postId).notifier).toggleLike();
    ref.read(postPaginationProvider().notifier).getPostPagination(forceRefetch: true);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
