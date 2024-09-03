import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../court/view/court_map_screen.dart';
import '../../court/view/court_search_screen.dart';
import '../../default_screen.dart';
import '../../game/view/game_screen.dart';
import '../../menu/view/menu_screen.dart';
import '../../theme/color_theme.dart';
import '../../user/view/user_info_screen.dart';

class DefaultLayout extends StatefulWidget {
  final int bottomIdx;
  final Widget body;
  final ScrollController scrollController;

  const DefaultLayout({
    super.key,
    required this.bottomIdx,
    required this.scrollController,
    required this.body,
  });

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (v) => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MITIColor.gray800,
        body: widget.body,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: CustomBottomNavigationBar(
          index: widget.bottomIdx,
          onTap: (int page) {
            log('page = $page');
            if (page == widget.bottomIdx) {
              widget.scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
              return;
            }
            if (page == 0) {
              context.goNamed(CourtMapScreen.routeName);
            } else if (page == 1) {
              context.goNamed(GameScreen.routeName);
            } else if (page == 2) {
              context.goNamed(CourtSearchScreen.routeName);
            } else {
              context.goNamed(MenuBody.routeName);
            }
          },
        ),
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  final Widget button;

  const BottomButton({super.key, required this.button});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: MITIColor.gray600,
            width: 1.h,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 18.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          button,
          if (Platform.isIOS) SizedBox(height: 21.h),
        ],
      ),
    );
  }
}
