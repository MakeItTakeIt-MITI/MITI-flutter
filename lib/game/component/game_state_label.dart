import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';
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
  final SettlementType settlementType;

  const SettlementLabel({super.key, required this.settlementType});

  @override
  Widget build(BuildContext context) {
    late Color textColor;

    switch (settlementType) {
      /// 정산 완료
      case SettlementType.completed:
        textColor = const Color(0xFF58CDFF);
        break;

      /// 정산 대기중
      case SettlementType.waiting:
        textColor = MITIColor.gray200;
        break;

      /// 부분 정산 완료
      case SettlementType.partiallyCompleted:
        textColor = const Color(0xFFFFDC62);
        break;

      /// 정산 취소
      case SettlementType.canceled:
        textColor = const Color(0xFFEE5F8A);
        break;

      /// 정산 정지
      case SettlementType.suspended:
        textColor = const Color(0xFFEE5F8A);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: MITIColor.gray600,
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Text(
        settlementType.name,
        style: MITITextStyle.tagStyle.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}

class TransferLabel extends StatelessWidget {
  final TransferType transferType;

  const TransferLabel({super.key, required this.transferType});

  @override
  Widget build(BuildContext context) {
    late Color textColor;

    switch (transferType) {
      case TransferType.completed:
        textColor = const Color(0xFF58CDFF);
        break;
      case TransferType.waiting:
        textColor = MITIColor.gray200;
        break;
      case TransferType.declined:
        textColor = const Color(0xFFEE5F8A);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: MITIColor.gray600,
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Text(
        transferType.name,
        style: MITITextStyle.tagStyle.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
