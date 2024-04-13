import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/model/entity_enum.dart';

class GameStateLabel extends StatelessWidget {
  final GameStatus gameStatus;

  const GameStateLabel({super.key, required this.gameStatus});

  @override
  Widget build(BuildContext context) {
    late Color backgroundColor;
    late Color textColor;

    switch (gameStatus) {
      case GameStatus.open:
        backgroundColor = const Color(0xFFC0DDFF);
        textColor = const Color(0xFF0019FF);
        break;
      case GameStatus.closed:
        backgroundColor = const Color(0xFFDBFFDF);
        textColor = const Color(0xFF33FF00);
        break;
      case GameStatus.completed:
        backgroundColor = const Color(0xFFF5CCFF);
        textColor = const Color(0xFFCA00FC);
        break;
      case GameStatus.canceled:
        backgroundColor = const Color(0xFFFFC0C0);
        textColor = const Color(0xFFFC0000);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.r),
        color: backgroundColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Text(
        gameStatus.displayName,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}