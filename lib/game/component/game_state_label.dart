import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/entity_enum.dart';

class GameStateLabel extends StatelessWidget {
  final GameStatusType gameStatus;

  const GameStateLabel({super.key, required this.gameStatus});

  @override
  Widget build(BuildContext context) {
    late Color backgroundColor;
    late Color textColor;

    switch (gameStatus) {
      case GameStatusType.open:
        backgroundColor = const Color(0xFF9DB6D4);
        textColor = const Color(0xFF303FC5);
        break;
      case GameStatusType.closed:
        backgroundColor = const Color(0xFF92D2D4);
        textColor = const Color(0xFF00797B);
        break;
      case GameStatusType.completed:
        backgroundColor = const Color(0xFFC1C1C1);
        textColor = const Color(0xFF484848);
        break;
      case GameStatusType.canceled:
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
      case ReviewType.hostReview:
        backgroundColor = const Color(0xFF0087E9).withOpacity(0.3);
        textColor = const Color(0xFF0087E9);
        break;
      case ReviewType.guestReview:
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
  final SettlementStatusType settlementType;

  const SettlementLabel({super.key, required this.settlementType});

  @override
  Widget build(BuildContext context) {
    late Color textColor;

    switch (settlementType) {
      /// 정산 완료
      case SettlementStatusType.completed:
        textColor = const Color(0xFF58CDFF);
        break;

      /// 정산 대기중
      case SettlementStatusType.waiting:
        textColor = MITIColor.gray200;
        break;

      /// 부분 정산 완료
      case SettlementStatusType.partiallyCompleted:
        textColor = const Color(0xFFFFDC62);
        break;

      /// 정산 취소
      case SettlementStatusType.canceled:
        textColor = const Color(0xFFEE5F8A);
        break;

      /// 정산 정지
      case SettlementStatusType.suspended:
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
  final BankTransferStatusType transferType;

  const TransferLabel({super.key, required this.transferType});

  @override
  Widget build(BuildContext context) {
    late Color textColor;

    switch (transferType) {
      case BankTransferStatusType.completed:
        textColor = const Color(0xFF58CDFF);
        break;
      case BankTransferStatusType.waiting:
        textColor = MITIColor.gray200;
        break;
      case BankTransferStatusType.declined:
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
