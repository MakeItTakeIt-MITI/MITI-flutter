import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'game/view/game_body.dart';

part 'home_screen.g.dart';

@Riverpod(keepAlive: true)
class PageScrollController extends _$PageScrollController {
  @override
  List<ScrollController> build() {
    return [
      ScrollController(),
      ScrollController(),
      ScrollController(),
      ScrollController(),
    ];
  }
}

class ShellRoutePageState with ChangeNotifier {
  ScrollController topController = ScrollController();
  ScrollController bottomController = ScrollController();

  void onScroll(double offset) {
    double topMax = topController.position.maxScrollExtent;
    double topOffset = min(topMax, offset);
    topController.jumpTo(topOffset);

    double bottomOffset = max(0, offset - topMax);
    bottomController.jumpTo(bottomOffset);
  }
}

class HomBody extends StatelessWidget {
  static String get routeName => 'home';

  const HomBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            centerTitle: true,
            title: Text('나의 참여 경기',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000000),
                )),
          ),
        ];
      },
      body: CustomScrollView(slivers: [

      ],),
    );
  }
}



class InfoBody extends StatelessWidget {
  static String get routeName => 'info';

  const InfoBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.pushNamed(LoginScreen.routeName);
        },
        child: Text('로그인'),
      ),
    );
  }
}

class MenuBody extends StatelessWidget {
  static String get routeName => 'menu';

  const MenuBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.pushNamed(LoginScreen.routeName);
        },
        child: Text('로그인'),
      ),
    );
  }
}

class DefaultShellScreen extends StatefulWidget {
  final Widget body;

  const DefaultShellScreen({super.key, required this.body});

  @override
  State<DefaultShellScreen> createState() => _DefaultShellScreenState();
}

class _DefaultShellScreenState extends State<DefaultShellScreen> {
  @override
  void initState() {
    super.initState();
  }

  int getIndex(BuildContext context) {
    if (GoRouterState.of(context).matchedLocation == '/home') {
      return 0;
    } else if (GoRouterState.of(context).matchedLocation == '/game') {
      return 1;
    } else if (GoRouterState.of(context).matchedLocation == '/info') {
      return 2;
    } else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = getIndex(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: widget.body,
        bottomNavigationBar: CustomBottomNavigationBar(
          index: index,
          onTap: (int page) {
            log('page $page index $index');
            if (page == 0) {
              context.goNamed(HomBody.routeName);
            } else if (page == 1) {
              context.goNamed(GameBody.routeName);
            } else if (page == 2) {
              context.goNamed(InfoBody.routeName);
            } else {
              context.goNamed(MenuBody.routeName);
            }
          },
        ));
  }
}

typedef BottomTap = void Function(int page);

class CustomBottomNavigationBar extends StatelessWidget {
  final int index;
  final BottomTap onTap;

  const CustomBottomNavigationBar(
      {super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.1),
              offset: Offset(0, 1.h),
              blurRadius: 3.r,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.08),
              offset: Offset(0, -1.h),
              blurRadius: 1.r,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.06),
              offset: Offset(0, -1.h),
              blurRadius: 2.r,
            ),
          ]),
      constraints: BoxConstraints.tight(Size(double.infinity, 80.h)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(0);
              },
              label: '홈',
              selected: index == 0,
              iconName: 'home',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(1);
              },
              label: '경기',
              selected: index == 1,
              iconName: 'play',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(2);
              },
              label: '내정보',
              selected: index == 2,
              iconName: 'info',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(3);
              },
              label: '전체',
              selected: index == 3,
              iconName: 'menu',
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomItem extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool selected;
  final String iconName;

  const CustomBottomItem(
      {super.key,
      required this.onTap,
      required this.label,
      required this.selected,
      required this.iconName});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
    );
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/icon/$iconName.svg',
            height: 24.r,
            width: 24.r,
            colorFilter: ColorFilter.mode(
                selected ? const Color(0xFF4065F6) : const Color(0xFF969696),
                BlendMode.srcIn),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: textStyle.copyWith(
              color:
                  selected ? const Color(0xFF4065F6) : const Color(0xFF969696),
            ),
          )
        ],
      ),
    );
  }
}
