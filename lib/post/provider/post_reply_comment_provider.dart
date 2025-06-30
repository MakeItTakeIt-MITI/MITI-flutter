import 'package:miti/post/provider/post_comment_form_provider.dart';
import 'package:miti/post/provider/post_comment_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../repository/post_repository.dart';

part 'post_reply_comment_provider.g.dart';

@riverpod
Future<BaseModel> postReplyCommentCreate(PostReplyCommentCreateRef ref,
    {required int postId, required int commentId}) async {
  final repository = ref.watch(postRepositoryProvider);
  final param =
      ref.watch(postCommentFormProvider(postId: postId, commentId: commentId));

  return await repository
      .createPostReplyComment(
          param: param, postId: postId, commentId: commentId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref
        .read(postCommentDetailProvider(postId: postId, commentId: commentId)
            .notifier)
        .update(value);

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
Future<BaseModel> postReplyCommentUpdate(PostReplyCommentUpdateRef ref,
    {required int postId,
    required int commentId,
    required int replyCommentId}) async {
  final repository = ref.watch(postRepositoryProvider);
  final param = ref.watch(postCommentFormProvider(
      isEdit: true,
      postId: postId,
      commentId: commentId,
      replyCommentId: replyCommentId));
  return await repository
      .patchPostReplyComment(
          param: param,
          postId: postId,
          commentId: commentId,
          replyCommentId: replyCommentId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref
        .read(postCommentDetailProvider(postId: postId, commentId: commentId)
            .notifier)
        .update(value);
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
Future<BaseModel> postReplyCommentDelete(PostReplyCommentDeleteRef ref,
    {required int postId,
    required int commentId,
    required int replyCommentId}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository
      .deletePostReplyComment(
          postId: postId, commentId: commentId, replyCommentId: replyCommentId)
      .then<BaseModel>((value) {
    logger.i(value);
    // todo api 호출이 아닌 메모리만 삭제
    ref
        .read(postCommentDetailProvider(postId: postId, commentId: commentId)
            .notifier)
        .get(postId: postId, commentId: commentId);
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
Future<BaseModel> postReplyCommentLike(PostReplyCommentLikeRef ref,
    {required int postId,
    required int commentId,
    required int replyCommentId,
    bool fromDetail = false}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository
      .postReplyCommentLike(
          postId: postId, commentId: commentId, replyCommentId: replyCommentId)
      .then<BaseModel>((value) {
    logger.i(value);
    if (fromDetail) {
      // 댓글 상세 위치일 때 상세 갱신
      ref
          .read(postCommentDetailProvider(postId: postId, commentId: commentId)
              .notifier)
          .replyToggleLike(replyCommentId: replyCommentId);
    }
    ref
        .read(postCommentListProvider(postId: postId).notifier)
        .replyToggleLike(commentId: commentId, replyCommentId: replyCommentId);

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> postReplyCommentUnLike(PostReplyCommentUnLikeRef ref,
    {required int postId,
    required int commentId,
    required int replyCommentId,
    bool fromDetail = false}) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository
      .deleteReplyCommentLike(
          postId: postId, commentId: commentId, replyCommentId: replyCommentId)
      .then<BaseModel>((value) {
    logger.i(value);
    if (fromDetail) {
      ref
          .read(postCommentDetailProvider(postId: postId, commentId: commentId)
              .notifier)
          .replyToggleLike(replyCommentId: replyCommentId);
    }

    ref
        .read(postCommentListProvider(postId: postId).notifier)
        .replyToggleLike(commentId: commentId, replyCommentId: replyCommentId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
