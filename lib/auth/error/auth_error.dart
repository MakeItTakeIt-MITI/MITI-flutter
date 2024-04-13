import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/dio/response_code.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/component/custom_text_form_field.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/form_util_provider.dart';
import '../view/oauth_error_screen.dart';
import '../view/phone_auth/phone_auth_screen.dart';

enum AuthApiType {
  login,
  signup,
  signup_check,
  send_code,
  request_code,
  find_email,
  reset_password,
  oauth,
  reissue,
  findInfo
}

abstract class ErrorBase {
  final int status_code;
  final int error_code;

  ErrorBase({
    required this.status_code,
    required this.error_code,
  });
}

class AuthError extends ErrorBase {
  AuthError({required super.status_code, required super.error_code});

  factory AuthError.fromModel({required ErrorModel model}) {
    return AuthError(
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(BuildContext context, AuthApiType authApi, WidgetRef ref) {
    switch (authApi) {
      case AuthApiType.login:
        login(context, ref);
        break;
      case AuthApiType.signup_check:
        signupCheck(context, ref);
        break;
      case AuthApiType.signup:
        signup(context, ref);
        break;
      case AuthApiType.oauth:
        oauth(context, ref);
        break;
      case AuthApiType.send_code:
        sendCode(context, ref);
        break;
      case AuthApiType.request_code:
        requestCode(context, ref);
        break;
      case AuthApiType.findInfo:
        findInfo(context, ref);
        break;
      default:
        break;
    }
  }

  void login(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 유효성 검증 실패
    } else if (this.status_code == UnAuthorized && this.error_code == 101) {
      /// 사용자 정보 불일치
      ref
          .read(formDescProvider(InputFormType.login).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "일치하는 사용자 정보가 존재하지 않습니다.",
              ));
    } else if (this.status_code == UnAuthorized && this.error_code == 201) {
      /// 탈퇴사용자
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '계정 조회 실패',
            content: '탈퇴한 사용자입니다.\n고객센터에 문의해주세요.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 301) {
      /// 미인증 사용자 로그인
      context.pushNamed(PhoneAuthScreen.routeName);
    }
  }

  void signupCheck(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 이메일/닉네임 유효성 검증 실패
    } else if (this.status_code == BadRequest && this.error_code == 901) {
      /// 유효성 오류 - 데이터가 주어지지 않은 경우
    }
  }

  void signup(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 유효성 검증 실패
    } else if (this.status_code == BadRequest && this.error_code == 101) {
      /// 데이터 중복
    } else if (this.status_code == ServerError) {
      /// 서버 오류
    }
  }

  void oauth(BuildContext context, WidgetRef ref) {
    if (this.status_code == Forbidden && this.error_code == 101) {
      /// path parameter/query string 유효성 검증 실패
    } else if (this.status_code == Forbidden && this.error_code == 301) {
      /// oauth 가입 이력 불일치
    } else if (this.status_code == Forbidden && this.error_code == 302) {
      /// 일반 회원가입 사용자 요청
      context.pushNamed(OauthErrorScreen.routeName);
    } else if (this.status_code == ServerError) {
      /// 서버 오류
    }
  }

  void sendCode(BuildContext context, WidgetRef ref) {
    if (status_code == BadRequest && error_code == 402) {
      /// 탈퇴한 사용자입니다
      showDialog(
          context: context,
          builder: (_) {
            return const CustomDialog(
              title: '계정 조회 실패',
              content: '탈퇴한 사용자입니다.\n고객센터에 문의해주세요.',
            );
          });
    } else if (status_code == BadRequest && error_code == 102) {
      ref
          .read(formDescProvider(InputFormType.passwordCode).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "인증번호가 일치하지 않습니다.",
              ));
    } else if (status_code == BadRequest && error_code == 401) {
      ref
          .read(formDescProvider(InputFormType.passwordCode).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "요청 유효 시간을 초과하였습니다.",
              ));
    } else if (status_code == Forbidden && error_code == 402) {
      showDialog(
          context: context,
          builder: (_) {
            return CustomDialog(
              title: '카카오 로그인 사용자',
              onPressed: () => context.goNamed(LoginScreen.routeName),
              content: '카카오 계정을 사용하여 가입하셨습니다.\n카카오 로그인을 통해 로그인해주세요.',
            );
          });
    }
  }

  void requestCode(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 이메일/비밀번호 유효성 검증 실패
    } else if (this.status_code == BadRequest && this.error_code == 301) {
      /// 인증 완료 사용자
      // context.pushNamed(name);
    } else if (this.status_code == UnAuthorized && this.error_code == 101) {
      /// 일치 사용자 없음
      ref
          .read(interactionDescProvider(InteractionType.normal).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "일치하는 사용자 정보가 존재하지 않습니다.",
              ));
    }
  }

  void findInfo(BuildContext context, WidgetRef ref) {
    if (this.status_code == NotFound && this.error_code == 101) {
      /// 일치 사용자 없음
      ref
          .read(interactionDescProvider(InteractionType.email).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "일치하는 사용자 정보가 존재하지 않습니다.",
              ));
    }
  }
}
