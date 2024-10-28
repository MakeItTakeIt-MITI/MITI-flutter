import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/view/login_screen.dart';
import '../../common/component/custom_dialog.dart';
import '../../common/error/common_error.dart';
import '../../common/error/view/error_screen.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../dio/response_code.dart';

enum PayApiType { ready, approval }

class PayError extends ErrorBase {
  PayError({required super.status_code, required super.error_code});

  factory PayError.fromModel({required ErrorModel model}) {
    return PayError(
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(
      BuildContext context, PayApiType payApiType, WidgetRef ref) {
    switch (payApiType) {
      case PayApiType.ready:
        _ready(context, ref);
        break;
      case PayApiType.approval:
        _approval(context, ref);
        break;
      default:
        break;
    }
  }

  /// 카카오 결제 준비 API (경기 참여)
  void _ready(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '결제 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 토큰 유효성 오류
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '결제 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == Forbidden) {
      if (this.error_code == 940) {
        ///  호스트 참여 불가
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '결제 실패',
              content: '호스트는 결제할 수 없습니다.',
            );
          },
        );
      } else if (this.error_code == 941) {
        /// 중복 참여
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '결제 실패',
              content: '이미 참여한 경기입니다.',
            );
          },
        );
      } else if (this.error_code == 440) {
        /// 참여 불가 경기
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '결제 실패',
              content: '참여할 수 없는 경기입니다.',
            );
          },
        );
      }
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 조회 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '결제 실패',
            content: '경기를 찾을 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == ServerError && this.error_code == 460) {
      /// 카카오 API 호출 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '결제 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    } else if (this.status_code == ServerError && this.error_code == 461) {
      /// 카카오 API 응답 처리 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '결제 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '결제 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 카카오 결제 승인 API
  void _approval(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// pg 토큰 유효성 오류
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else if (this.status_code == Forbidden && this.error_code == 440) {
      /// 모집 마감 경기
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// payment request 조회 실패
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else if (this.status_code == ServerError && this.error_code == 440) {
      /// 경기 참여 실패
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else if (this.status_code == ServerError && this.error_code == 460) {
      /// 결제 완료 api 호출 실패
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else if (this.status_code == ServerError && this.error_code == 461) {
      /// 결제 완료 응답 처리 실패
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else {
      /// 서버 오류
      context.pushReplacementNamed(ErrorScreen.routeName);
    }
  }
}
