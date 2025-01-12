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

enum ReportApiType {
  report,
}

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
      case ReportApiType.report:
        _report(context, ref);
        break;

      default:
        break;
    }
  }

  /// 경기 호스트 신고 API
  void _report(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 작성 데이터 유효성 검증 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 신고 실패',
            content: '경기 신고 내용이 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 신고 불가 경기 상태
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 신고 실패',
            content: '6시간 이내의 경기만 신고 할 수 있습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 미참여 사용자
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 신고 실패',
            content: '경기를 참여하지 않은 계정입니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 942) {
      /// 중복 신고
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 신고 실패',
            content: '이미 신고한 경기입니다.',
          );
        },
      );
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 정보 조회 실패

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 신고 실패',
            content: '해당 경기가 존재하지 않습니다.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 신고 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }
}
