import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/view/settlement_management_screen.dart';
import 'package:miti/auth/view/find_info/find_password_screen.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/error/view/pay_error_screen.dart';
import 'package:miti/common/model/remote_config_model.dart';
import 'package:miti/court/view/court_detail_screen.dart';
import 'package:miti/court/view/court_game_list_screen.dart';
import 'package:miti/etc/view/tc_policy_screen.dart';
import 'package:miti/game/model/widget/user_reivew_short_info_model.dart';
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/game/view/game_payment_screen.dart';
import 'package:miti/game/view/game_search_screen.dart';
import 'package:miti/game/view/game_update_screen.dart';
import 'package:miti/game/view/review_form_screen.dart';
import 'package:miti/notification/model/push_model.dart';
import 'package:miti/notification/view/notification_detail_screen.dart';
import 'package:miti/notification/view/notification_screen.dart';
import 'package:miti/support/view/faq_screen.dart';
import 'package:miti/support/view/guide_screen.dart';
import 'package:miti/support/view/support_form_screen.dart';
import 'package:miti/user/view/user_delete_screen.dart';
import 'package:miti/user/view/user_payment_screen.dart';
import 'package:miti/user/view/user_player_profile_screen.dart';
import 'package:miti/user/view/user_profile_form_screen.dart';
import 'package:miti/user/view/review_detail_screen.dart';

import '../../account/view/bank_transfer_form_screen.dart';
import '../../account/component/bank_transfer_card.dart';
import '../../account/view/settlement_detail_screen.dart';
import '../../account/view/settlement_screen.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/view/find_info/find_email_screen.dart';
import '../../auth/view/find_info/find_info_screen.dart';
import '../../auth/view/oauth_error_screen.dart';
import '../../auth/view/signup/signup_screen.dart';
import '../../auth/view/signup/signup_select_screen.dart';
import '../../court/model/court_model.dart';
import '../../court/view/court_search_screen.dart';
import '../../game/view/game_participation_screen.dart';
import '../../game/view/game_create_complete_screen.dart';
import '../../default_screen.dart';
import '../../court/view/court_map_screen.dart';
import '../../game/view/game_review_list_screen.dart';
import '../../game/view/game_screen.dart';
import '../../kakaopay/view/approval_screen.dart';
import '../../notification/view/notification_setting_screen.dart';
import '../../report/view/report_form_screen.dart';
import '../../report/view/report_list_screen.dart';
import '../../review/view/my_review_detail_screen.dart';
import '../../review/view/receive_review_list_screen.dart';
import '../../review/view/review_list_screen.dart';
import '../../review/view/written_review_list_screen.dart';
import '../../user/view/nickname_update_screen.dart';
import '../../user/view/profile_screen.dart';
import '../../splash_screen.dart';
import '../../support/view/support_detail_screen.dart';
import '../../support/view/support_screen.dart';
import '../../user/provider/user_provider.dart';
import '../../user/view/user_participation_screen.dart';
import '../../user/view/user_payment_detail_screen.dart';
import '../../user/view/user_profile_update_screen.dart';
import '../../user/view/user_review_screen.dart';
import '../../util/update/version_check_wrapper.dart';
import '../error/view/error_screen.dart';
import '../model/entity_enum.dart';
import '../view/not_found_screen.dart';

final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavKey = GlobalKey<NavigatorState>();
final signUpPopProvider = StateProvider.autoDispose<bool>((ref) => false);

class DialogPage<T> extends Page<T> {
  static String get routeName => 'test';

  final Widget child;

  const DialogPage({required this.child, super.key});

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
        context: context,
        settings: this,
        barrierDismissible: false,
        builder: (context) => Material(
          color: Colors.transparent,
          child: child,
        ),
      );
}

final routerProvider = Provider<GoRouter>((ref) {
  final provider = ref.read(tokenProvider);
  return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      navigatorKey: rootNavKey,
      refreshListenable: TokenProvider(ref: ref),
      errorBuilder: (BuildContext context, GoRouterState state) {
        return const NotFoundScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          parentNavigatorKey: rootNavKey,
          name: SplashScreen.routeName,
          builder: (context, state) {
            PushDataModel? model;
            if (state.extra != null) {
              model = state.extra as PushDataModel;
            }
            return SplashScreen(
              pushModel: model,
            );
          },
        ),
        GoRoute(
            path: '/login',
            parentNavigatorKey: rootNavKey,
            name: LoginScreen.routeName,
            builder: (_, state) =>
                const VersionCheckWrapper(child: LoginScreen()),
            routes: [
              GoRoute(
                path: 'signUpComplete',
                parentNavigatorKey: rootNavKey,
                name: SignUpCompleteScreen.routeName,
                builder: (_, state) =>
                    VersionCheckWrapper(child: SignUpCompleteScreen()),
              ),
              GoRoute(
                //
                path: 'oauthError',
                parentNavigatorKey: rootNavKey,
                name: OauthErrorScreen.routeName,
                builder: (_, state) =>
                    const VersionCheckWrapper(child: OauthErrorScreen()),
              ),
              GoRoute(
                path: 'completeResetPassword',
                parentNavigatorKey: rootNavKey,
                name: CompleteRestPasswordScreen.routeName,
                builder: (_, state) => const VersionCheckWrapper(
                    child: CompleteRestPasswordScreen()),
              ),
              GoRoute(
                  path: 'findInfo',
                  parentNavigatorKey: rootNavKey,
                  name: FindInfoScreen.routeName,
                  builder: (_, state) {
                    return const VersionCheckWrapper(child: FindInfoScreen());
                  },
                  routes: [
                    GoRoute(
                      path: 'findEmail',
                      parentNavigatorKey: rootNavKey,
                      name: FindEmailScreen.routeName,
                      builder: (_, state) {
                        final email = state.uri.queryParameters['email']!;

                        return VersionCheckWrapper(
                          child: FindEmailScreen(
                            findEmail: email,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'otherAccount',
                      parentNavigatorKey: rootNavKey,
                      name: OtherAccountScreen.routeName,
                      builder: (_, state) {
                        final SignupMethodType authType =
                            state.extra as SignupMethodType;
                        final PhoneAuthenticationPurposeType phoneType =
                            PhoneAuthenticationPurposeType.stringToEnum(
                                value: state.uri.queryParameters['phoneType']!);
                        return VersionCheckWrapper(
                          child: OtherAccountScreen(
                            authType: authType,
                            phoneType: phoneType,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'notFoundAccount',
                      parentNavigatorKey: rootNavKey,
                      name: NotFoundAccountScreen.routeName,
                      builder: (_, state) {
                        return const VersionCheckWrapper(
                            child: NotFoundAccountScreen());
                      },
                    ),
                    GoRoute(
                      path: 'resetPassword',
                      parentNavigatorKey: rootNavKey,
                      name: ResetPasswordScreen.routeName,
                      builder: (_, state) {
                        final String password_update_token =
                            state.uri.queryParameters['password_update_token']!;

                        final int userId =
                            int.parse(state.uri.queryParameters['userId']!);
                        return VersionCheckWrapper(
                          child: ResetPasswordScreen(
                            password_update_token: password_update_token,
                            userId: userId,
                          ),
                        );
                      },
                    ),
                  ]),
              GoRoute(
                  path: 'signUpSelect',
                  parentNavigatorKey: rootNavKey,
                  name: SignUpSelectScreen.routeName,
                  builder: (_, state) =>
                      const VersionCheckWrapper(child: SignUpSelectScreen()),
                  routes: [
                    GoRoute(
                        path: 'signUp',
                        parentNavigatorKey: rootNavKey,
                        name: SignUpScreen.routeName,

                        // onExit: (context) {
                        //   if (ref.read(signUpPopProvider)) {
                        //     return true;
                        //   }
                        //
                        //   showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       final button = Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.center,
                        //         children: [
                        //           Expanded(
                        //             child: TextButton(
                        //               onPressed: () {
                        //                 context.pop();
                        //                 context.pop();
                        //                 ref
                        //                     .read(signUpPopProvider
                        //                         .notifier)
                        //                     .update((state) => true);
                        //               },
                        //               style: ButtonStyle(
                        //                   backgroundColor:
                        //                       WidgetStateProperty.all(
                        //                           MITIColor.gray600)),
                        //               child: Text(
                        //                 '취소하기',
                        //                 style: MITITextStyle.mdBold
                        //                     .copyWith(
                        //                   color: MITIColor.primary,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //           SizedBox(width: 6.w),
                        //           Expanded(
                        //             child: TextButton(
                        //               onPressed: () {
                        //                 context.pop();
                        //               },
                        //               child: Text(
                        //                 '가입 계속하기',
                        //                 style: MITITextStyle.mdBold
                        //                     .copyWith(
                        //                   color: MITIColor.gray800,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       );
                        //       return Material(
                        //         color: Colors.transparent,
                        //         child: CustomDialog(
                        //           title: '회원가입 취소',
                        //           content:
                        //               '회원가입 취소 시 입력하신 정보가 모두 삭제됩니다.\n회원가입을 취소하시겠습니까?',
                        //           button: button,
                        //         ),
                        //       );
                        //     },
                        //   );
                        //   return false;
                        // },
                        builder: (_, state) {
                          SignupMethodType extra =
                              // SignupMethodType.kakao;
                              state.extra as SignupMethodType;

                          return VersionCheckWrapper(
                            child: SignUpScreen(
                              type: extra,
                            ),
                          );
                        },
                        routes: []),
                  ]),
            ]),
        GoRoute(
          path: '/error',
          parentNavigatorKey: rootNavKey,
          name: ErrorScreen.routeName,
          builder: (context, state) {
            return const VersionCheckWrapper(child: ErrorScreen());
          },
        ),
        GoRoute(
            path: '/dialog',
            parentNavigatorKey: rootNavKey,
            name: DialogPage.routeName,
            pageBuilder: (context, state) {
              final Widget child = state.extra as Widget;
              return DialogPage(
                child: child,
                key: state.pageKey,
              );
            }),
        ShellRoute(
            navigatorKey: shellNavKey,
            builder: (context, state, child) {
              log("shell init");
              return VersionCheckWrapper(
                  child: DefaultShellScreen(body: child));
            },
            routes: [
              GoRoute(
                path: '/home',
                redirect: (_, state) => provider.redirectLogic(state),
                parentNavigatorKey: shellNavKey,
                name: CourtMapScreen.routeName,
                builder: (context, state) {
                  return const CourtMapScreen();
                },
                pageBuilder: (context, state) {
                  return const NoTransitionPage(child: CourtMapScreen());
                },
                routes: [
                  GoRoute(
                    path: 'gameSearch',
                    parentNavigatorKey: rootNavKey,
                    name: GameSearchScreen.routeName,
                    builder: (context, state) {
                      return GameSearchScreen();
                    },
                  )
                ],
              ),
              GoRoute(
                  path: '/games',
                  parentNavigatorKey: shellNavKey,
                  redirect: (_, state) => provider.redirectLogic(state),
                  name: GameScreen.routeName,
                  builder: (context, state) {
                    return const GameScreen();
                  },
                  pageBuilder: (context, state) {
                    return const NoTransitionPage(child: GameScreen());
                  },
                  routes: [
                    GoRoute(
                      path: 'approval',
                      parentNavigatorKey: rootNavKey,
                      name: KakaoPayApprovalScreen.routeName,
                      builder: (context, state) {
                        return KakaoPayApprovalScreen();
                      },
                    ),
                    GoRoute(
                      path: 'myParticipation',
                      parentNavigatorKey: rootNavKey,
                      name: UserParticipationScreen.routeName,
                      builder: (context, state) {
                        UserGameType extra = state.extra as UserGameType;
                        return UserParticipationScreen(
                          type: extra,
                        );
                      },
                    ),
                    GoRoute(
                        path: 'create',
                        parentNavigatorKey: rootNavKey,
                        name: GameCreateScreen.routeName,
                        builder: (context, state) {
                          return const GameCreateScreen();
                        },
                        routes: []),
                    GoRoute(
                        path: ':gameId',
                        parentNavigatorKey: rootNavKey,
                        name: GameDetailScreen.routeName,
                        builder: (context, state) {
                          final int gameId =
                              int.parse(state.pathParameters['gameId']!);
                          return GameDetailScreen(
                            gameId: gameId,
                          );
                        },
                        routes: [
                          GoRoute(
                              path: 'participation',
                              parentNavigatorKey: rootNavKey,
                              name: GameParticipationScreen.routeName,
                              builder: (context, state) {
                                final int gameId =
                                    int.parse(state.pathParameters['gameId']!);
                                return GameParticipationScreen(
                                  gameId: gameId,
                                );
                              }),
                          GoRoute(
                            path: 'complete',
                            parentNavigatorKey: rootNavKey,
                            name: GameCompleteScreen.routeName,
                            builder: (context, state) {
                              final extra = state.extra as GameCompleteType;
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);
                              return GameCompleteScreen(
                                gameId: gameId,
                                type: extra,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'update',
                            parentNavigatorKey: rootNavKey,
                            name: GameUpdateScreen.routeName,
                            builder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);

                              return GameUpdateScreen(
                                gameId: gameId,
                              );
                            },
                          ),
                          GoRoute(
                              path: 'report',
                              parentNavigatorKey: rootNavKey,
                              name: ReportListScreen.routeName,
                              builder: (context, state) {
                                final int gameId =
                                    int.parse(state.pathParameters['gameId']!);
                                int? participationId = null;

                                if (state.uri.queryParameters
                                    .containsKey('participationId')) {
                                  participationId = int.parse(state
                                      .uri.queryParameters['participationId']!);
                                }

                                final ReportCategoryType reportType =
                                    state.extra as ReportCategoryType;
                                return ReportListScreen(
                                  gameId: gameId,
                                  reportType: reportType,
                                  participationId: participationId,
                                );
                              },
                              routes: [
                                GoRoute(
                                  path: ':reportId',
                                  parentNavigatorKey: rootNavKey,
                                  name: ReportFormScreen.routeName,
                                  builder: (context, state) {
                                    final int gameId = int.parse(
                                        state.pathParameters['gameId']!);
                                    final int reportId = int.parse(
                                        state.pathParameters['reportId']!);
                                    int? participationId = null;
                                    if (state.uri.queryParameters
                                        .containsKey('participationId')) {
                                      participationId = int.parse(state.uri
                                          .queryParameters['participationId']!);
                                    }
                                    // final type =
                                    //     state.extra as HostReportCategoryType;
                                    return ReportFormScreen(
                                      gameId: gameId,
                                      reportId: reportId,
                                      // type: type,
                                      participationId: participationId,
                                    );
                                  },
                                ),
                              ]),
                          GoRoute(
                              path: 'players',
                              parentNavigatorKey: rootNavKey,
                              name: GameReviewListScreen.routeName,
                              builder: (context, state) {
                                final int gameId =
                                    int.parse(state.pathParameters['gameId']!);
                                return GameReviewListScreen(
                                  gameId: gameId,
                                );
                              },
                              routes: [
                                GoRoute(
                                  path: 'reviewList',
                                  parentNavigatorKey: rootNavKey,
                                  name: ReviewListScreen.routeName,
                                  builder: (context, state) {
                                    final int gameId = int.parse(
                                        state.pathParameters['gameId']!);
                                    int? participationId;
                                    if (state.uri.queryParameters
                                        .containsKey('participationId')) {
                                      participationId = int.parse(state.uri
                                          .queryParameters['participationId']!);
                                    }

                                    return ReviewListScreen(
                                      gameId: gameId,
                                      participationId: participationId,
                                      // ratingId: ratingId,
                                    );
                                  },
                                ),
                              ]),
                          GoRoute(
                              path: 'paymentInfo',
                              parentNavigatorKey: rootNavKey,
                              name: GamePaymentScreen.routeName,
                              builder: (context, state) {
                                final int gameId =
                                    int.parse(state.pathParameters['gameId']!);
                                return GamePaymentScreen(
                                  gameId: gameId,
                                );
                              },
                              routes: [
                                GoRoute(
                                    path: 'error',
                                    parentNavigatorKey: rootNavKey,
                                    name: PayErrorScreen.routeName,
                                    builder: (context, state) {
                                      final canParticipation =
                                          state.extra! as bool;
                                      final int gameId = int.parse(
                                          state.pathParameters['gameId']!);
                                      return PayErrorScreen(
                                        gameId: gameId,
                                        canParticipation: canParticipation,
                                      );
                                    },
                                    routes: []),
                              ]),
                          GoRoute(
                            path: 'review',
                            parentNavigatorKey: rootNavKey,
                            name: ReviewScreen.routeName,
                            builder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);
                              int? participationId;
                              if (state.uri.queryParameters
                                  .containsKey('participationId')) {
                                participationId = int.parse(state
                                    .uri.queryParameters['participationId']!);
                              }
                              final model =
                                  state.extra as UserReviewShortInfoModel;

                              return ReviewScreen(
                                gameId: gameId,
                                participationId: participationId,
                                userInfoModel: model,
                                // ratingId: ratingId,
                              );
                            },
                          ),
                          GoRoute(
                            path: ':reviewId',
                            parentNavigatorKey: rootNavKey,
                            name: ReviewDetailScreen.routeName,
                            builder: (_, state) {
                              final int reviewId =
                                  int.parse(state.pathParameters['reviewId']!);
                              int? participationId;
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);
                              if (state.uri.queryParameters
                                  .containsKey('participationId')) {
                                participationId = int.parse(state
                                    .uri.queryParameters['participationId']!);
                              }
                              final revieweeNickname = state
                                  .uri.queryParameters['revieweeNickname']!;
                              return ReviewDetailScreen(
                                reviewId: reviewId,
                                participationId: participationId,
                                gameId: gameId,
                                revieweeNickname: revieweeNickname,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'cancel/:participationId',
                            parentNavigatorKey: rootNavKey,
                            name: GameRefundScreen.routeName,
                            builder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);
                              final int participationId = int.parse(
                                  state.pathParameters['participationId']!);

                              return GameRefundScreen(
                                gameId: gameId,
                                participationId: participationId,
                              );
                            },
                          ),
                        ]),
                  ]),
              GoRoute(
                  path: '/courts',
                  parentNavigatorKey: shellNavKey,
                  name: CourtSearchListScreen.routeName,
                  redirect: (_, state) => provider.redirectLogic(state),
                  builder: (context, state) {
                    return const CourtSearchListScreen();
                  },
                  pageBuilder: (context, state) {
                    return const NoTransitionPage(
                        child: CourtSearchListScreen());
                  },
                  routes: [
                    GoRoute(
                        path: ':courtId',
                        parentNavigatorKey: rootNavKey,
                        name: CourtDetailScreen.routeName,
                        builder: (context, state) {
                          final int courtId =
                              int.parse(state.pathParameters['courtId']!);

                          return CourtDetailScreen(
                            courtId: courtId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'gameList',
                            parentNavigatorKey: rootNavKey,
                            name: CourtGameListScreen.routeName,
                            builder: (context, state) {
                              final int courtId =
                                  int.parse(state.pathParameters['courtId']!);

                              return CourtGameListScreen(
                                courtId: courtId,
                              );
                            },
                          ),
                        ]),
                  ]),
              GoRoute(
                path: '/menu',
                parentNavigatorKey: shellNavKey,
                redirect: (_, state) => provider.redirectLogic(state),
                name: ProfileBody.routeName,
                builder: (context, state) {
                  return const ProfileBody();
                },
                pageBuilder: (context, state) {
                  return const NoTransitionPage(child: ProfileBody());
                },
                routes: [
                  GoRoute(
                    path: 'playerprofile',
                    parentNavigatorKey: rootNavKey,
                    name: UserPlayerProfileScreen.routeName,
                    builder: (context, state) {
                      return const UserPlayerProfileScreen();
                    },
                  ),
                  GoRoute(
                    path: 'delete',
                    parentNavigatorKey: rootNavKey,
                    name: UserDeleteScreen.routeName,
                    builder: (context, state) {
                      return const UserDeleteScreen();
                    },
                  ),
                  GoRoute(
                      path: 'support',
                      parentNavigatorKey: rootNavKey,
                      name: SupportScreen.routeName,
                      builder: (context, state) {
                        return const SupportScreen();
                      },
                      routes: [
                        GoRoute(
                          path: 'supportForm',
                          parentNavigatorKey: rootNavKey,
                          name: SupportFormScreen.routeName,
                          builder: (context, state) {
                            return SupportFormScreen();
                          },
                        ),
                        GoRoute(
                          path: ':questionId',
                          parentNavigatorKey: rootNavKey,
                          name: SupportDetailScreen.routeName,
                          builder: (context, state) {
                            final int questionId =
                                int.parse(state.pathParameters['questionId']!);
                            return SupportDetailScreen(
                              questionId: questionId,
                            );
                          },
                        ),
                      ]),
                  GoRoute(
                      path: 'settlements',
                      parentNavigatorKey: rootNavKey,
                      name: SettlementListScreen.routeName,
                      builder: (context, state) {
                        final int bottomIdx =
                            int.parse(state.uri.queryParameters['bottomIdx']!);
                        return SettlementListScreen(
                          bottomIdx: bottomIdx,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: ':settlementId',
                          parentNavigatorKey: rootNavKey,
                          name: SettlementDetailScreen.routeName,
                          builder: (context, state) {
                            final int settlementId = int.parse(
                                state.pathParameters['settlementId']!);

                            return SettlementDetailScreen(
                              settlementId: settlementId,
                            );
                          },
                        ),
                      ]),
                  GoRoute(
                    path: 'review',
                    parentNavigatorKey: rootNavKey,
                    name: UserWrittenReviewScreen.routeName,
                    builder: (_, state) {
                      final extra = UserReviewType.stringToEnum(
                          value: state.extra! as String);
                      final int bottomIdx =
                          int.parse(state.uri.queryParameters['bottomIdx']!);
                      return UserWrittenReviewScreen(
                        type: extra,
                        bottomIdx: bottomIdx,
                      );
                    },
                    routes: [],
                  ),
                  GoRoute(
                    path: 'tcPolicy',
                    parentNavigatorKey: rootNavKey,
                    name: TcPolicyScreen.routeName,
                    builder: (context, state) {
                      return const TcPolicyScreen();
                    },
                  ),
                  GoRoute(
                    path: 'nicknameUpdate',
                    parentNavigatorKey: rootNavKey,
                    name: NicknameUpdateScreen.routeName,
                    builder: (context, state) {
                      return const NicknameUpdateScreen();
                    },
                  ),
                  GoRoute(
                    path: 'myPayment',
                    parentNavigatorKey: rootNavKey,
                    name: UserPaymentScreen.routeName,
                    builder: (context, state) {
                      return const UserPaymentScreen();
                    },
                    routes: [
                      GoRoute(
                        path: ':paymentResultId',
                        parentNavigatorKey: rootNavKey,
                        name: UserPaymentDetailScreen.routeName,
                        builder: (context, state) {
                          final int paymentResultId = int.parse(
                              state.pathParameters['paymentResultId']!);
                          return UserPaymentDetailScreen(
                            paymentResultId: paymentResultId,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'notification',
                    parentNavigatorKey: rootNavKey,
                    name: NotificationScreen.routeName,
                    builder: (context, state) {
                      return const NotificationScreen();
                    },
                    routes: [
                      GoRoute(
                        path: ':id',
                        parentNavigatorKey: rootNavKey,
                        name: NoticeDetailScreen.routeName,
                        builder: (context, state) {
                          final int id = int.parse(state.pathParameters['id']!);
                          final type = state.extra as NoticeScreenType;
                          return NoticeDetailScreen(
                            id: id,
                            type: type,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'notificationSetting',
                    parentNavigatorKey: rootNavKey,
                    name: NotificationSettingScreen.routeName,
                    builder: (context, state) {
                      return const NotificationSettingScreen();
                    },
                  ),
                  GoRoute(
                      path: 'profileUpdate',
                      parentNavigatorKey: rootNavKey,
                      name: UserProfileUpdateScreen.routeName,
                      builder: (context, state) {
                        return const UserProfileUpdateScreen();
                      },
                      routes: [
                        GoRoute(
                          path: 'profileForm',
                          parentNavigatorKey: rootNavKey,
                          name: UserProfileFormScreen.routeName,
                          builder: (context, state) {
                            return const UserProfileFormScreen();
                          },
                        ),
                      ]),
                  GoRoute(
                    path: 'settlementManagement',
                    parentNavigatorKey: rootNavKey,
                    name: SettlementManagementScreen.routeName,
                    builder: (context, state) {
                      return const SettlementManagementScreen();
                    },
                  ),
                  GoRoute(
                    path: 'transferForm',
                    parentNavigatorKey: rootNavKey,
                    name: BankTransferFormScreen.routeName,
                    builder: (context, state) {
                      return const BankTransferFormScreen();
                    },
                  ),
                  GoRoute(
                    path: 'faq',
                    parentNavigatorKey: rootNavKey,
                    name: FAQScreen.routeName,
                    builder: (context, state) {
                      return const FAQScreen();
                    },
                  ),
                  GoRoute(
                    path: 'guide',
                    parentNavigatorKey: rootNavKey,
                    name: GuideScreen.routeName,
                    builder: (context, state) {
                      return const GuideScreen();
                    },
                  ),
                  GoRoute(
                    path: 'receiveReviewList',
                    parentNavigatorKey: rootNavKey,
                    name: ReceiveReviewListScreen.routeName,
                    builder: (context, state) {
                      return const ReceiveReviewListScreen();
                    },
                  ),
                  GoRoute(
                    path: 'writtenReviewList',
                    parentNavigatorKey: rootNavKey,
                    name: WrittenReviewListScreen.routeName,
                    builder: (context, state) {
                      return const WrittenReviewListScreen();
                    },
                  ),
                  GoRoute(
                    path: 'myReviewDetail/:reviewId',
                    parentNavigatorKey: rootNavKey,
                    name: MyReviewDetailScreen.routeName,
                    builder: (context, state) {
                      final int reviewId =
                          int.parse(state.pathParameters['reviewId']!);
                      final userReviewType = UserReviewType.stringToEnum(
                          value: state.uri.queryParameters['userReviewType']!);
                      final reviewType = ReviewType.stringToEnum(
                          value: state.uri.queryParameters['reviewType']!);
                      return MyReviewDetailScreen(
                        userReviewType: userReviewType,
                        reviewId: reviewId,
                        reviewType: reviewType,
                      );
                    },
                  ),
                ],
              ),
            ]),
      ]);
});
