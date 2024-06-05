import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/view/user_info_screen.dart';
import 'court/view/court_map_screen.dart';
import 'game/view/game_screen.dart';
import 'menu/view/menu_screen.dart';

final contextProvider = StateProvider<BuildContext?>((ref) => null);

class DefaultShellScreen extends ConsumerStatefulWidget {
  final Widget body;

  const DefaultShellScreen({super.key, required this.body});

  @override
  ConsumerState<DefaultShellScreen> createState() => _DefaultShellScreenState();
}

class _DefaultShellScreenState extends ConsumerState<DefaultShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(contextProvider.notifier).update((state) => context);
    });
  }

  int getIndex(BuildContext context) {
    if (GoRouterState.of(context).matchedLocation.startsWith('/home')) {
      return 0;
    } else if (GoRouterState.of(context).matchedLocation.startsWith('/game')) {
      return 1;
    } else if (GoRouterState.of(context).matchedLocation.startsWith('/info')) {
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
        backgroundColor: Colors.white,
        body: widget.body,
        bottomNavigationBar: CustomBottomNavigationBar(
          index: index,
          onTap: (int page) {
            if (page == 0) {
              if (GoRouterState.of(context)
                  .matchedLocation
                  .startsWith('/home')) {
                // controller[0].animateTo(0,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut);
              } else {
                context.goNamed(CourtMapScreen.routeName);
              }
            } else if (page == 1) {
              if (GoRouterState.of(context)
                  .matchedLocation
                  .startsWith('/game')) {
                // controller[1].animateTo(0,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut);
              } else {
                context.goNamed(GameScreen.routeName);
              }
            } else if (page == 2) {
              if (GoRouterState.of(context)
                  .matchedLocation
                  .startsWith('/info')) {
                // controller[2].animateTo(0,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut);
              } else {
                context.goNamed(InfoBody.routeName);
              }
            } else {
              if (GoRouterState.of(context)
                  .matchedLocation
                  .startsWith('/menu')) {
                // controller[3].animateTo(0,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut);
              } else {
                context.goNamed(MenuBody.routeName);
              }
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
              iconName: index == 0 ? 'fill_home' : 'unfill_home',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(1);
              },
              label: '경기',
              selected: index == 1,
              iconName: index == 1 ? 'fill_game' : 'unfill_game',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(2);
              },
              label: '내정보',
              selected: index == 2,
              iconName: index == 2 ? 'fill_info' : 'unfill_info',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(3);
              },
              label: '전체',
              selected: index == 3,
              iconName: index == 3 ? 'fill_menu' : 'unfill_menu',
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
    final textStyle = MITITextStyle.menuCategoryStyle;
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
