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
import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/form_util_provider.dart';
import '../../common/provider/router_provider.dart';

enum UserApiType { nickname, delete, get, reviewDetail }

class UserError extends ErrorBase {
  final ErrorModel model;

  UserError({
    required super.status_code,
    required super.error_code,
    required this.model,
  });

  factory UserError.fromModel({required ErrorModel model}) {
    return UserError(
      model: model,
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(BuildContext context, UserApiType userApi, WidgetRef ref,
      {Object? object}) {
    switch (userApi) {
      case UserApiType.nickname:
        _updateNickname(context, ref);
        break;
      case UserApiType.delete:
        _deleteUser(context, ref);
        break;
      case UserApiType.get:
        _getUserInfo(context, ref);
        break;
      default:
        break;
    }
  }

  /// 유저 정보 상세 조회 API
  void _getUserInfo(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
    } else if (this.status_code == Forbidden && this.error_code == 501) {
      /// 요청 권한 오류
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 사용자 정보 조회 실패
    } else {
      /// 이외 에러
    }
  }

  /// 회원 탈퇴 API
  void _deleteUser(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
    } else if (this.status_code == Forbidden && this.error_code == 501) {
      /// 요청 권한 없음
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 완료되지 않은 경기 존재
      final extra = CustomDialog(
        title: '회원탈퇴 실패',
        content: '완료되지 않은 경기가 있습니다.\n경기 진행을 완료한 뒤에 회원 탈퇴를 진행해주세요.',
        onPressed: () {
          context.pop();
        },
      );
      context.pushNamed(DialogPage.routeName, extra: extra);
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 완료되지 않은 참가 존재
      final extra = CustomDialog(
        title: '회원탈퇴 실패',
        content: '완료되지 않은 참가 경기가 있습니다.\n경기 진행을 완료한 뒤에 회원 탈퇴를 진행해주세요.',
        onPressed: () {
          context.pop();
        },
      );
      context.pushNamed(DialogPage.routeName, extra: extra);
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 사용자 정보 조회 실패
    } else {
      /// 이외 에러
    }
  }

  /// 작성 리뷰 상세 조회 API
  void _getWrittenReviewDetail(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 요청 권한 없음(review 작성자 x)
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 리뷰 조회 결과 없음
      context.pushNamed(ErrorScreen.routeName);
    } else {
      /// 이외 에러
    }
  }

  /// 내 리뷰 상세 조회 API
  void _getReceiveReviewDetail(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 요청 권한 없음(reviewee x)
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 리뷰 조회 결과 없음
      context.pushNamed(ErrorScreen.routeName);
    } else {
      /// 이외 에러
    }
  }

  /// 닉네임 변경 API
  void _updateNickname(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 유효성 검증 실패
      ref
          .read(interactionDescProvider(InteractionType.nickname).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "이미 사용중인 닉네임입니다.",
              ));
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 사용자 불일치
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 사용자 조회 실패
    } else {
      /// 이외 에러
    }
  }

  /// 비밀번호 변경 API
  void _updatePassword(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 입력 데이터 유효성 검증 실패
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 기존 비밀번호 불일치
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 사용자 불일치
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// oauth 가입 사용자
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 사용자 조회 실패
    } else {
      /// 이외 에러
    }
  }

  /// 내 리뷰 상세 조회 API
  // void _updatePassword(BuildContext context, WidgetRef ref) {
  //   if (this.status_code == BadRequest && this.error_code == 101) {
  //     /// 이외 에러
  //   } else {
  //     /// 이외 에러
  //   }
  // }
}
