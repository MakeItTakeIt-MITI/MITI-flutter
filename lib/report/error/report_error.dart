import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/error/view/error_screen.dart';
import 'package:miti/dio/response_code.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/component/custom_text_form_field.dart';
import '../../common/component/defalut_flashbar.dart';
import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/provider/form_util_provider.dart';
import '../../common/provider/router_provider.dart';

enum ReportApiType { hostReport, guestReport, reports, get }

class ReportError extends ErrorBase {
  final ErrorModel model;

  ReportError({
    required super.status_code,
    required super.error_code,
    required this.model,
  });

  factory ReportError.fromModel({required ErrorModel model}) {
    return ReportError(
      model: model,
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(
      BuildContext context, ReportApiType reportApi, WidgetRef ref,
      {Object? object}) {
    switch (reportApi) {
      case ReportApiType.hostReport:
        _hostReport(context, ref);
        break;
      case ReportApiType.guestReport:
        _guestReport(context, ref);
        break;
      case ReportApiType.reports:
        _reports(context, ref);
        break;
      case ReportApiType.get:
        _get(context, ref);
        break;
      default:
        break;
    }
  }

  /// 신고 사유 목록 조회 API
  void _reports(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 쿼리스트링 유효성 검증 실패
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else {
      /// 서버 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    }
  }

  /// 신고 사유 상세 조회 API
  void _get(BuildContext context, WidgetRef ref) {
    if (this.status_code == NotFound && this.error_code == 940) {
      /// 데이터 조회 실패
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else {
      /// 서버 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    }
  }


  /// 경기 호스트 신고 API
  void _hostReport(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 작성 데이터 유효성 검증 실패
      FlashUtil.showFlash(context, '경기 신고 내용이 유효하지 않습니다.',
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 신고 불가 경기 상태
      FlashUtil.showFlash(context, '6시간 이내의 경기만 신고 할 수 있습니다.',
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 미참여 사용자
      FlashUtil.showFlash(context, '경기를 참여하지 않은 계정입니다.',
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 942) {
      /// 중복 신고
      FlashUtil.showFlash(context, '이미 신고한 경기입니다.', textColor: MITIColor.error);
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 정보 조회 실패
      FlashUtil.showFlash(context, '해당 경기가 존재하지 않습니다.',
          textColor: MITIColor.error);
    } else {
      /// 서버 오류
      FlashUtil.showFlash(context, '서버가 불안정해 잠시후 다시 이용해주세요.',
          textColor: MITIColor.error);
    }
  }

  /// 경기 게스트 신고 API
  void _guestReport(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 작성 데이터 유효성 검증 실패
      FlashUtil.showFlash(context, '경기 신고 내용이 유효하지 않습니다.',
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 완료되지 않은 경기
      FlashUtil.showFlash(context, '완료되지 않은 경기입니다.',
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 확정되지 않은 경기 참여
      FlashUtil.showFlash(context, '경기 참여에 확정되지 않았습니다.',
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 942) {
      /// 경기 미참여자 오류
      FlashUtil.showFlash(context, '경기를 참여하지 않았습니다.',
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 943) {
      /// 신고 완료 참여자
      FlashUtil.showFlash(context, '이미 신고를 하였습니다.', textColor: MITIColor.error);
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 정보 조회 실패
      FlashUtil.showFlash(context, '해당 경기가 존재하지 않습니다.',
          textColor: MITIColor.error);
    } else {
      /// 서버 오류
      FlashUtil.showFlash(context, '서버가 불안정해 잠시후 다시 이용해주세요.',
          textColor: MITIColor.error);
    }
  }
}
