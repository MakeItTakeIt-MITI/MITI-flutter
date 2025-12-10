import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../chat/provider/chat_approve_provider.dart';

enum GameCompleteType {
  create,
  payment;
}

class GameCompleteScreen extends StatelessWidget {
  final int gameId;
  final GameCompleteType type;
  late final List<String> title;

  late final List<String> desc;

  static String get routeName => 'gameComplete';

  GameCompleteScreen({
    super.key,
    required this.gameId,
    required this.type,
  }) {
    title = type == GameCompleteType.create
        ? ["경기 정보를 다시 확인해 주세요!", "경기 무료 전환은 경기 시작 30분 전까지", "매치 완료 후, 리뷰 남기기"]
        : ['경기 정보를 다시 확인해 주세요!', '경기 운영 정보 확인하기', '매치 완료 후, 리뷰 남기기'];

    desc = type == GameCompleteType.create
        ? [
            "경기 정보가 올바르게 작성되었는지 확인해 주세요.\n경기 취소는 경기 생성 후 2시간 이내로만 가능하니 잘못 생성 하셨다면 빠르게 취소해 주세요!",
            "경기 참가비를 무료로 전환할 수 있어요. 다만, 경기 시작 30분 전까지만 전환 가능하니 주의해 주세요.",
            "경기가 종료된 후, 리뷰를 통해 함께 플레이 한 선수들에게 리뷰를 남겨주세요. 리뷰는 올바른 농구 문화를 이루는 데 도움이 됩니다!"
          ]
        : [
            '경기 상세 정보에서 참여할 경기의 시간과 장소를 확인해주세요.\n경기에 늦지 않게 경기장까지의 경로를 미리 찾아주세요!',
            '경기 운영 정보를 통해 경기장의 주차, 샤워실, 유니폼, 참여 인원 등 경기에 관한 정보들을 미리 확인해주세요!',
            '경기가 종료된 후, 리뷰를 통해 함께 플레이한 선수들에게\n리뷰를 남겨주세요.\n리뷰는 올바른 농구 문화를 형성하는데 도움이 됩니다!'
          ];
  }

  Widget getProgress(int idx) {
    return Container(
      height: 24.r,
      width: 24.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: V2MITIColor.primary2,
      ),
      child: Center(
        child: Text(
          idx.toString(),
          style: V2MITITextStyle.tinyBoldNormal
              .copyWith(color: V2MITIColor.gray11),
        ),
      ),
    );
  }

  Widget info(int idx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            getProgress(idx + 1),
            SizedBox(width: 8.w),
            Text(
              title[idx],
              style: V2MITITextStyle.tinyBoldNormal.copyWith(
                color: V2MITIColor.white,
              ),
            )
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          desc[idx],
          style: V2MITITextStyle.tinyMediumNormal.copyWith(
            color: V2MITIColor.gray3,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 213.h,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Lottie.asset(
                          'assets/lottie/success.json',
                          width: 200,
                          height: 213.h,
                          fit: BoxFit.fill,
                          repeat: true,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 74.5.h),
                            Text(
                              type == GameCompleteType.create
                                  ? '경기 생성 완료!'
                                  : '경기 참가 완료!',
                              style: V2MITITextStyle.title3.copyWith(
                                color: V2MITIColor.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '경기 정보를 확인해보세요',
                              style:
                                  V2MITITextStyle.smallRegularNormal.copyWith(
                                color: V2MITIColor.gray2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 52.h),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  type == GameCompleteType.create
                      ? "새로운 경기를 생성하셨습니다."
                      : '경기 참여가 확정되었습니다!',
                  style: V2MITITextStyle.smallBoldNormal.copyWith(
                    color: V2MITIColor.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "경기 시작전, 아래의 내용을 다시 확인해주세요!",
                  style: V2MITITextStyle.tinyRegularNormal.copyWith(
                    color: V2MITIColor.white,
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: V2MITIColor.gray11,
                  ),
                  child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, idx) {
                        return info(idx);
                      },
                      separatorBuilder: (_, idx) {
                        return SizedBox(height: 24.h);
                      },
                      itemCount: 3),
                ),
                const Spacer(),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return SizedBox(
                      height: 48.h,
                      child: TextButton(
                        onPressed: () async {
                          await ref
                              .read(
                                  chatApproveProvider(gameId: gameId).notifier)
                              .get(gameId: gameId);
                          Map<String, String> pathParameters = {
                            'gameId': gameId.toString()
                          };

                          context.goNamed(
                            GameDetailScreen.routeName,
                            pathParameters: pathParameters,
                          );
                        },
                        style: TextButton.styleFrom(
                            fixedSize: Size(double.infinity, 44.h)),
                        child: const Text('경기 정보 확인하기'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
