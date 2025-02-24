
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/theme/color_theme.dart';

import '../../common/model/entity_enum.dart';
import '../../game/model/v2/account/base_bank_transfer_response.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../model/transfer_model.dart';


class BankTransferCard extends ConsumerWidget {
  final int id;
  final String amount;
  final String account_bank;
  final String account_holder;
  final String account_number;
  final BankTransferStatusType status;
  final String created_at;

  const BankTransferCard(
      {super.key,
      required this.id,
      required this.amount,
      required this.account_bank,
      required this.account_holder,
      required this.account_number,
      required this.status,
      required this.created_at});

  factory BankTransferCard.fromModel({required BaseBankTransferResponse model}) {
    return BankTransferCard(
      amount: NumberUtil.format(model.amount.toString()),
      account_bank: model.accountBank.displayName,
      account_holder: model.accountHolder,
      account_number: model.accountNumber,
      status: model.transferStatus,
      created_at: DateTimeUtil.parseMd(dateTime: model.createdAt),
      id: model.id,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(color: MITIColor.gray750),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$amount원',
                      style: MITITextStyle.lgBold.copyWith(
                        color: MITIColor.gray100,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      created_at,
                      style: MITITextStyle.sm.copyWith(
                        color: MITIColor.gray400,
                      ),
                    )
                  ],
                ),
                TransferLabel(transferType: status),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: MITIColor.gray700,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  getInfo('예금주', account_holder),
                  SizedBox(height: 10.h),
                  getInfo('수령 은행', account_bank),
                  SizedBox(height: 10.h),
                  getInfo('수령 계좌', account_number),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row getInfo(String title, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.xxsmLight.copyWith(
            color: MITIColor.gray400,
          ),
        ),
        Text(
          content,
          style: MITITextStyle.xxsm.copyWith(
            color: MITIColor.gray300,
          ),
        ),
      ],
    );
  }
}
