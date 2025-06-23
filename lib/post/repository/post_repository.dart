import 'package:dio/dio.dart' hide Headers;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/provider/dio_provider.dart';
import '../model/base_post_comment_response.dart';
import '../model/popular_post_list_response.dart';
import '../model/popular_search_word_list_response.dart';
import '../model/post_response.dart';
import '../param/post_comment_param.dart';
import '../param/post_form_param.dart';

part 'post_repository.g.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return PostRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class PostRepository {
  factory PostRepository(Dio dio, {String baseUrl}) = _PostRepository;

  /// 게시글 작성 API
  @Headers({'token': 'true'})
  @POST('/posts/{postId}')
  Future<ResponseModel<PostResponse>> createPost(
      {@Body() required PostFormParam param});

  /// 게시글 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/posts/{postId}')
  Future<ResponseModel<PostResponse>> getPostDetail(
      {@Path() required int postId});

  /// 게시글 수정 API
  @Headers({'token': 'true'})
  @PATCH('/posts/{postId}')
  Future<ResponseModel<PostResponse>> patchPost({
    @Path() required int postId,
    @Body() required PostFormParam param,
  });

  /// 게시글 삭제 API
  @Headers({'token': 'true'})
  @DELETE('/posts/{postId}')
  Future<ResponseModel<PostResponse>> deletePost({
    @Path() required int postId,
  });

  /// 인기 게시글 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/posts/popular-posts')
  Future<ResponseListModel<PopularPostListResponse>> getPopularPosts();

  /// 인기 게시글 검색어 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/posts/popular-search-word')
  Future<ResponseListModel<PopularSearchWordListResponse>> getPopularSearch();

  /// 게시글 댓글 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/posts/{postId}/comments')
  Future<ResponseListModel<BasePostCommentResponse>> getPostComments(
      {@Path() required int postId});

  /// 게시글 댓글 작성 API
  @Headers({'token': 'true'})
  @POST('/posts/{postId}/comments')
  Future<ResponseListModel<BasePostCommentResponse>> createPostComment({
    @Path() required int postId,
    @Body() required PostCommentParam param,
  });

  /// 게시글 댓글 수정 API
  @Headers({'token': 'true'})
  @PATCH('/posts/{postId}/comments/{commentId}')
  Future<ResponseListModel<BasePostCommentResponse>> patchPostComment({
    @Path() required int postId,
    @Path() required int commentId,
    @Body() required PostCommentParam param,
  });

  /// 게시글 댓글 삭제 API
  @Headers({'token': 'true'})
  @DELETE('/posts/{postId}/comments/{commentId}')
  Future<ResponseListModel<BasePostCommentResponse>> deletePostComment({
    @Path() required int postId,
    @Path() required int commentId,
  });

  /// 게시글 댓글 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/posts/{postId}/comments/{commentId}')
  Future<ResponseModel<BasePostCommentResponse>> getPostCommentDetail({
    @Path() required int postId,
    @Path() required int commentId,
  });

  /// 게시글 대댓글 작성 API
  @Headers({'token': 'true'})
  @POST('/posts/{postId}/comments/{commentId}/reply-comments')
  Future<ResponseModel<BasePostCommentResponse>> createPostReplyComment({
    @Path() required int postId,
    @Path() required int commentId,
    @Body() required PostCommentParam param,
  });

  /// 게시글 대댓글 수정 API
  @Headers({'token': 'true'})
  @PATCH('/posts/{postId}/comments/{commentId}/reply-comments/{replyCommentId}')
  Future<ResponseModel<BasePostCommentResponse>> patchPostReplyComment({
    @Path() required int postId,
    @Path() required int commentId,
    @Path() required int replyCommentId,
    @Body() required PostCommentParam param,
  });

  /// 게시글 대댓글 삭제 API
  @Headers({'token': 'true'})
  @DELETE(
      '/posts/{postId}/comments/{commentId}/reply-comments/{replyCommentId}')
  Future<ResponseModel<BasePostCommentResponse>> deletePostReplyComment({
    @Path() required int postId,
    @Path() required int commentId,
    @Path() required int replyCommentId,
  });

  /// 게시글 좋아요 API
  @Headers({'token': 'true'})
  @POST('/posts/{postId}/likes')
  Future<ResponseModel<BasePostCommentResponse>> postLike(
      {@Path() required int postId});

  /// 게시글 좋아요 취소 API
  @Headers({'token': 'true'})
  @DELETE('/posts/{postId}/likes')
  Future<ResponseModel<BasePostCommentResponse>> deleteLike(
      {@Path() required int postId});

  /// 게시글 댓글 좋아요 API
  @Headers({'token': 'true'})
  @POST('/posts/{postId}/comments/{commentId}/likes')
  Future<CompletedModel> postCommentLike({
    @Path() required int postId,
    @Path() required int commentId,
  });

  /// 게시글 댓글 좋아요 취소 API
  @Headers({'token': 'true'})
  @DELETE('/posts/{postId}/comments/{commentId}/likes')
  Future<CompletedModel> deleteCommentLike({
    @Path() required int postId,
    @Path() required int commentId,
  });

  /// 게시글 대댓글 좋아요 API
  @Headers({'token': 'true'})
  @POST(
      '/posts/{postId}/comments/{commentId}/reply-comments/{replyCommentId}/likes')
  Future<ResponseModel<CompletedModel>> postReplyCommentLike({
    @Path() required int postId,
    @Path() required int commentId,
    @Path() required int replyCommentId,
  });

  /// 게시글 대댓글 좋아요 취소 API
  @Headers({'token': 'true'})
  @DELETE(
      '/posts/{postId}/comments/{commentId}/reply-comments/{replyCommentId}/likes')
  Future<ResponseModel<CompletedModel>> deleteReplyCommentLike({
    @Path() required int postId,
    @Path() required int commentId,
    @Path() required int replyCommentId,
  });
}
