
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/error/view/error_screen.dart';
import 'package:miti/dio/response_code.dart';
import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';

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
}
