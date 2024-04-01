import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/find_info/find_password_screen.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_info_screen.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_screen.dart';

import '../../auth/view/find_info/find_email_screen.dart';
import '../../auth/view/find_info/find_info_screen.dart';
import '../../auth/view/phone_auth/phone_auth_send_screen.dart';
import '../../auth/view/signup/signup_screen.dart';
import '../../auth/view/signup/signup_select_screen.dart';
import '../../game/view/game_body.dart';
import '../../home_screen.dart';

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
                name: HomBody.routeName,
                builder: (context, state) {
                  return HomBody();
                },
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: HomBody());
                },
              ),
              GoRoute(
                path: '/game',
                parentNavigatorKey: shellNavKey,
                name: GameBody.routeName,
                builder: (context, state) {
                  return GameBody();
                },
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: GameBody());
                },
              ),
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
              ),
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
        GoRoute(
            path: '/login',
            parentNavigatorKey: rootNavKey,
            name: LoginScreen.routeName,
            builder: (_, state) => const LoginScreen(),
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: LoginScreen());
            },
            routes: [
              GoRoute(
                path: 'phoneSuccess',
                parentNavigatorKey: rootNavKey,
                name: PhoneAuthSuccess.routeName,
                builder: (_, state) => const PhoneAuthSuccess(),
                pageBuilder: (context, state) {
                  return const NoTransitionPage(child: PhoneAuthSuccess());
                },
              ),
              GoRoute(
                path: 'phoneSend',
                parentNavigatorKey: rootNavKey,
                name: PhoneAuthSendScreen.routeName,
                builder: (_, state) => const PhoneAuthSendScreen(),
                pageBuilder: (context, state) {
                  return const NoTransitionPage(child: PhoneAuthSendScreen());
                },
              ),
              GoRoute(
                  path: 'findInfo',
                  parentNavigatorKey: rootNavKey,
                  name: FindInfoScreen.routeName,
                  builder: (_, state) {
                    final String findInfo =
                        state.uri.queryParameters['findInfo']!;
                    return FindInfoScreen(
                      findInfo: findInfo,
                    );
                  },
                  pageBuilder: (context, state) {
                    final String findInfo =
                        state.uri.queryParameters['findInfo']!;
                    return NoTransitionPage(
                        child: FindInfoScreen(
                      findInfo: findInfo,
                    ));
                  },
                  routes: [
                    GoRoute(
                      path: 'findEmail',
                      parentNavigatorKey: rootNavKey,
                      name: FindEmailScreen.routeName,
                      builder: (_, state) {
                        final isOauth =
                            bool.parse(state.uri.queryParameters['isOauth']!);
                        final email = state.uri.queryParameters['email']!;
                        return FindEmailScreen(
                          findEmail: email,
                          isOauth: isOauth,
                        );
                      },
                      pageBuilder: (context, state) {
                        final isOauth =
                            bool.parse(state.uri.queryParameters['isOauth']!);
                        final email = state.uri.queryParameters['email']!;
                        return NoTransitionPage(
                            child: FindEmailScreen(
                          findEmail: email,
                          isOauth: isOauth,
                        ));
                      },
                    ),
                    GoRoute(
                      path: 'findPasswordByEmail',
                      parentNavigatorKey: rootNavKey,
                      name: FindPasswordByEmailScreen.routeName,
                      builder: (_, state) {
                        final email = state.uri.queryParameters['email']!;
                        return FindPasswordByEmailScreen(
                          email: email,
                        );
                      },
                      pageBuilder: (context, state) {
                        final email = state.uri.queryParameters['email']!;
                        return NoTransitionPage(
                            child: FindPasswordByEmailScreen(
                          email: email,
                        ));
                      },
                    ),
                    GoRoute(
                      path: 'notFoundUser',
                      parentNavigatorKey: rootNavKey,
                      name: NotFoundUserInfoScreen.routeName,
                      builder: (_, state) => const NotFoundUserInfoScreen(),
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
                    return const NoTransitionPage(child: SignUpSelectScreen());
                  },
                  routes: [
                    GoRoute(
                      path: 'signUp',
                      parentNavigatorKey: rootNavKey,
                      name: SignUpScreen.routeName,
                      builder: (_, state) => const SignUpScreen(),
                      pageBuilder: (context, state) {
                        return const NoTransitionPage(child: SignUpScreen());
                      },
                    ),
                  ]),
              GoRoute(
                  path: 'phoneAuth',
                  parentNavigatorKey: rootNavKey,
                  name: PhoneAuthScreen.routeName,
                  builder: (_, state) => const PhoneAuthScreen(),
                  pageBuilder: (context, state) {
                    return const NoTransitionPage(child: PhoneAuthScreen());
                  },
                  routes: [
                    GoRoute(
                        path: 'phoneAuthInfo',
                        parentNavigatorKey: rootNavKey,
                        name: PhoneAuthInfoScreen.routeName,
                        builder: (_, state) => const PhoneAuthInfoScreen(),
                        pageBuilder: (context, state) {
                          return const NoTransitionPage(
                              child: PhoneAuthInfoScreen());
                        },
                        routes: []),
                  ]),
            ]),
      ]);
});
