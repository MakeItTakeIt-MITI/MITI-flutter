import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/error/view/error_screen.dart';
import 'package:miti/dio/response_code.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/component/custom_text_form_field.dart';
import '../../common/component/defalut_flashbar.dart';
import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/provider/form_util_provider.dart';
import '../../common/provider/router_provider.dart';
import '../../theme/color_theme.dart';

enum PostApiType {
  createPost,
  getPostList,
  getPopularList,
  getPopularSearchList,
  getDetail,
  updatePost,
  deletePost,
  getCommentList,
  createComment,
  getCommentDetail,
  updateComment,
  deleteComment,
  createReplyComment,
  updateReplyComment,
  deleteReplyComment,
  likePost,
  unLikePost,
  likeComment,
  unLikeComment,
  likeReplyComment,
  unLikeReplyComment,
}

class PostError extends ErrorBase {
  final ErrorModel model;

  PostError({
    required super.status_code,
    required super.error_code,
    required this.model,
  });

  factory PostError.fromModel({required ErrorModel model}) {
    return PostError(
      model: model,
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(BuildContext context, PostApiType postApi, WidgetRef ref,
      {Object? object}) {
    switch (postApi) {
      case PostApiType.createPost:
        _createPost(context, ref);
        break;
      case PostApiType.getPostList:
        _getPostList(context, ref);
        break;
      case PostApiType.getPopularList:
        _getPopularList(context, ref);
        break;
      case PostApiType.getPopularSearchList:
        _getPopularSearchList(context, ref);
        break;
      case PostApiType.getDetail:
        _getDetail(context, ref);
        break;
      case PostApiType.updatePost:
        _updatePost(context, ref);
        break;
      case PostApiType.deletePost:
        _deletePost(context, ref);
        break;
      case PostApiType.getCommentList:
        _getCommentList(context, ref);
        break;
      case PostApiType.createComment:
        _createComment(context, ref);
        break;
      case PostApiType.getCommentDetail:
        _getCommentDetail(context, ref);
        break;
      case PostApiType.updateComment:
        _updateComment(context, ref);
        break;
      case PostApiType.deleteComment:
        _deleteComment(context, ref);
        break;
      case PostApiType.createReplyComment:
        _createReplyComment(context, ref);
        break;
      case PostApiType.updateReplyComment:
        _updateReplyComment(context, ref);
        break;
      case PostApiType.deleteReplyComment:
        _deleteReplyComment(context, ref);
        break;
      case PostApiType.likePost:
        _likePost(context, ref);
        break;
      case PostApiType.unLikePost:
        _unLikePost(context, ref);
        break;
      case PostApiType.likeComment:
        _likeComment(context, ref);
        break;
      case PostApiType.unLikeComment:
        _unLikeComment(context, ref);
        break;
      case PostApiType.likeReplyComment:
        _likeReplyComment(context, ref);
        break;
      case PostApiType.unLikeReplyComment:
        _unLikeReplyComment(context, ref);
        break;
      default:
        break;
    }
  }

  /// 게시글 작성 API
  void _createPost(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "게시글 작성을 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 게시글 목록 조회 API
  void _getPostList(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((s) {
      context.pushReplacementNamed(ErrorScreen.routeName);
    });
  }

  /// 인기 게시글 목록 조회 API
  void _getPopularList(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((s) {
      context.pushReplacementNamed(ErrorScreen.routeName);
    });
  }

  /// 인기 게시글 검색어 목록 조회 API
  void _getPopularSearchList(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((s) {
      context.pushReplacementNamed(ErrorScreen.routeName);
    });
  }

  /// 게시글 상세 조회 API
  void _getDetail(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((s) {
      context.pushReplacementNamed(ErrorScreen.routeName);
    });
  }

  /// 게시글 수정 API
  void _updatePost(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "게시글 수정을 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 게시글 삭제 API
  void _deletePost(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "게시글 삭제를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 게시글 댓글 목록 조회 API
  void _getCommentList(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((s) {
      context.pushReplacementNamed(ErrorScreen.routeName);
    });
  }

  /// 게시글 댓글 작성 API
  void _createComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "댓글 작성을 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 게시글 댓글 상세 조회 API
  void _getCommentDetail(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((s) {
      context.pushReplacementNamed(ErrorScreen.routeName);
    });
  }

  /// 댓글 수정 API
  void _updateComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "댓글 수정을 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 댓글 삭제 API
  void _deleteComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "댓글 삭제를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 대댓글 작성 API
  void _createReplyComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "대댓글 작성을 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 대댓글 수정 API
  void _updateReplyComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "대댓글 수정을 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 대댓글 삭제 API
  void _deleteReplyComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "대댓글 삭제를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 게시글 좋아요 API
  void _likePost(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "게시글 좋아요를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 게시글 좋아요 취소 API
  void _unLikePost(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "게시글 좋아요 취소를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 댓글 좋아요 API
  void _likeComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "댓글 좋아요를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 댓글 좋아요 취소 API
  void _unLikeComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "댓글 좋아요 취소를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 대댓글 좋아요 API
  void _likeReplyComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "대댓글 좋아요를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }

  /// 대댓글 좋아요 취소 API
  void _unLikeReplyComment(BuildContext context, WidgetRef ref) {
    FlashUtil.showFlash(context, "대댓글 좋아요 취소를 실패하였습니다.",
        textColor: V2MITIColor.red5);
  }
}
