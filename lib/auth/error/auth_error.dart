import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/widget/find_info_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:miti/common/provider/widget/form_provider.dart';
import 'package:miti/dio/response_code.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/component/custom_text_form_field.dart';
import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../model/find_info_model.dart';
import '../view/oauth_error_screen.dart';

enum AuthApiType {
  /// 로그인 API
  login,

  /// 로그아웃 API
  logout,

  /// 회원가입 API
  signup,
  signup_check,

  /// 인증 코드 입력 API - 회원가입, 이메일, 비밀번호
  send_code,
  request_code,

  /// 인증 코드 전송 요청 API
  requestSMS,
  oauth,
  reissue,

  /// 사용자 정보 수정 토큰 발급 API
  tokenForPassword,
}

class AuthError extends ErrorBase {
  final ErrorModel model;

  AuthError({
    required super.status_code,
    required super.error_code,
    required this.model,
  });

  factory AuthError.fromModel({required ErrorModel model}) {
    return AuthError(
      model: model,
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(BuildContext context, AuthApiType authApi, WidgetRef ref,
      {Object? object}) {
    switch (authApi) {
      case AuthApiType.login:
        _login(context, ref);
        break;
      case AuthApiType.logout:
        _logout(context, ref);
        break;
      case AuthApiType.signup_check:
        _signupCheck(context, ref);
        break;
      case AuthApiType.signup:
        _signup(context, ref);
        break;
      case AuthApiType.oauth:
        _oauth(context, ref, object as AuthType);
        break;
      case AuthApiType.send_code:
        _sendCode(context, ref, object as PhoneAuthType);
        break;
      case AuthApiType.request_code:
        _requestCode(context, ref);
        break;
      case AuthApiType.requestSMS:
        _requestSMS(context, ref);
        break;
      case AuthApiType.reissue:
        _reissue(context, ref);
        break;
      case AuthApiType.tokenForPassword:
        _tokenForPassword(context, ref);
        break;
      default:
        break;
    }
  }

  /// 일반 로그인 API
  void _login(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 로그인 데이터 유효성 검증 실패
      ref.read(formInfoProvider(InputFormType.email).notifier).update(
            borderColor: MITIColor.error,
          );
      ref.read(formInfoProvider(InputFormType.password).notifier).update(
            borderColor: MITIColor.error,
            interactionDesc: InteractionDesc(
              isSuccess: false,
              desc: "이메일이나 비밀번호가 일치하지 않습니다.",
            ),
          );
    } else if (this.status_code == UnAuthorized && this.error_code == 140) {
      /// 로그인 정보 일치 사용자 없음
      ref.read(formInfoProvider(InputFormType.email).notifier).update(
            borderColor: MITIColor.error,
          );
      ref.read(formInfoProvider(InputFormType.password).notifier).update(
            borderColor: MITIColor.error,
            interactionDesc: InteractionDesc(
              isSuccess: false,
              desc: "이메일이나 비밀번호가 일치하지 않습니다.",
            ),
          );
    } else if (this.status_code == Forbidden && this.error_code == 140) {
      /// 로그인 불가 사용자
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '로그인 실패',
            content: '탈퇴한 사용자입니다.\n고객센터에 문의해주세요.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '로그인 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 로그아웃 API
  void _logout(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 토큰값 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '로그아웃 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 회원가입정보 중복 확인 API
  void _signupCheck(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 데이터 입력값 유효성 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '확인 실패',
            content: '입력하신 내용이 알맞지 않습니다.\n다른 내용으로 입력해주세요.',
          );
        },
      );
    } else if (this.status_code == BadRequest && this.error_code == 120) {
      /// 이메일/닉네임 미입력
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '확인 실패',
            content: '이메일 또는 닉네임을 다시 입력해주세요.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '확인 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 일반 회원가입 API
  void _signup(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 회원가입 데이터 유효성 검증 실패
      if (model.data['phone'] != null &&
          (model.data['phone'] as List<dynamic>).isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '회원가입 실패',
              content: '이미 회원가입한 전화번호입니다.',
            );
          },
        );
      } else if (model.data['name'] != null &&
          (model.data['name'] as List<dynamic>).isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '회원가입 실패',
              content: '유효하지 않는 이름입니다.',
            );
          },
        );
      }
    } else if (this.status_code == BadRequest && this.error_code == 120) {
      /// 비밀번호 불일치
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '회원가입 실패',
            content: '입력하신 비밀번호가 일치하지 않습니다.\n다시 이용해주세요.',
          );
        },
      );
    } else if (this.status_code == BadRequest && this.error_code == 220) {
      /// 인증 미완료 휴대전화 번호
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '회원가입 실패',
            content: '인증되지 않은 휴대전화입니다.',
          );
        },
      );
    } else if (this.status_code == BadRequest && this.error_code == 520) {
      /// 토큰 유효성 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '회원가입 실패',
            content: '다시 시도해 주세요.',
          );
        },
      );
    } else if (this.status_code == BadRequest && this.error_code == 940) {
      /// 회원가입 방식 불일치
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '회원가입 실패',
            content: '다시 시도해 주세요.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '회원가입 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// Oauth 엑세스토큰 로그인 API
  void _oauth(BuildContext context, WidgetRef ref, AuthType type) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 로그인 데이터 유효성 검증 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '로그인 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 540) {
      /// 비회원 Oauth 사용자 ?
      final extra = type;
      print("not oauth user");
    context.goNamed(SignUpScreen.routeName, extra: extra);
    } else if (this.status_code == Forbidden && this.error_code == 140) {
      /// 로그인 불가 사용자
      String oauthProvider = type == AuthType.kakao ? '애플' : '카카오';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: '로그인 실패',
            content: '이미 $oauthProvider에 회원가입한 기록이 있습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 340) {
      /// 이메일 가입 사용자
      showDialog(
          context: context,
          builder: (_) {
            return CustomDialog(
              title: '이메일 가입 사용자',
              content: '이메일 가입 이력이 존재합니다.\n일반 로그인을 통해 로그인 해주시기 바랍니다.',
              btnDesc: '이메일 로그인 하러 가기',
              onPressed: () {
                context.pop();
                context.goNamed(LoginScreen.routeName);
              },
            );
          });
    } else if (this.status_code == Forbidden && this.error_code == 341) {
      /// 타 oauth 서비스 사용자
      /// 애플 가입 사용자
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return BottomDialog(
              title: 'Apple ID 가입 사용자',
              content:
                  '해당 번호로 Apple ID 가입 이력이 존재합니다.\nApple ID 로그인을 통해 로그인 해주시기 바랍니다.',
              btn: TextButton(
                onPressed: () {
                  context.pop();
                  context.goNamed(LoginScreen.routeName);
                },
                child: const Text("Apple ID 로그인 하러 가기"),
              ),
            );
          });
    } else if (this.status_code == Forbidden && this.error_code == 342) {
      /// 타 oauth 서비스 사용자
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return BottomDialog(
              title: '카카오 가입 사용자',
              content: '해당 번호로 카카오 가입 이력이 존재합니다.\n카카오 로그인을 통해 로그인 해주시기 바랍니다.',
              btn: TextButton(
                onPressed: () {
                  context.pop();
                  context.goNamed(LoginScreen.routeName);
                },
                child: const Text("카카오로 로그인 하러 가기"),
              ),
            );
          });
    } else if (this.status_code == Forbidden && this.error_code == 361) {
      /// 일반 로그인 사용자
      context.pushNamed(OauthErrorScreen.routeName);
    } else if (this.status_code == NotFound && this.error_code == 950) {
      /// 지원하지 않는 oauth 서비스
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '로그인 실패',
            content: '해당 로그인 기능은 지원하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == ServerError && this.error_code == 460) {
      /// 카카오 인증 요청 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '로그인 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    } else if (this.status_code == ServerError && this.error_code == 461) {
      /// 카카오 사용자 정보 변환 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '로그인 실패',
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
            title: '로그인 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 토큰 재발급
  void _reissue(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 520) {
      /// 토큰 유효성 검증 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '재발급 실패',
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
            title: '재발급 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 인증 코드 입력 API - 회원가입, 이메일, 비밀번호
  void _sendCode(BuildContext context, WidgetRef ref, PhoneAuthType type) {
    if (status_code == BadRequest && error_code == 101) {
      /// 요청 데이터 유효성 오류
      showDialog(
          context: context,
          builder: (_) {
            return const CustomDialog(
              title: '인증코드 검증 실패',
              content: '잘못된 코드를 입력했습니다.',
            );
          });
    } else if (status_code == BadRequest && error_code == 120) {
      /// 요청 시간 제한 초과

      ref.read(formInfoProvider(InputFormType.phone).notifier).update(
            borderColor: MITIColor.error,
            interactionDesc: InteractionDesc(
              isSuccess: false,
              desc: "인증번호 입력 시간이 초과되었습니다.",
            ),
          );
    } else if (status_code == BadRequest && error_code == 340) {
      /// 회원가입 -  이메일 가입 사용자

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return BottomDialog(
              title: '이메일 가입 사용자',
              content: '해당 번호로 이메일 가입 이력이 존재합니다.\n일반 로그인을 통해 로그인 해주시기 바랍니다.',
              btn: TextButton(
                onPressed: () {
                  context.pop();
                  context.goNamed(LoginScreen.routeName);
                },
                child: const Text("이메일 로그인 하러 가기"),
              ),
            );
          });
    } else if (status_code == BadRequest && error_code == 341) {
      /// 회원가입 - 애플 가입 사용자

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return BottomDialog(
              title: 'Apple ID 가입 사용자',
              content:
                  '해당 번호로 Apple ID 가입 이력이 존재합니다.\nApple ID 로그인을 통해 로그인 해주시기 바랍니다.',
              btn: TextButton(
                onPressed: () {
                  context.pop();
                  context.goNamed(LoginScreen.routeName);
                },
                child: const Text("Apple ID 로그인 하러 가기"),
              ),
            );
          });
    } else if (status_code == BadRequest && error_code == 342) {
      /// 회원가입 - 카카오 가입 사용자
      ///

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return BottomDialog(
              title: '카카오 가입 사용자',
              content: '해당 번호로 카카오 가입 이력이 존재합니다.\n카카오 로그인을 통해 로그인 해주시기 바랍니다.',
              btn: TextButton(
                onPressed: () {
                  context.pop();
                  context.goNamed(LoginScreen.routeName);
                },
                child: const Text("카카오 로그인 하러 가기"),
              ),
            );
          });
    } else if (status_code == BadRequest && error_code == 440) {
      /// 이메일, 비밀번호 찾기 apple 가입자
      if (type == PhoneAuthType.find_email) {
        ref
            .read(findEmailProvider.notifier)
            .update(EmailVerifyModel(authType: AuthType.apple));
      } else {
        ref
            .read(findPasswordProvider.notifier)
            .update(PasswordVerifyModel(authType: AuthType.apple));
      }
    } else if (status_code == BadRequest && error_code == 441) {
      /// 이메일, 비밀번호 찾기 kakao 가입자
      if (type == PhoneAuthType.find_email) {
        ref
            .read(findEmailProvider.notifier)
            .update(EmailVerifyModel(authType: AuthType.kakao));
      } else {
        ref
            .read(findPasswordProvider.notifier)
            .update(PasswordVerifyModel(authType: AuthType.kakao));
      }
    } else if (status_code == BadRequest && error_code == 480) {
      /// 이메일, 비밀번호 찾기 인증 코드 불일치

      ref.read(formInfoProvider(InputFormType.phone).notifier).update(
            borderColor: MITIColor.error,
            interactionDesc: InteractionDesc(
              isSuccess: false,
              desc: "인증번호가 일치하지 않습니다.",
            ),
          );
    } else if (status_code == BadRequest && error_code == 520) {
      /// 토큰 유효성 검증 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '인증 토큰 검증 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    } else if (status_code == Forbidden && error_code == 480) {
      /// 인증 요청 횟수 초과

      ref.read(formInfoProvider(InputFormType.phone).notifier).update(
            borderColor: MITIColor.error,
            interactionDesc: InteractionDesc(
              isSuccess: false,
              desc: "인증번호 입력 가능 횟수를 초과하셨습니다.",
            ),
          );
    } else if (status_code == NotFound && error_code == 440) {
      /// 일치 사용자 없음
      if (type == PhoneAuthType.find_email) {
        ref.read(findEmailProvider.notifier).update(EmailVerifyModel());
      } else {
        ref.read(findPasswordProvider.notifier).update(PasswordVerifyModel());
      }
    } else if (status_code == NotFound && error_code == 460) {
      /// 인증 요청 조회 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '인증 요청 조회 실패',
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
            title: '인증코드 검증 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// SMS 전송 - 사용자 인증 API
  void _requestCode(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 이메일/비밀번호 유효성 검증 실패
      showDialog(
          context: context,
          builder: (_) {
            return CustomDialog(
              title: 'SMS 요청 실패',
              onPressed: () => context.goNamed(LoginScreen.routeName),
              content: '이메일 또는 비밀번호를 다시 입력해주세요.',
            );
          });
    } else if (this.status_code == BadRequest && this.error_code == 440) {
      /// 인증 완료 사용자
      showDialog(
          context: context,
          builder: (_) {
            return CustomDialog(
              title: 'SMS 요청 실패',
              onPressed: () => context.goNamed(LoginScreen.routeName),
              content: '이미 인증 완료한 사용자입니다.',
            );
          });
    } else if (this.status_code == UnAuthorized && this.error_code == 140) {
      /// 일치 사용자 없음
      ref
          .read(interactionDescProvider(InteractionType.normal).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "일치하는 사용자 정보가 존재하지 않습니다.",
              ));
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: 'SMS 요청 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// SMS 전송 - 비밀번호 재설정 API
  void _requestSMS(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 입력값 유효성 검증 실패
      showDialog(
          context: context,
          builder: (_) {
            return CustomDialog(
              title: 'SMS 요청 실패',
              onPressed: () => context.goNamed(LoginScreen.routeName),
              content: '비밀번호를 다시 입력해주세요.',
            );
          });
    } else if (this.status_code == ServerError && this.error_code == 100) {
      /// sms 전송 요청 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: 'SMS 요청 실패',
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
            title: 'SMS 요청 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 비밀번호 재설정용 토큰 발급 API
  void _tokenForPassword(BuildContext context, WidgetRef ref) {
    if ((this.status_code == BadRequest && this.error_code == 101) ||
        (this.status_code == UnAuthorized && this.error_code == 140)) {
      ref.read(formInfoProvider(InputFormType.updateToken).notifier).update(
            borderColor: MITIColor.error,
            interactionDesc: InteractionDesc(
              isSuccess: false,
              desc: "비밀번호가 일치하지 않습니다.",
            ),
          );
    } else if (this.status_code == Forbidden && this.error_code == 440) {
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '토큰 발급 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }
}
