import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/find_info/find_password_screen.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_info_screen.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_screen.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/game/view/game_host_list_screen.dart';

import '../../auth/view/find_info/find_email_screen.dart';
import '../../auth/view/find_info/find_info_screen.dart';
import '../../auth/view/phone_auth/phone_auth_send_screen.dart';
import '../../auth/view/signup/signup_screen.dart';
import '../../auth/view/signup/signup_select_screen.dart';
import '../../game/view/game_list_screen.dart';
import '../../default_screen.dart';
import '../../court/view/court_map_screen.dart';
import '../../game/view/game_screen.dart';

final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
      initialLocation: '/home',
      debugLogDiagnostics: true,
      navigatorKey: rootNavKey,
      routes: <RouteBase>[
        ShellRoute(
            navigatorKey: shellNavKey,
            builder: (context, state, child) {
              return DefaultShellScreen(body: child);
            },
            routes: [
              GoRoute(
                path: '/home',
                parentNavigatorKey: shellNavKey,
                name: CourtMapScreen.routeName,
                builder: (context, state) {
                  return CourtMapScreen();
                },
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: CourtMapScreen());
                },
              ),
              GoRoute(
                  path: '/game',
                  parentNavigatorKey: shellNavKey,
                  name: GameScreen.routeName,
                  builder: (context, state) {
                    return GameScreen();
                  },
                  pageBuilder: (context, state) {
                    return NoTransitionPage(child: GameScreen());
                  },
                  routes: [
                    GoRoute(
                      path: 'create',
                      parentNavigatorKey: rootNavKey,
                      name: GameCreateScreen.routeName,
                      builder: (context, state) {
                        return GameCreateScreen();
                      },
                      pageBuilder: (context, state) {
                        return NoTransitionPage(child: GameCreateScreen());
                      },
                    ),
                    GoRoute(
                      path: 'host',
                      parentNavigatorKey: rootNavKey,
                      name: GameHostScreen.routeName,
                      builder: (context, state) {
                        return GameHostScreen();
                      },
                      pageBuilder: (context, state) {
                        return NoTransitionPage(child: GameHostScreen());
                      },
                    ),
                    GoRoute(
                        path: 'participation',
                        parentNavigatorKey: rootNavKey,
                        name: GameParticipationScreen.routeName,
                        builder: (context, state) {
                          return GameParticipationScreen();
                        },
                        pageBuilder: (context, state) {
                          return NoTransitionPage(child: GameParticipationScreen());
                        },
                        routes: [
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
                            pageBuilder: (context, state) {
                              final int gameId =
                                  int.parse(state.pathParameters['gameId']!);

                              return NoTransitionPage(
                                  child: GameDetailScreen(
                                gameId: gameId,
                              ));
                            },
                          ),
                        ]),
                  ]),
              GoRoute(
                  path: '/info',
                  parentNavigatorKey: shellNavKey,
                  name: InfoBody.routeName,
                  builder: (context, state) {
                    return InfoBody();
                  },
                  pageBuilder: (context, state) {
                    return NoTransitionPage(child: InfoBody());
                  },
                  routes: [
                    GoRoute(
                        path: 'login',
                        parentNavigatorKey: rootNavKey,
                        name: LoginScreen.routeName,
                        builder: (_, state) => const LoginScreen(),
                        pageBuilder: (context, state) {
                          return const NoTransitionPage(child: LoginScreen());
                        },
                        routes: [
                          GoRoute(
                            path: 'completeResetPassword',
                            parentNavigatorKey: rootNavKey,
                            name: CompleteRestPasswordScreen.routeName,
                            builder: (_, state) =>
                                const CompleteRestPasswordScreen(),
                            pageBuilder: (context, state) {
                              return const NoTransitionPage(
                                  child: CompleteRestPasswordScreen());
                            },
                          ),
                          GoRoute(
                            path: 'phoneSuccess',
                            parentNavigatorKey: rootNavKey,
                            name: PhoneAuthSuccess.routeName,
                            builder: (_, state) => const PhoneAuthSuccess(),
                            pageBuilder: (context, state) {
                              return const NoTransitionPage(
                                  child: PhoneAuthSuccess());
                            },
                          ),
                          GoRoute(
                            path: 'phoneSend',
                            parentNavigatorKey: rootNavKey,
                            name: PhoneAuthSendScreen.routeName,
                            builder: (_, state) => const PhoneAuthSendScreen(),
                            pageBuilder: (context, state) {
                              return const NoTransitionPage(
                                  child: PhoneAuthSendScreen());
                            },
                          ),
                          GoRoute(
                              path: 'findInfo',
                              parentNavigatorKey: rootNavKey,
                              name: FindInfoScreen.routeName,
                              builder: (_, state) {
                                return FindInfoScreen();
                              },
                              pageBuilder: (context, state) {
                                return NoTransitionPage(
                                    child: FindInfoScreen());
                              },
                              routes: [
                                GoRoute(
                                  path: 'findEmail',
                                  parentNavigatorKey: rootNavKey,
                                  name: FindEmailScreen.routeName,
                                  builder: (_, state) {
                                    final isOauth = bool.parse(
                                        state.uri.queryParameters['isOauth']!);
                                    final email =
                                        state.uri.queryParameters['email']!;
                                    return FindEmailScreen(
                                      findEmail: email,
                                      isOauth: isOauth,
                                    );
                                  },
                                  pageBuilder: (context, state) {
                                    final isOauth = bool.parse(
                                        state.uri.queryParameters['isOauth']!);
                                    final email =
                                        state.uri.queryParameters['email']!;
                                    return NoTransitionPage(
                                        child: FindEmailScreen(
                                      findEmail: email,
                                      isOauth: isOauth,
                                    ));
                                  },
                                ),
                                GoRoute(
                                  path: 'resetPassword',
                                  parentNavigatorKey: rootNavKey,
                                  name: ResetPasswordScreen.routeName,
                                  builder: (_, state) {
                                    return ResetPasswordScreen();
                                  },
                                  pageBuilder: (context, state) {
                                    return NoTransitionPage(
                                        child: ResetPasswordScreen());
                                  },
                                ),
                                GoRoute(
                                  path: 'notFoundUser',
                                  parentNavigatorKey: rootNavKey,
                                  name: NotFoundUserInfoScreen.routeName,
                                  builder: (_, state) =>
                                      const NotFoundUserInfoScreen(),
                                  pageBuilder: (context, state) {
                                    return const NoTransitionPage(
                                        child: NotFoundUserInfoScreen());
                                  },
                                ),
                              ]),
                          GoRoute(
                              path: 'signUpSelect',
                              parentNavigatorKey: rootNavKey,
                              name: SignUpSelectScreen.routeName,
                              builder: (_, state) => const SignUpSelectScreen(),
                              pageBuilder: (context, state) {
                                return const NoTransitionPage(
                                    child: SignUpSelectScreen());
                              },
                              routes: [
                                GoRoute(
                                  path: 'signUp',
                                  parentNavigatorKey: rootNavKey,
                                  name: SignUpScreen.routeName,
                                  builder: (_, state) => const SignUpScreen(),
                                  pageBuilder: (context, state) {
                                    return const NoTransitionPage(
                                        child: SignUpScreen());
                                  },
                                ),
                              ]),
                          GoRoute(
                              path: 'phoneAuth',
                              parentNavigatorKey: rootNavKey,
                              name: PhoneAuthScreen.routeName,
                              builder: (_, state) => const PhoneAuthScreen(),
                              pageBuilder: (context, state) {
                                return const NoTransitionPage(
                                    child: PhoneAuthScreen());
                              },
                              routes: [
                                GoRoute(
                                    path: 'phoneAuthInfo',
                                    parentNavigatorKey: rootNavKey,
                                    name: PhoneAuthInfoScreen.routeName,
                                    builder: (_, state) =>
                                        const PhoneAuthInfoScreen(),
                                    pageBuilder: (context, state) {
                                      return const NoTransitionPage(
                                          child: PhoneAuthInfoScreen());
                                    },
                                    routes: []),
                              ]),
                        ]),
                  ]),
              GoRoute(
                path: '/menu',
                parentNavigatorKey: shellNavKey,
                name: MenuBody.routeName,
                builder: (context, state) {
                  return MenuBody();
                },
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: MenuBody());
                },
              ),
            ]),
      ]);
});
