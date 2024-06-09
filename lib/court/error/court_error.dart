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
import '../../common/model/entity_enum.dart';
import '../../common/provider/form_util_provider.dart';
import '../../common/provider/router_provider.dart';

enum CourtApiType {
  get,
}

class CourtError extends ErrorBase {
  final ErrorModel model;

  CourtError({
    required super.status_code,
    required super.error_code,
    required this.model,
  });

  factory CourtError.fromModel({required ErrorModel model}) {
    return CourtError(
      model: model,
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(BuildContext context, CourtApiType courtApi, WidgetRef ref,
      {Object? object}) {
    switch (courtApi) {
      case CourtApiType.get:
        _get(context, ref);
        break;
      default:
        break;
    }
  }

  /// 경기장 상세 조회 API
  void _get(BuildContext context, WidgetRef ref) {
    if (this.status_code == NotFound && this.error_code == 940) {
      /// 정산 기록 조회 실패
      const extra = ErrorScreenType.notFound;
      context.pushReplacementNamed(ErrorScreen.routeName, extra: extra);
    } else {
      /// 서버 오류
      const extra = ErrorScreenType.server;
      context.pushReplacementNamed(ErrorScreen.routeName, extra: extra);
    }
  }
}
