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

enum UserApiType {
  updateNickname,
  delete,
  get,
  writtenReviewDetail,
  receiveReviewDetail,
  updatePassword
}

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

  void responseError(BuildContext context, UserApiType userApi, WidgetRef ref,
      {Object? object}) {
    switch (userApi) {
      case UserApiType.delete:
        _deleteUser(context, ref);
        break;
      case UserApiType.get:
        _getUserInfo(context, ref);
        break;
      case UserApiType.writtenReviewDetail:
        _getWrittenReviewDetail(context, ref);
        break;
      case UserApiType.receiveReviewDetail:
        _getReceiveReviewDetail(context, ref);
        break;
      case UserApiType.updateNickname:
        _updateNickname(context, ref);
        break;
      case UserApiType.updatePassword:
        _updatePassword(context, ref);
        break;
      default:
        break;
    }
  }

  /// 유저 정보 상세 조회 API
  void _getUserInfo(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '유저 정보 조회 실패',
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
            title: '유저 정보 조회 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 501) {
      /// 요청 권한 오류
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 사용자 정보 조회 실패
      context.pushReplacementNamed(ErrorScreen.routeName);

    } else {
      /// 서버 오류
      context.pushReplacementNamed(ErrorScreen.routeName);

    }
  }

  /// 회원 탈퇴 API
  void _deleteUser(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '회원 탈퇴 실패',
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
            title: '회원 탈퇴 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 501) {
      /// 요청 권한 없음
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '회원 탈퇴 실패',
            content: '회원 탈퇴 권한이 없습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 440) {
      /// 완료되지 않은 경기 존재
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return BottomDialog(
              title: '회원탈퇴 실패',
              content:
                  '경기 진행이 끝나지 않은 경기가 있습니다.\n경기 진행이 모두 끝난 이후에 회원 탈퇴를 진행해 주세요.',
              btn: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      "확인",
                    ),
                  );
                },
              ),
            );
          });
    } else if (this.status_code == Forbidden && this.error_code == 441) {
      /// 완료되지 않은 참가 존재
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return BottomDialog(
              title: '회원탈퇴 실패',
              content: '완료되지 않은 참가 경기가 있습니다.\n경기 진행을 완료한 뒤에 회원 탈퇴를 진행해주세요.',
              btn: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      "확인",
                    ),
                  );
                },
              ),
            );
          });
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 사용자 정보 조회 실패
      context.pushReplacementNamed(ErrorScreen.routeName);

    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '회원 탈퇴 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 작성 리뷰 상세 조회 API
  void _getWrittenReviewDetail(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 조회 실패',
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
            title: '리뷰 조회 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 요청 권한 없음(review 작성자 x)
      context.pushReplacementNamed(ErrorScreen.routeName);

    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 리뷰 조회 결과 없음
      context.pushReplacementNamed(ErrorScreen.routeName);

    } else {
      /// 서버 오류
      context.pushReplacementNamed(ErrorScreen.routeName);

    }
  }

  /// 내 리뷰 상세 조회 API
  void _getReceiveReviewDetail(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 요청 권한 없음(reviewee x)
      context.pushReplacementNamed(ErrorScreen.routeName);

    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 리뷰 조회 결과 없음
      context.pushReplacementNamed(ErrorScreen.routeName);

    } else {
      /// 서버 오류
      context.pushReplacementNamed(ErrorScreen.routeName);

    }
  }

  /// 닉네임 변경 API
  void _updateNickname(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 유효성 검증 실패
      ref
          .read(interactionDescProvider(InteractionType.nickname).notifier)
          .update((state) => InteractionDesc(
                isSuccess: false,
                desc: "다른 닉네임을 사용해주세요.",
              ));
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      context.goNamed(LoginScreen.routeName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '닉네임 변경 실패',
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
            title: '닉네임 변경 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 사용자 불일치
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '닉네임 변경 실패',
            content: '사용자가 일치하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 사용자 조회 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '닉네임 변경 실패',
            content: '해당 사용자를 찾을 수 없습니다.',
          );
        },
      );
    } else {
      /// 이외 에러
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '닉네임 변경 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 비밀번호 변경 API
  void _updatePassword(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 입력 데이터 유효성 검증 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '비밀번호 변경 실패',
            content: '유효하지 않은 비밀번호입니다.',
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
            title: '비밀번호 변경 실패',
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
            title: '비밀번호 변경 실패',
            content: '다시 로그인 해주세요.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 기존 비밀번호 불일치
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '비밀번호 변경 실패',
            content: '기존 비밀번호가 일치하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 사용자 불일치
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '비밀번호 변경 실패',
            content: '사용자가 일치하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// oauth 가입 사용자
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '비밀번호 변경 실패',
            content: '카카오 또는 애플 계정 사용자입니다.\n해당 로그인을 이용해주세요.',
          );
        },
      );
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 사용자 조회 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '비밀번호 변경 실패',
            content: '해당 사용자를 찾을 수 없습니다.',
          );
        },
      );
    } else {
      /// 이외 에러
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '비밀번호 변경 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }
}
