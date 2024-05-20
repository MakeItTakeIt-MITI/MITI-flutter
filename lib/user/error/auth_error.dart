import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/dio/response_code.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/component/custom_text_form_field.dart';
import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/form_util_provider.dart';

enum UserApiType { nickname }

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

  void responseError(BuildContext context, UserApiType authApi, WidgetRef ref,
      {Object? object}) {
    switch (authApi) {
      case UserApiType.nickname:
        updateNickname(context, ref);
        break;
      default:
        break;
    }
  }

  /// 닉네임 변경 API
  void updateNickname(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 유효성 검증 실패
      ref
          .read(interactionDescProvider(InteractionType.nickname).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "이미 사용중인 닉네임입니다.",
              ));
    }
  }
}
