import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/game/view/game_payment_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../game/provider/game_provider.dart';

class PayErrorScreen extends ConsumerWidget {
  final int gameId;
  final bool canParticipation;

  static String get routeName => 'payError';

  const PayErrorScreen(
      {super.key, required this.canParticipation, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = canParticipation
        ? '결제가 정상적으로 완료되지 않았습니다.\n다시 결제를 진행해주세요.'
        : '더이상 참여할 수 없는 경기입니다.\n다른 경기에 참여해주세요.';
    return Scaffold(
      bottomNavigationBar: BottomButton(
        hasBorder: false,
        button: TextButton(
          onPressed: () {
            if (canParticipation) {
              Map<String, String> pathParameters = {
                'gameId': gameId.toString()
              };
              context.pushNamed(GamePaymentScreen.routeName,
                  pathParameters: pathParameters);
            } else {
              ref.refresh(gameDetailProvider(gameId: gameId));
              Map<String, String> pathParameters = {
                'gameId': gameId.toString()
              };
              context.goNamed(GameDetailScreen.routeName,
                  pathParameters: pathParameters);
            }
          },
          child: Text(canParticipation ? '결제로 돌아가기' : '돌아가기'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '결제 승인에 실패했습니다.',
            style: MITITextStyle.xxl140.copyWith(
              color: MITIColor.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),
          Text(
            content,
            style: MITITextStyle.pageSubTextStyle.copyWith(
              color: MITIColor.gray300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
