import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';
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

  void responseError(BuildContext context, PayApiType apiType, WidgetRef ref) {
    switch (apiType) {
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

  void _ready(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 액세스 토큰 오류
    } else if (this.status_code == Forbidden) {
      if (this.error_code == 901) {
        ///  참여할 수 없는 참가자(호스트)
      } else if (this.error_code == 902) {
        /// 참여할 수 없는 경기 상태
      } else if (this.error_code == 903) {
        /// 중복 참여
      }
    } else if (this.status_code == NotFound && this.error_code == 901) {
      /// game_id 조회 결과 없음
    } else if (this.status_code == ServerError && this.error_code == 401) {
      /// 카카오 API 호출 실패
    }
  }

  void _approval(BuildContext context, WidgetRef ref) {
    if (this.status_code == ServerError && this.error_code == 401) {
      /// 경기 참여 처리 실패
    }
  }
}
