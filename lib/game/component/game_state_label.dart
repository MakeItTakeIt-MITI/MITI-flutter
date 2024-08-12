import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/text_theme.dart';

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
        backgroundColor = const Color(0xFF9DB6D4);
        textColor = const Color(0xFF303FC5);
        break;
      case GameStatus.closed:
        backgroundColor = const Color(0xFF92D2D4);
        textColor = const Color(0xFF00797B);
        break;
      case GameStatus.completed:
        backgroundColor = const Color(0xFFC1C1C1);
        textColor = const Color(0xFF484848);
        break;
      case GameStatus.canceled:
        backgroundColor = const Color(0xFFE9C4D3);
        textColor = const Color(0xFFDB0059);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.r),
        color: backgroundColor,
      ),
      padding: EdgeInsets.all(4.r),
      child: Text(
        gameStatus.displayName,
        style: MITITextStyle.xxxsmBold.copyWith(color: textColor),
      ),
    );
  }
}

class ReviewLabel extends StatelessWidget {
  final ReviewType reviewType;

  const ReviewLabel({super.key, required this.reviewType});

  @override
  Widget build(BuildContext context) {
    late Color backgroundColor;
    late Color textColor;

    switch (reviewType) {
      case ReviewType.host:
        backgroundColor = const Color(0xFF0087E9).withOpacity(0.3);
        textColor = const Color(0xFF0087E9);
        break;
      case ReviewType.guest:
        backgroundColor = const Color(0xFF43D000).withOpacity(0.3);
        textColor = const Color(0xFF43D000);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.r),
        color: backgroundColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Text(
        reviewType.displayName,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          height: 13 / 10,
          letterSpacing: -0.25.sp,
          color: textColor,
        ),
      ),
    );
  }
}

class SettlementLabel extends StatelessWidget {
  final SettlementType bankType;

  const SettlementLabel({super.key, required this.bankType});

  @override
  Widget build(BuildContext context) {
    late Color backgroundColor;
    late Color textColor;

    switch (bankType) {
      case SettlementType.completed:
        backgroundColor = const Color(0xFFDBFFDF);
        textColor = const Color(0xFF33FF00);
        break;
      case SettlementType.waiting:
        backgroundColor = const Color(0xFFFFC0C0);
        textColor = const Color(0xFFFF0000);
        break;
      case SettlementType.partial_completed:
        backgroundColor = const Color(0xFFC0DDFF);
        textColor = const Color(0xFF0019FF);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.r),
        color: backgroundColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Text(
        bankType.name,
        style: MITITextStyle.tagStyle.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}

class BankLabel extends StatelessWidget {
  final BankType bankType;

  const BankLabel({super.key, required this.bankType});

  @override
  Widget build(BuildContext context) {
    late Color backgroundColor;
    late Color textColor;

    switch (bankType) {
      case BankType.completed:
        backgroundColor = const Color(0xFFDBFFDF);
        textColor = const Color(0xFF33FF00);
        break;
      case BankType.waiting:
        backgroundColor = const Color(0xFFC0DDFF);
        textColor = const Color(0xFF0019FF);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.r),
        color: backgroundColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Text(
        bankType.name,
        style: MITITextStyle.tagStyle.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
