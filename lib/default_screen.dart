import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';
import 'court/view/court_map_screen.dart';
import 'court/view/court_search_screen.dart';
import 'game/view/game_screen.dart';
import 'user/view/profile_menu_screen.dart';

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
    } else if (GoRouterState.of(context).matchedLocation.startsWith('/court')) {
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
        backgroundColor: MITIColor.gray800,
        body: widget.body,
        bottomNavigationBar: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final scrollController = ref.watch(scrollControllerProvider);
            return CustomBottomNavigationBar(
              index: index,
              onTap: (int page) {
                if (page == 0) {
                  if (GoRouterState.of(context)
                      .matchedLocation
                      .startsWith('/home')) {

                  } else {
                    context.goNamed(CourtMapScreen.routeName);
                  }
                } else if (page == 1) {
                  if (GoRouterState.of(context)
                      .matchedLocation
                      .startsWith('/game')) {
                    _scrollTop(scrollController);
                  } else {
                    context.goNamed(GameScreen.routeName);
                  }
                } else if (page == 2) {
                  if (GoRouterState.of(context)
                      .matchedLocation
                      .startsWith('/court')) {
                    _scrollTop(scrollController);
                  } else {
                    context.goNamed(CourtSearchListScreen.routeName);
                  }
                } else {
                  if (GoRouterState.of(context)
                      .matchedLocation
                      .startsWith('/menu')) {
                    _scrollTop(scrollController);
                  } else {
                    context.goNamed(ProfileBody.routeName);
                  }
                }
              },
            );
          },
        ));
  }

  void _scrollTop(ScrollController? scrollController) {
    if (scrollController != null && scrollController.position.pixels > 0) {
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
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
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: MITIColor.gray700)),
        color: MITIColor.gray900,
      ),
      constraints: BoxConstraints.tight(Size(double.infinity, 86.h)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // SizedBox(height: 40.w),
          CustomBottomItem(
            onTap: () {
              onTap(0);
            },
            label: '홈',
            selected: index == 0,
            iconName: index == 0 ? 'home' : 'home',
          ),
          // const Spacer(),
          CustomBottomItem(
            onTap: () {
              onTap(1);
            },
            label: '내 경기',
            selected: index == 1,
            iconName: index == 1 ? 'game' : 'game',
          ),
          // const Spacer(),
          CustomBottomItem(
            onTap: () {
              onTap(2);
            },
            label: '경기장',
            selected: index == 2,
            iconName: index == 2 ? 'court' : 'court',
          ),
          // const Spacer(),
          CustomBottomItem(
            onTap: () {
              onTap(3);
            },
            label: '마이페이지',
            selected: index == 3,
            iconName: index == 3 ? 'profile' : 'profile',
          ),
          // SizedBox(height: 40.w),
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
    final textStyle = MITITextStyle.xxsmSemiBold;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 11.h,
          ),
          SvgPicture.asset(
            AssetUtil.getAssetPath(type: AssetType.icon, name: iconName),
            height: 24.r,
            width: 24.r,
            colorFilter: ColorFilter.mode(
                selected ? MITIColor.gray100 : MITIColor.gray500,
                BlendMode.srcIn),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: textStyle.copyWith(
              color: selected ? MITIColor.gray100 : MITIColor.gray500,
            ),
          )
        ],
      ),
    );
  }
}
