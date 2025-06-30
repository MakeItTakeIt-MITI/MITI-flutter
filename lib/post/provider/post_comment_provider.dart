import 'dart:developer';

import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/post/provider/post_comment_form_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../model/base_post_comment_response.dart';
import '../repository/post_repository.dart';

part 'post_comment_provider.g.dart';

@Riverpod(keepAlive: false)
class PostCommentList extends _$PostCommentList {
  @override
  BaseModel build({required int postId}) {
    get(postId: postId);
    return LoadingModel();
  }

  Future<void> get({required int postId}) async {
    final repository = ref.watch(postRepositoryProvider);
    repository.getPostComments(postId: postId).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

  void toggleLike({required int commentId}) {
    if (state is ResponseListModel<BasePostCommentResponse>) {
      final userId = ref.read(authProvider)?.id;
      final pState = (state as ResponseListModel<BasePostCommentResponse>);
      final data = pState.data!;

      final likes =
          data.singleWhere((c) => c.id == commentId).likedUsers.toList();

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId ?? 0);
      }
      final updateData = data.map((e) {
        if (e.id == commentId) {
          return e.copyWith(likedUsers: likes);
        } else {
          return e;
        }
      }).toList();
      state = pState.copyWith(data: updateData);
    }
  }

  void replyToggleLike({required int commentId, required int replyCommentId}) {
    if (state is ResponseListModel<BasePostCommentResponse>) {
      final userId = ref.read(authProvider)?.id;
      final pState = (state as ResponseListModel<BasePostCommentResponse>);
      final data = pState.data!;
      final comment = data.singleWhere((c) => c.id == commentId);
      final replyComment =
          comment.replyComments.singleWhere((e) => e.id == replyCommentId);

      final likes = replyComment.likedUsers.toList();

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId ?? 0);
      }

      final updateReplyComments = comment.replyComments.map((e) {
        if (e.id == replyCommentId) {
          return e.copyWith(likedUsers: likes);
        } else {
          return e;
        }
      }).toList();

      final updateData = data.map((e) {
        if (e.id == commentId) {
          return e.copyWith(replyComments: updateReplyComments);
        } else {
          return e;
        }
      }).toList();

      state = pState.copyWith(
        data: updateData,
      );
    }
  }
}

@Riverpod(keepAlive: false)
class PostCommentDetail extends _$PostCommentDetail {
  @override
  BaseModel build({required int postId, required int commentId}) {
    get(postId: postId, commentId: commentId);
    return LoadingModel();
  }

  Future<void> get({required int postId, required int commentId}) async {
    log("comment 상세 조회");
    final repository = ref.watch(postRepositoryProvider);
    repository
        .getPostCommentDetail(postId: postId, commentId: commentId)
        .then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

  void update(ResponseModel<BasePostCommentResponse> newState) {
    state = newState;
  }

  void toggleLike({required int commentId}) {
    if (state is ResponseModel<BasePostCommentResponse>) {
      final userId = ref.read(authProvider)?.id;
      final pState = (state as ResponseModel<BasePostCommentResponse>);
      final data = pState.data!;

      final likes = data.likedUsers.toList();

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId ?? 0);
      }

      state = pState.copyWith(data: data.copyWith(likedUsers: likes));

      // // 게시글 상세에서 게시글 댓글 리스트 갱신
      // ref
      //     .read(postCommentListProvider(postId: postId).notifier)
      //     .toggleLike(commentId: commentId);
    }
  }

  void replyToggleLike({required int replyCommentId}) {
    if (state is ResponseModel<BasePostCommentResponse>) {
      final userId = ref.read(authProvider)?.id;
      final pState = (state as ResponseModel<BasePostCommentResponse>);
      final data = pState.data!;
      final likes = data.replyComments
          .singleWhere((e) => e.id == replyCommentId)
          .likedUsers
          .toList();

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId ?? 0);
      }

      final updateReplyComments = data.replyComments.map((e) {
        if (e.id == replyCommentId) {
          return e.copyWith(likedUsers: likes);
        } else {
          return e;
        }
      }).toList();

      state = pState.copyWith(
        data: data.copyWith(
          replyComments: updateReplyComments,
        ),
      );
    }
  }
}

@riverpod
Future<BaseModel> postCommentCreate(PostCommentCreateRef ref,
    {required int postId}) async {
  final repository = ref.watch(postRepositoryProvider);
  final param = ref.watch(postCommentFormProvider(postId: postId));
  return await repository
      .createPostComment(param: param, postId: postId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref
        .read(postCommentListProvider(postId: postId).notifier)
        .get(postId: postId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postCommentUpdate(PostCommentUpdateRef ref,
    {required int postId, required int commentId}) async {
  final repository = ref.watch(postRepositoryProvider);
  final param = ref.watch(postCommentFormProvider(
    isEdit: true,
    postId: postId,
    commentId: commentId,
  ));
  return await repository
      .patchPostComment(param: param, postId: postId, commentId: commentId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref
        .read(postCommentListProvider(postId: postId).notifier)
        .get(postId: postId);
    ref
        .read(postCommentDetailProvider(postId: postId, commentId: commentId)
            .notifier)
        .get(postId: postId, commentId: commentId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postCommentDelete(PostCommentDeleteRef ref,
    {required int postId, required int commentId}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository
      .deletePostComment(postId: postId, commentId: commentId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref
        .read(postCommentListProvider(postId: postId).notifier)
        .get(postId: postId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postCommentLike(PostCommentLikeRef ref,
    {required int postId,
    required int commentId,
    bool fromCommentDetail = false}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository
      .postCommentLike(postId: postId, commentId: commentId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref
        .read(postCommentListProvider(postId: postId).notifier)
        .toggleLike(commentId: commentId);

    if (fromCommentDetail) {
      ref
          .read(postCommentDetailProvider(postId: postId, commentId: commentId)
              .notifier)
          .toggleLike(commentId: commentId);
    }

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postCommentUnLike(PostCommentUnLikeRef ref,
    {required int postId,
    required int commentId,
    bool fromCommentDetail = false}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository
      .deleteCommentLike(postId: postId, commentId: commentId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref
        .read(postCommentListProvider(postId: postId).notifier)
        .toggleLike(commentId: commentId);

    if (fromCommentDetail) {
      ref
          .read(postCommentDetailProvider(postId: postId, commentId: commentId)
              .notifier)
          .toggleLike(commentId: commentId);
    }

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
