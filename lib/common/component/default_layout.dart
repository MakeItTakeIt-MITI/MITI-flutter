import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../court/view/court_map_screen.dart';
import '../../court/view/court_search_screen.dart';
import '../../default_screen.dart';
import '../../game/view/game_screen.dart';
import '../../user/view/profile_menu_screen.dart';
import '../../theme/color_theme.dart';

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
            } else if (page == 1) {
              context.goNamed(CourtSearchListScreen.routeName);
            } else if (page == 2) {
              context.goNamed(CourtMapScreen.routeName);
            } else if(page== 3){
              context.goNamed(GameScreen.routeName);
            }else if(page == 4){
              context.goNamed(ProfileBody.routeName);
            }
          },
        ),
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  final Widget button;
  final bool hasBorder;

  const BottomButton({super.key, required this.button, this.hasBorder = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: hasBorder
            ? Border(
                top: BorderSide(
                  color: MITIColor.gray600,
                  width: 1.h,
                ),
              )
            : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
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
