import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/find_info/find_password_screen.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_info_screen.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_screen.dart';
import 'package:miti/court/view/court_game_list_screen.dart';
import 'package:miti/game/view/game_participation_screen.dart';
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/game/view/game_host_list_screen.dart';
import 'package:miti/game/view/game_payment_screen.dart';
import 'package:miti/game/view/game_update_screen.dart';
import 'package:miti/game/view/review_form_screen.dart';
import 'package:miti/support/view/faq_screen.dart';
import 'package:miti/support/view/support_form_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/view/user_delete_screen.dart';
import 'package:miti/user/view/user_profile_form_screen.dart';
import 'package:miti/user/view/user_review_detail_screen.dart';

import '../../account/view/bank_transfer_form_screen.dart';
import '../../account/view/bank_transfer_screen.dart';
import '../../account/view/settlement_detail_screen.dart';
import '../../account/view/settlement_screen.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/view/find_info/find_email_screen.dart';
import '../../auth/view/find_info/find_info_screen.dart';
import '../../auth/view/oauth_error_screen.dart';
import '../../auth/view/phone_auth/phone_auth_send_screen.dart';
import '../../auth/view/signup/signup_screen.dart';
import '../../auth/view/signup/signup_select_screen.dart';
import '../../court/model/court_model.dart';
import '../../court/view/court_search_screen.dart';
import '../../game/view/game_create_complete_screen.dart';
import '../../default_screen.dart';
import '../../court/view/court_map_screen.dart';
import '../../game/view/game_screen.dart';
import '../../kakaopay/view/approval_screen.dart';
import '../../kakaopay/view/payment_screen.dart';
import '../../menu/view/menu_screen.dart';
import '../../permission_screen.dart';
import '../../splash_screen.dart';
import '../../support/view/support_detail_screen.dart';
import '../../support/view/support_screen.dart';
import '../../user/provider/user_provider.dart';
import '../../user/view/user_delete_success_screen.dart';
import '../../user/view/user_host_list_screen.dart';
import '../../user/view/user_info_screen.dart';
import '../../user/view/user_review_screen.dart';
import '../component/custom_dialog.dart';
import '../error/view/error_screen.dart';
import '../model/entity_enum.dart';

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
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      navigatorKey: rootNavKey,
      refreshListenable: TokenProvider(ref: ref),
      routes: <RouteBase>[
        GoRoute(
          path: '/splash',
          parentNavigatorKey: rootNavKey,
          name: SplashScreen.routeName,

          builder: (context, state) {
            return SplashScreen();
          },

          // pageBuilder: (context, state) {
          //   return NoTransitionPage(child: SplashScreen());
          // },
        ),

        GoRoute(
            path: '/login',
            parentNavigatorKey: rootNavKey,
            name: LoginScreen.routeName,
            builder: (_, state) => const LoginScreen(),
            // pageBuilder: (context, state) {
            //   return const NoTransitionPage(child: LoginScreen());
            // },
            routes: [
              GoRoute(
                path: 'oauthError',
                parentNavigatorKey: rootNavKey,
                name: OauthErrorScreen.routeName,
                builder: (_, state) => const OauthErrorScreen(),
                // pageBuilder: (context, state) {
                //   return const NoTransitionPage(
                //       child: OauthErrorScreen());
                // },
              ),
              GoRoute(
                path: 'completeResetPassword',
                parentNavigatorKey: rootNavKey,
                name: CompleteRestPasswordScreen.routeName,
                builder: (_, state) => const CompleteRestPasswordScreen(),
                // pageBuilder: (context, state) {
                //   return const NoTransitionPage(
                //       child: CompleteRestPasswordScreen());
                // },
              ),
              GoRoute(
                path: 'phoneSuccess',
                parentNavigatorKey: rootNavKey,
                name: PhoneAuthSuccess.routeName,
                builder: (_, state) => const PhoneAuthSuccess(),
                // pageBuilder: (context, state) {
                //   return const NoTransitionPage(
                //       child: PhoneAuthSuccess());
                // },
              ),
              GoRoute(
                path: 'phoneSend',
                parentNavigatorKey: rootNavKey,
                name: PhoneAuthSendScreen.routeName,
                builder: (_, state) => const PhoneAuthSendScreen(),
                // pageBuilder: (context, state) {
                //   return const NoTransitionPage(
                //       child: PhoneAuthSendScreen());
                // },
              ),
              GoRoute(
                  path: 'findInfo',
                  parentNavigatorKey: rootNavKey,
                  name: FindInfoScreen.routeName,
                  builder: (_, state) {
                    return FindInfoScreen();
                  },
                  // pageBuilder: (context, state) {
                  //   return NoTransitionPage(child: FindInfoScreen());
                  // },
                  routes: [
                    GoRoute(
                      path: 'findEmail',
                      parentNavigatorKey: rootNavKey,
                      name: FindEmailScreen.routeName,
                      builder: (_, state) {
                        final email = state.uri.queryParameters['email']!;

                        return FindEmailScreen(
                          findEmail: email,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'otherAccount',
                      parentNavigatorKey: rootNavKey,
                      name: OtherAccountScreen.routeName,
                      builder: (_, state) {
                        final AuthType authType = state.extra as AuthType;
                        return OtherAccountScreen(
                          authType: authType,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'notFoundAccount',
                      parentNavigatorKey: rootNavKey,
                      name: NotFoundAccountScreen.routeName,
                      builder: (_, state) {
                        return const NotFoundAccountScreen();
                      },
                    ),
                    GoRoute(
                      path: 'resetPassword',
                      parentNavigatorKey: rootNavKey,
                      name: ResetPasswordScreen.routeName,
                      builder: (_, state) {
                        final String password_update_token = state
                            .uri.queryParameters['password_update_token']!;

                        final int userId =
                        int.parse(state.uri.queryParameters['userId']!);
                        return ResetPasswordScreen(
                          password_update_token: password_update_token,
                          userId: userId,
                        );
                      },
                      // pageBuilder: (context, state) {
                      //   return NoTransitionPage(
                      //       child: ResetPasswordScreen());
                      // },
                    ),
                  ]),
              GoRoute(
                  path: 'signUpSelect',
                  parentNavigatorKey: rootNavKey,
                  name: SignUpSelectScreen.routeName,
                  builder: (_, state) => const SignUpSelectScreen(),
                  // pageBuilder: (context, state) {
                  //   return const NoTransitionPage(
                  //       child: SignUpSelectScreen());
                  // },
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
                      //                       MaterialStateProperty.all(
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
                        AuthType extra = state.extra as AuthType;

                        return SignUpScreen(
                          type: extra,
                        );
                      },
                      routes: [],
                      // pageBuilder: (context, state) {
                      //   return const NoTransitionPage(
                      //       child: SignUpScreen());
                      // },
                    ),
                  ]),
              GoRoute(
                  path: 'phoneAuth',
                  parentNavigatorKey: rootNavKey,
                  name: PhoneAuthScreen.routeName,
                  builder: (_, state) => const PhoneAuthScreen(),
                  // pageBuilder: (context, state) {
                  //   return const NoTransitionPage(
                  //       child: PhoneAuthScreen());
                  // },
                  routes: [
                    GoRoute(
                        path: 'phoneAuthInfo',
                        parentNavigatorKey: rootNavKey,
                        name: PhoneAuthInfoScreen.routeName,
                        builder: (_, state) => const PhoneAuthInfoScreen(),
                        // pageBuilder: (context, state) {
                        //   return const NoTransitionPage(
                        //       child: PhoneAuthInfoScreen());
                        // },
                        routes: []),
                  ]),
            ]),
        GoRoute(
          path: '/error',
          parentNavigatorKey: rootNavKey,
          name: ErrorScreen.routeName,
          builder: (context, state) {
            ErrorScreenType extra = state.extra as ErrorScreenType;
            return ErrorScreen(
              errorType: extra,
            );
          },
          // pageBuilder: (context, state) {
          //   return NoTransitionPage(child: SplashScreen());
          // },
        ),
        GoRoute(
            path: '/dialog',
            parentNavigatorKey: rootNavKey,
            name: DialogPage.routeName,
            // builder: (context, state) {
            //   return SplashScreen();
            // },
            pageBuilder: (context, state) {
              final Widget child = state.extra as Widget;
              return DialogPage(
                child: child,
                key: state.pageKey,
              );
            }),
        GoRoute(
          path: '/permission',
          parentNavigatorKey: rootNavKey,
          name: PermissionScreen.routeName,
          builder: (context, state) {
            return PermissionScreen();
          },
          // pageBuilder: (context, state) {
          //   return NoTransitionPage(child: PermissionScreen());
          // },
        ),
        ShellRoute(
            navigatorKey: shellNavKey,
            builder: (context, state, child) {
              return DefaultShellScreen(body: child);
            },
            routes: [
              GoRoute(
                path: '/home',
                redirect: (_, state) => provider.redirectLogic(state),
                parentNavigatorKey: shellNavKey,
                name: CourtMapScreen.routeName,
                builder: (context, state) {
                  return CourtMapScreen();
                },
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: CourtMapScreen());
                },
                routes: [
                  GoRoute(
                      path: 'signUpComplete',
                      parentNavigatorKey: rootNavKey,
                      name: SignUpCompleteScreen.routeName,
                      builder: (_, state) => SignUpCompleteScreen(),
                      routes: []),
                  GoRoute(
                    path: 'user/delete',
                    parentNavigatorKey: rootNavKey,
                    name: UserDeleteSuccessScreen.routeName,
                    builder: (context, state) {
                      final int bottomIdx =
                          int.parse(state.uri.queryParameters['bottomIdx']!);

                      return UserDeleteSuccessScreen(
                        bottomIdx: bottomIdx,
                      );
                    },
                    // pageBuilder: (context, state) {
                    //   return NoTransitionPage(child: UserDeleteSuccessScreen());
                    // },
                  ),
                ],
              ),
              GoRoute(
                  path: '/game',
                  parentNavigatorKey: shellNavKey,
                  redirect: (_, state) => provider.redirectLogic(state),
                  name: GameScreen.routeName,
                  builder: (context, state) {
                    return GameScreen();
                  },
                  pageBuilder: (context, state) {
                    return NoTransitionPage(child: GameScreen());
                  },
                  routes: [
                    GoRoute(
                      path: 'approval',
                      parentNavigatorKey: rootNavKey,
                      name: KakaoPayApprovalScreen.routeName,
                      // redirect: (_, state) => provider.redirectLogic(state),
                      builder: (context, state) {
                        return KakaoPayApprovalScreen();
                      },
                      // pageBuilder: (context, state) {
                      //   return NoTransitionPage(
                      //       child: KakaoPayApprovalScreen());
                      // },
                    ),
                    GoRoute(
                      path: 'host',
                      parentNavigatorKey: rootNavKey,
                      name: GameHostScreen.routeName,
                      // redirect: (_, state) => provider.redirectLogic(state),
                      builder: (context, state) {
                        UserGameType extra = state.extra as UserGameType;
                        final int bottomIdx =
                            int.parse(state.uri.queryParameters['bottomIdx']!);
                        return GameHostScreen(
                          type: extra,
                          bottomIdx: bottomIdx,
                        );
                      },
                      // pageBuilder: (context, state) {
                      //   UserGameType extra = state.extra as UserGameType;
                      //   return NoTransitionPage(
                      //       child: GameHostScreen(
                      //     type: extra,
                      //   ));
                      // },
                    ),
                    GoRoute(
                        path: 'create',
                        parentNavigatorKey: rootNavKey,
                        name: GameCreateScreen.routeName,
                        // redirect: (_, state) => provider.redirectLogic(state),
                        builder: (context, state) {
                          final int bottomIdx = int.parse(
                              state.uri.queryParameters['bottomIdx']!);
                          return GameCreateScreen(
                            bottomIdx: bottomIdx,
                          );
                        },
                        // pageBuilder: (context, state) {
                        //   return NoTransitionPage(child: GameCreateScreen());
                        // },
                        routes: [
                          GoRoute(
                            path: ':gameId/complete',
                            parentNavigatorKey: rootNavKey,
                            name: GameCreateCompleteScreen.routeName,
                            builder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);

                              final int bottomIdx = int.parse(
                                  state.uri.queryParameters['bottomIdx']!);
                              return GameCreateCompleteScreen(
                                gameId: gameId,
                                bottomIdx: bottomIdx,
                              );
                            },
                            // pageBuilder: (context, state) {
                            //   final int gameId =
                            //       int.parse(state.pathParameters['gameId']!);
                            //   return NoTransitionPage(
                            //       child: GameCreateCompleteScreen(
                            //     gameId: gameId,
                            //   ));
                            // },
                          ),
                        ]),
                    GoRoute(
                        path: ':gameId',
                        parentNavigatorKey: rootNavKey,
                        name: GameDetailScreen.routeName,
                        builder: (context, state) {
                          final int gameId =
                              int.parse(state.pathParameters['gameId']!);
                          final int bottomIdx = int.parse(
                              state.uri.queryParameters['bottomIdx']!);
                          return GameDetailScreen(
                            gameId: gameId,
                            bottomIdx: bottomIdx,
                          );
                        },
                        // pageBuilder: (context, state) {
                        //   final int gameId =
                        //       int.parse(state.pathParameters['gameId']!);
                        //   return NoTransitionPage(
                        //       child: GameDetailScreen(
                        //     gameId: gameId,
                        //   ));
                        // },
                        routes: [
                          GoRoute(
                            path: 'players',
                            parentNavigatorKey: rootNavKey,
                            name: GameParticipationScreen.routeName,
                            // redirect: (_, state) =>
                            //     provider.redirectLogic(state),
                            builder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);
                              final int bottomIdx = int.parse(
                                  state.uri.queryParameters['bottomIdx']!);
                              return GameParticipationScreen(
                                gameId: gameId,
                                bottomIdx: bottomIdx,
                              );
                            },
                            // pageBuilder: (context, state) {
                            //   final int gameId =
                            //       int.parse(state.pathParameters['gameId']!);
                            //   int? participationId;
                            //   if (state.uri.queryParameters
                            //       .containsKey('participationId')) {
                            //     participationId = int.parse(state
                            //         .uri.queryParameters['participationId']!);
                            //   }
                            //   return NoTransitionPage(
                            //       child: GameParticipationScreen(
                            //     gameId: gameId,
                            //     participationId: participationId,
                            //   ));
                            // },
                          ),
                          GoRoute(
                            path: 'review',
                            parentNavigatorKey: rootNavKey,
                            name: ReviewScreen.routeName,
                            // redirect: (_, state) =>
                            //     provider.redirectLogic(state),
                            builder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);
                              final int ratingId = int.parse(
                                  state.uri.queryParameters['ratingId']!);
                              int? participationId;
                              if (state.uri.queryParameters
                                  .containsKey('participationId')) {
                                participationId = int.parse(state
                                    .uri.queryParameters['participationId']!);
                              }
                              final int bottomIdx = int.parse(
                                  state.uri.queryParameters['bottomIdx']!);
                              return ReviewScreen(
                                gameId: gameId,
                                participationId: participationId,
                                ratingId: ratingId,
                                bottomIdx: bottomIdx,
                              );
                            },
                            // pageBuilder: (context, state) {
                            //   final int gameId =
                            //       int.parse(state.pathParameters['gameId']!);
                            //   final int ratingId = int.parse(
                            //       state.uri.queryParameters['ratingId']!);
                            //   int? participationId;
                            //   if (state.uri.queryParameters
                            //       .containsKey('participationId')) {
                            //     participationId = int.parse(state
                            //         .uri.queryParameters['participationId']!);
                            //   }
                            //   return NoTransitionPage(
                            //       child: ReviewScreen(
                            //     gameId: gameId,
                            //     participationId: participationId,
                            //     ratingId: ratingId,
                            //   ));
                            // },
                          ),
                          GoRoute(
                            path: 'cancel/:participationId',
                            parentNavigatorKey: rootNavKey,
                            name: GameRefundScreen.routeName,
                            // redirect: (_, state) =>
                            //     provider.redirectLogic(state),
                            builder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);
                              final int participationId = int.parse(
                                  state.pathParameters['participationId']!);
                              final int bottomIdx = int.parse(
                                  state.uri.queryParameters['bottomIdx']!);
                              return GameRefundScreen(
                                gameId: gameId,
                                participationId: participationId,
                                bottomIdx: bottomIdx,
                              );
                            },
                            // pageBuilder: (context, state) {
                            //   final int gameId =
                            //       int.parse(state.pathParameters['gameId']!);
                            //   final int participationId = int.parse(
                            //       state.pathParameters['participationId']!);
                            //   return NoTransitionPage(
                            //       child: GameRefundScreen(
                            //     gameId: gameId,
                            //     participationId: participationId,
                            //   ));
                            // },
                          ),
                          GoRoute(
                              path: 'paymentInfo',
                              parentNavigatorKey: rootNavKey,
                              name: GamePaymentScreen.routeName,
                              // redirect: (_, state) =>
                              //     provider.redirectLogic(state),
                              builder: (context, state) {
                                final int gameId =
                                    int.parse(state.pathParameters['gameId']!);
                                return GamePaymentScreen(
                                  gameId: gameId,
                                );
                              },
                              // pageBuilder: (context, state) {
                              //   final int gameId =
                              //       int.parse(state.pathParameters['gameId']!);
                              //
                              //   return NoTransitionPage(
                              //       child: GamePaymentScreen(
                              //     gameId: gameId,
                              //   ));
                              // },
                              routes: [
                                GoRoute(
                                  path: 'payment',
                                  parentNavigatorKey: rootNavKey,
                                  name: PaymentScreen.routeName,
                                  builder: (context, state) {
                                    final int gameId = int.parse(
                                        state.pathParameters['gameId']!);
                                    final String redirectUrl = state
                                        .uri.queryParameters['redirectUrl']!;
                                    return PaymentScreen(
                                      gameId: gameId,
                                      redirectUrl: redirectUrl,
                                    );
                                  },
                                  // pageBuilder: (context, state) {
                                  //   final int gameId = int.parse(
                                  //       state.pathParameters['gameId']!);
                                  //   final String redirectUrl = state
                                  //       .uri.queryParameters['redirectUrl']!;
                                  //
                                  //   return NoTransitionPage(
                                  //       child: PaymentScreen(
                                  //     gameId: gameId,
                                  //     redirectUrl: redirectUrl,
                                  //   ));
                                  // },
                                ),
                              ]),
                          GoRoute(
                            path: 'update',
                            parentNavigatorKey: rootNavKey,
                            name: GameUpdateScreen.routeName,
                            builder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);
                              final int bottomIdx = int.parse(
                                  state.uri.queryParameters['bottomIdx']!);
                              return GameUpdateScreen(
                                gameId: gameId,
                                bottomIdx: bottomIdx,
                              );
                            },
                            // pageBuilder: (context, state) {
                            //   final int gameId =
                            //       int.parse(state.pathParameters['gameId']!);
                            //   return NoTransitionPage(
                            //       child: GameUpdateScreen(
                            //     gameId: gameId,
                            //   ));
                            // },
                          ),
                        ]),
                  ]),
              GoRoute(
                  path: '/info',
                  parentNavigatorKey: shellNavKey,
                  name: InfoBody.routeName,
                  redirect: (_, state) => provider.redirectLogic(state),
                  builder: (context, state) {
                    return InfoBody();
                  },
                  pageBuilder: (context, state) {
                    return NoTransitionPage(child: InfoBody());
                  },
                  routes: [
                    GoRoute(
                      path: 'delete',
                      parentNavigatorKey: rootNavKey,
                      name: UserDeleteScreen.routeName,
                      builder: (context, state) {
                        final int bottomIdx =
                            int.parse(state.uri.queryParameters['bottomIdx']!);
                        return UserDeleteScreen(
                          bottomIdx: bottomIdx,
                        );
                      },
                      // pageBuilder: (context, state) {
                      //   return NoTransitionPage(child: UserDeleteScreen());
                      // },
                    ),
                    GoRoute(
                        path: 'support',
                        parentNavigatorKey: rootNavKey,
                        name: SupportScreen.routeName,
                        // redirect: (_, state) => provider.redirectLogic(state),
                        builder: (context, state) {
                          final int bottomIdx = int.parse(
                              state.uri.queryParameters['bottomIdx']!);

                          return SupportScreen(
                            bottomIdx: bottomIdx,
                          );
                        },
                        // pageBuilder: (context, state) {
                        //   return NoTransitionPage(child: SupportScreen());
                        // },
                        routes: [
                          GoRoute(
                            path: 'form',
                            parentNavigatorKey: rootNavKey,
                            name: SupportFormScreen.routeName,
                            // redirect: (_, state) =>
                            //     provider.redirectLogic(state),
                            builder: (context, state) {
                              final int bottomIdx = int.parse(
                                  state.uri.queryParameters['bottomIdx']!);
                              return SupportFormScreen(
                                bottomIdx: bottomIdx,
                              );
                            },
                            // pageBuilder: (context, state) {
                            //   return NoTransitionPage(
                            //       child: SupportFormScreen());
                            // },
                          ),
                          GoRoute(
                            path: ':questionId',
                            parentNavigatorKey: rootNavKey,
                            name: SupportDetailScreen.routeName,
                            // redirect: (_, state) =>
                            //     provider.redirectLogic(state),
                            builder: (context, state) {
                              final int questionId = int.parse(
                                  state.pathParameters['questionId']!);
                              final int bottomIdx = int.parse(
                                  state.uri.queryParameters['bottomIdx']!);
                              return SupportDetailScreen(
                                questionId: questionId,
                                bottomIdx: bottomIdx,
                              );
                            },
                            // pageBuilder: (context, state) {
                            //   final int questionId = int.parse(
                            //       state.pathParameters['questionId']!);
                            //   return NoTransitionPage(
                            //       child: SupportDetailScreen(
                            //     questionId: questionId,
                            //   ));
                            // },
                          ),
                        ]),
                    GoRoute(
                      path: 'bankTransfer',
                      parentNavigatorKey: rootNavKey,
                      name: BankTransferScreen.routeName,
                      // redirect: (_, state) => provider.redirectLogic(state),
                      builder: (context, state) {
                        final int bottomIdx =
                            int.parse(state.uri.queryParameters['bottomIdx']!);

                        return BankTransferScreen(
                          bottomIdx: bottomIdx,
                        );
                      },
                      // pageBuilder: (context, state) {
                      //   return NoTransitionPage(child: BankTransferScreen());
                      // },
                    ),
                    GoRoute(
                        path: 'settlements',
                        parentNavigatorKey: rootNavKey,
                        name: SettlementListScreen.routeName,
                        builder: (context, state) {
                          final int bottomIdx = int.parse(
                              state.uri.queryParameters['bottomIdx']!);
                          return SettlementListScreen(
                            bottomIdx: bottomIdx,
                          );
                        },
                        // pageBuilder: (context, state) {
                        //   return NoTransitionPage(
                        //       child: SettlementListScreen());
                        // },
                        routes: [
                          GoRoute(
                            path: ':settlementId',
                            parentNavigatorKey: rootNavKey,
                            name: SettlementDetailScreen.routeName,
                            builder: (context, state) {
                              final int settlementId = int.parse(
                                  state.pathParameters['settlementId']!);
                              final int bottomIdx = int.parse(
                                  state.uri.queryParameters['bottomIdx']!);
                              return SettlementDetailScreen(
                                settlementId: settlementId,
                                bottomIdx: bottomIdx,
                              );
                            },
                            // pageBuilder: (context, state) {
                            //   final int settlementId = int.parse(
                            //       state.pathParameters['settlementId']!);
                            //   return NoTransitionPage(
                            //       child: SettlementDetailScreen(
                            //     settlementId: settlementId,
                            //   ));
                            // },
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
                      // pageBuilder: (context, state) {
                      //   final extra = UserReviewType.stringToEnum(
                      //       value: state.extra! as String);
                      //   return NoTransitionPage(
                      //       child: UserWrittenReviewScreen(
                      //     type: extra,
                      //   ));
                      // },
                      routes: [
                        GoRoute(
                          path: ':reviewId',
                          parentNavigatorKey: rootNavKey,
                          name: ReviewDetailScreen.routeName,
                          builder: (_, state) {
                            final extra = state.extra! as UserReviewType;
                            final int reviewId =
                                int.parse(state.pathParameters['reviewId']!);
                            final int bottomIdx = int.parse(
                                state.uri.queryParameters['bottomIdx']!);

                            return ReviewDetailScreen(
                              reviewId: reviewId,
                              reviewType: extra,
                              bottomIdx: bottomIdx,
                            );
                          },
                          // pageBuilder: (context, state) {
                          //   final extra = state.extra! as UserReviewType;
                          //
                          //   final int reviewId =
                          //       int.parse(state.pathParameters['reviewId']!);
                          //   return NoTransitionPage(
                          //       child: ReviewDetailScreen(
                          //     reviewId: reviewId,
                          //     reviewType: extra,
                          //   ));
                          // },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'profileForm',
                      parentNavigatorKey: rootNavKey,
                      name: UserProfileFormScreen.routeName,
                      builder: (context, state) {
                        final int bottomIdx =
                            int.parse(state.uri.queryParameters['bottomIdx']!);

                        return UserProfileFormScreen(
                          bottomIdx: bottomIdx,
                        );
                      },
                      // pageBuilder: (context, state) {
                      //   return NoTransitionPage(child: UserProfileFormScreen());
                      // },
                    ),
                    GoRoute(
                      path: ':accountId/transferForm',
                      parentNavigatorKey: rootNavKey,
                      name: BankTransferFormScreen.routeName,
                      builder: (context, state) {
                        final int accountId =
                            int.parse(state.pathParameters['accountId']!);
                        final int bottomIdx =
                            int.parse(state.uri.queryParameters['bottomIdx']!);
                        return BankTransferFormScreen(
                          accountId: accountId,
                          bottomIdx: bottomIdx,
                        );
                      },
                      // pageBuilder: (context, state) {
                      //   final int accountId =
                      //       int.parse(state.pathParameters['accountId']!);
                      //   return NoTransitionPage(
                      //       child: BankTransferFormScreen(
                      //     accountId: accountId,
                      //   ));
                      // },
                    ),
                  ]),
              GoRoute(
                path: '/menu',
                parentNavigatorKey: shellNavKey,
                redirect: (_, state) => provider.redirectLogic(state),
                name: MenuBody.routeName,
                builder: (context, state) {
                  return MenuBody();
                },
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: MenuBody());
                },
                routes: [
                  GoRoute(
                    path: 'faq',
                    parentNavigatorKey: rootNavKey,
                    name: FAQScreen.routeName,
                    builder: (context, state) {
                      final int bottomIdx =
                          int.parse(state.uri.queryParameters['bottomIdx']!);
                      return FAQScreen(
                        bottomIdx: bottomIdx,
                      );
                    },
                    // pageBuilder: (context, state) {
                    //   return NoTransitionPage(child: FAQScreen());
                    // },
                  ),
                  GoRoute(
                      path: 'court',
                      parentNavigatorKey: rootNavKey,
                      name: CourtSearchScreen.routeName,
                      builder: (context, state) {
                        final int bottomIdx =
                            int.parse(state.uri.queryParameters['bottomIdx']!);
                        return CourtSearchScreen(
                          bottomIdx: bottomIdx,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: ':courtId',
                          parentNavigatorKey: rootNavKey,
                          name: CourtGameListScreen.routeName,
                          builder: (context, state) {
                            final int courtId =
                                int.parse(state.pathParameters['courtId']!);
                            final CourtSearchModel extra =
                                state.extra! as CourtSearchModel;
                            final int bottomIdx = int.parse(
                                state.uri.queryParameters['bottomIdx']!);
                            return CourtGameListScreen(
                              courtId: courtId,
                              model: extra,
                              bottomIdx: bottomIdx,
                            );
                          },
                        ),
                      ]),
                ],
              ),
            ]),
      ]);
});
