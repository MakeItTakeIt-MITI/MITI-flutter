
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/error/view/error_screen.dart';
import 'package:miti/dio/response_code.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/error/common_error.dart';
import '../../common/model/default_model.dart';

enum AccountApiType { getSettlementInfo, requestTransfer, getAccountInfo }

class AccountError extends ErrorBase {
  final ErrorModel model;

  AccountError({
    required super.status_code,
    required super.error_code,
    required this.model,
  });

  factory AccountError.fromModel({required ErrorModel model}) {
    return AccountError(
      model: model,
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(
      BuildContext context, AccountApiType accountApi, WidgetRef ref,
      {Object? object}) {
    switch (accountApi) {
      case AccountApiType.getSettlementInfo:
        _get(context, ref);
        break;
      case AccountApiType.requestTransfer:
        _requestTransfer(context, ref);
        break;
      case AccountApiType.getAccountInfo:
        _getAccountInfo(context, ref);
        break;
      default:
        break;
    }
  }

  /// 정산 내역 상세 조회 API
  void _get(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '정산 내역 조회 실패',
              content: '다시 로그인 해주세요.',
            );
          },
        );
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '정산 내역 조회 실패',
              content: '다시 로그인 해주세요.',
            );
          },
        );
      });
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 사용자 고유 번호 권한 오류	or 정산 계좌 권한 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == NotFound && this.error_code == 940) {
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

  /// 송금 요청 생성 API
  void _requestTransfer(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 요청 데이터 유효성 검증 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '송금 요청 실패',
            content: '송금 요청 정보가 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == BadRequest && this.error_code == 180) {
      /// 요청 가능 금액 초과
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '송금 요청 실패',
            content: '요청 가능한 송금액을 초과하였습니다.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '송금 요청 실패',
              content: '다시 로그인 해주세요.',
            );
          },
        );
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류

      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '송금 요청 실패',
              content: '다시 로그인 해주세요.',
            );
          },
        );
      });
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 요청 권한 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '송금 요청 실패',
              content: '송금 요청 권한이 없습니다.',
            );
          },
        );
      });
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '송금 요청 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 계좌 정보 조회 API
  void _getAccountInfo(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '계좌 정보 조회 실패',
              content: '다시 로그인 해주세요.',
            );
          },
        );
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류

      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialog(
              title: '계좌 정보 조회 실패',
              content: '다시 로그인 해주세요.',
            );
          },
        );
      });
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 요청 권한 없음
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 일치 계좌 정보 없음
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
