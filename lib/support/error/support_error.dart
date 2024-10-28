import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/error/view/error_screen.dart';
import 'package:miti/dio/response_code.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';

enum SupportApiType {
  create,
  get,
}

class SupportError extends ErrorBase {
  final ErrorModel model;

  SupportError({
    required super.status_code,
    required super.error_code,
    required this.model,
  });

  factory SupportError.fromModel({required ErrorModel model}) {
    return SupportError(
      model: model,
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(
      BuildContext context, SupportApiType supportApi, WidgetRef ref,
      {Object? object}) {
    switch (supportApi) {
      case SupportApiType.get:
        _get(context, ref);
        break;
      case SupportApiType.create:
        _create(context, ref);
        break;
      default:
        break;
    }
  }

  /// 나의 문의 내역 상세 조회 API
  void _get(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '문의 조희 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '문의 조희 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == NotFound && this.error_code == 901) {
      /// 문의 고유 번호 오류
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else {
      /// 서버 오류
      context.pushReplacementNamed(ErrorScreen.routeName);
    }
  }

  /// 문의 작성 API
  void _create(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 경기 정보 유효성 검증 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '문의 작성 실패',
            content: '문의 정보가 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '문의 작성 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '문의 작성 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '문의 작성 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }
}
