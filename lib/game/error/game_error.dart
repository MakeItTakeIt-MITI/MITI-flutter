import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../../theme/text_theme.dart';
import '../view/game_screen.dart';

enum GameApiType {
  createGame,
  get,
  update,
  getPaymentInfo,
  getRefundInfo,
  getReview,
  createGuestReview,
  createHostReview,
  free,
  cancel,
  participationCancel,
}

class GameError extends ErrorBase {
  final ErrorModel model;

  GameError({
    required super.status_code,
    required super.error_code,
    required this.model,
  });

  factory GameError.fromModel({required ErrorModel model}) {
    return GameError(
      model: model,
      status_code: model.status_code,
      error_code: model.error_code,
    );
  }

  void responseError(BuildContext context, GameApiType gameApi, WidgetRef ref,
      {Object? object}) {
    switch (gameApi) {
      case GameApiType.get:
        _get(context, ref);
        break;
      case GameApiType.createGame:
        _create(context, ref);
        break;
      case GameApiType.update:
        _update(context, ref);
        break;
      case GameApiType.getPaymentInfo:
        _getPaymentInfo(context, ref);
        break;
      case GameApiType.getRefundInfo:
        _getRefundInfo(context, ref);
        break;
      case GameApiType.getReview:
        _getReview(context, ref);
        break;
      case GameApiType.createGuestReview:
        _createGuestReview(context, ref);
        break;
      case GameApiType.createHostReview:
        _createHostReview(context, ref);
        break;
      case GameApiType.free:
        _free(context, ref);
        break;
      case GameApiType.cancel:
        _cancel(context, ref);
        break;
      case GameApiType.participationCancel:
        _participationCancel(context, ref);
        break;
      default:
        break;
    }
  }

  /// 경기 상세 조회 API
  void _get(BuildContext context, WidgetRef ref) {
    if (this.status_code == NotFound && this.error_code == 940) {
      /// 해당 경기 정보 조회 실패
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

  /// 경기 모집 생성 API
  void _create(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 경기 정보 유효성 검증 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 모집 생성 실패',
            content: '경기 모집 정보가 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '경기 모집 생성 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '경기 모집 생성 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == ServerError && this.error_code == 460) {
      /// 위경도 요청 API 실패
      WidgetsBinding.instance.addPostFrameCallback((s) {
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '경기 모집 생성 실패',
                      content: '서버가 불안정해 잠시후 다시 이용해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == ServerError && this.error_code == 461) {
      /// 위경도 변환 응답 처리 실패
      WidgetsBinding.instance.addPostFrameCallback((s) {
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '경기 모집 생성 실패',
                      content: '서버가 불안정해 잠시후 다시 이용해주세요.',
                    );
                  },
                ));
      });
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 모집 생성 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 경기 정보 수정 API
  void _update(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 요청 데이터 유효성 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 수정 실패',
            content: '경기 모집 정보가 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == BadRequest && this.error_code == 180) {
      /// 데이터  유효성 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 수정 실패',
            content: '경기 모집 정보가 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == BadRequest && this.error_code == 501) {
      /// 호스트 사용자 불일치
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 수정 실패',
            content: '경기 주최자가 아닙니다.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '경기 수정 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '경기 수정 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == Forbidden && this.error_code == 501) {
      /// 호스트 사용자 아님
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 수정 실패',
            content: '경기 주최자가 아닙니다.',
          );
        },
      );
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 정보 조회 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 수정 실패',
            content: '해당 경기를 찾을 수 없습니다.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '경기 수정 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 경기 참여 결제 정보 조회 API
  void _getPaymentInfo(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '결제 정보 조회 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '결제 정보 조회 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 참여 불가 경기
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 참여 불가 사용자
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == Forbidden && this.error_code == 942) {
      /// 참여 완료 사용자
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 정보 조회 실패
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

  /// 경기 참여 환불 정보 조회 API
  void _getRefundInfo(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 940) {
      /// path parameter 오류
      context.pushReplacementNamed(ErrorScreen.routeName);
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '환불 정보 조회 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '환불 정보 조회 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 요청자 참여자 불일치
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 참여 미확정 참여
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == Forbidden && this.error_code == 942) {
      /// 경기 참여 취소 시간 제한 초과
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == Forbidden && this.error_code == 943) {
      /// 참여 취소 불가 경기
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == Forbidden && this.error_code == 944) {
      /// 미완료 결제 상태
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.pushReplacementNamed(ErrorScreen.routeName);
      });
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 참여 정보 조회 실패
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

  /// 평점 상세 조회 API
  void _getReview(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '평점 조회 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '평점 조회 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 평점 정보 조회 실패
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

  /// 게스트 리뷰 작성 API
  void _createGuestReview(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 요청 데이터 유효성 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '리뷰 정보가 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == BadRequest && this.error_code == 940) {
      /// path parameter 데이터 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '리뷰 정보가 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '리뷰 작성 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomDialog(
                      title: '리뷰 작성 실패',
                      content: '다시 로그인 해주세요.',
                    );
                  },
                ));
      });
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 결제 미완료 참여

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '결제가 완료되지 않은 경기는 작성할 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 미완료 경기

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '완료되지 않은 경기는 작성할 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 942) {
      /// 해당 경기 미참여 사용자

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '참여하지 않은 사용자는 작성할 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 정보 조회 실패

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '작성하신 리뷰의 경기를 찾을 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == NotFound && this.error_code == 941) {
      /// 참여 정보 조회 실패

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '작성하신 리뷰의 경기 참여를 찾을 수 없습니다.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 호스트 리뷰 작성 API
  void _createHostReview(BuildContext context, WidgetRef ref) {
    if (this.status_code == BadRequest && this.error_code == 101) {
      /// 요청 데이터 유효성 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '리뷰 정보가 유효하지 않습니다.',
          );
        },
      );
    } else if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 토큰 미제공
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
                () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomDialog(
                  title: '리뷰 작성 실패',
                  content: '다시 로그인 해주세요.',
                );
              },
            ));
      });
    } else if (this.status_code == UnAuthorized && this.error_code == 502) {
      /// 엑세스 토큰 오류
      WidgetsBinding.instance.addPostFrameCallback((s) {
        context.goNamed(LoginScreen.routeName);
        Future.delayed(
            const Duration(milliseconds: 200),
                () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomDialog(
                  title: '리뷰 작성 실패',
                  content: '다시 로그인 해주세요.',
                );
              },
            ));
      });
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 미완료 경기

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '완료되지 않은 경기는 작성할 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 호스트 사용자

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '본인 리뷰는 작성할 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 942) {
      /// 미참여 사용자

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '참여하지 않은 사용자는 작성할 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == Forbidden && this.error_code == 943) {
      /// 참여 미확정 사용자

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '참여가 확정되지 않은 사용자는 작성할 수 없습니다.',
          );
        },
      );
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 관련 객체 조회 실패

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '작성하신 리뷰의 경기를 찾을 수 없습니다.',
          );
        },
      );
    } else {
      /// 서버 오류
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: '리뷰 작성 실패',
            content: '서버가 불안정해 잠시후 다시 이용해주세요.',
          );
        },
      );
    }
  }

  /// 경기 무료 전환 API
  void _free(BuildContext context, WidgetRef ref) {
    if (this.status_code == Forbidden && this.error_code == 940) {
      /// 요청 권한 없음
      FlashUtil.showFlash(context, "경기 무료 전환에 실패하였습니다.",
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 변경 불가능한 경기
      FlashUtil.showFlash(context, "경기 무료 전환에 실패하였습니다.",
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 942) {
      /// 무료 참여인 경기
      FlashUtil.showFlash(context, "경기 무료 전환에 실패하였습니다.",
          textColor: MITIColor.error);
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 정보 조회 결과 없음
      FlashUtil.showFlash(context, "경기 무료 전환에 실패하였습니다.",
          textColor: MITIColor.error);
    } else if (this.status_code == ServerError && this.error_code == 340) {
      /// 서버 내부 오류
      FlashUtil.showFlash(context, "경기 무료 전환에 실패하였습니다.",
          textColor: MITIColor.error);
    } else {
      /// 서버 오류
      FlashUtil.showFlash(context, "경기 무료 전환에 실패하였습니다.",
          textColor: MITIColor.error);
    }
  }

  /// 경기 모집 취소 API
  void _cancel(BuildContext context, WidgetRef ref) {
    if (this.status_code == UnAuthorized && this.error_code == 501) {
      /// 액세스 토큰 오류
      FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 940) {
      /// 경기 취소 권한 없음
      FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
          textColor: MITIColor.error);
    } else if (this.status_code == Forbidden && this.error_code == 941) {
      /// 취소 불가능한 경기 상태
      FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
          textColor: MITIColor.error);
    } else if (this.status_code == NotFound && this.error_code == 940) {
      /// 경기 정보 조회 실패
      FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
          textColor: MITIColor.error);
    } else {
      /// 서버 오류
      FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
          textColor: MITIColor.error);
    }
  }

  _participationCancel(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return BottomDialog(
            hasPop: true,
            title: '참여를 취소할 수 없는 경기입니다.',
            content: '경기 시작 2시간 이내에는 경기 참여를 취소하실 수 없습니다.',
            btn: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return TextButton(
                  onPressed: () async {
                    context.goNamed(GameScreen.routeName);
                  },
                  style: TextButton.styleFrom(
                    fixedSize: Size(double.infinity, 48.h),
                    backgroundColor: MITIColor.error,
                  ),
                  child: Text(
                    "돌아가기",
                    style: MITITextStyle.mdBold.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                );
              },
            ),
          );
        });

    // if (this.status_code == BadRequest && this.error_code == 940) {
    //   /// 경기 및 참여 정보 불일치
    //   FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
    //       textColor: MITIColor.error);
    // } else if (this.status_code == Forbidden && this.error_code == 940) {
    //   /// 요청 권한 없음
    //   FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
    //       textColor: MITIColor.error);
    // } else if (this.status_code == Forbidden && this.error_code == 941) {
    //   /// 취소 불가 참여
    //   FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
    //       textColor: MITIColor.error);
    // } else if (this.status_code == Forbidden && this.error_code == 942) {
    //   /// 참여 취소 불가 경기
    //   FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
    //       textColor: MITIColor.error);
    // } else if (this.status_code == Forbidden && this.error_code == 960) {
    //   /// 참여 미확정 경기
    //   FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
    //       textColor: MITIColor.error);
    // } else if (this.status_code == Forbidden && this.error_code == 961) {
    //   /// 결제 취소 실패
    //   FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
    //       textColor: MITIColor.error);
    // } else if (this.status_code == NotFound && this.error_code == 940) {
    //   /// 참여 정보 조회 실패
    //   FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
    //       textColor: MITIColor.error);
    // } else {
    //   /// 서버 오류
    //   FlashUtil.showFlash(context, "경기 모집 취소에 실패하였습니다.",
    //       textColor: MITIColor.error);
    // }
  }
}
