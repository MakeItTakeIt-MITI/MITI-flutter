import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

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
        : ['경기 장소까지의 경로를 미리 검색하기', '경기 운영 정보를 확인하기', '매치 완료 후, 리뷰 남기기'];

    desc = type == GameCompleteType.create
        ? [
            "경기 정보가 올바르게 작성되었는지 확인해 주세요.\n경기 취소는 경기 생성 후 2시간 이내로만 가능하니 잘못 생성 하셨다면 빠르게 취소해 주세요!",
            "경기 참가비를 무료로 전환할 수 있어요. 다만, 경기 시작 30분 전까지만 전환 가능하니 주의해 주세요.",
            "경기가 종료된 후, 리뷰를 통해 함께 플레이 한 선수들에게 리뷰를 남겨주세요. 리뷰는 올바른 농구 문화를 이루는 데 도움이 됩니다!"
          ]
        : [
            '경기 상세 정보에서 참여할 경기의 시간과 경기 장소를 확인하여, 약속 시간에 늦지 않도록 경기장까지의 경로를 미리 찾아주세요!',
            '경기 운영 정보를 통해 경기장의 주차, 샤워실, 유니폼, 참여인원 등을 미리 확인하여 경기 참여 시 차질이 없도록 준비해 주세요.',
            '경기가 종료된 후, 리뷰를 통해 함께 플레이 한 선수들에게 리뷰를 남겨주세요. 리뷰는 올바른 농구 문화를 이루는 데 도움이 됩니다!'
          ];
  }

  Widget getProgress(int idx) {
    return Container(
      height: 24.r,
      width: 24.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: MITIColor.primary,
      ),
      child: Center(
        child: Text(
          idx.toString(),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF262626),
            letterSpacing: -14.sp * 0.02,
          ),
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
            SizedBox(width: 16.w),
            Text(
              title[idx],
              style: MITITextStyle.md.copyWith(
                color: MITIColor.gray100,
              ),
            )
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          desc[idx],
          style: MITITextStyle.xxsmLight150.copyWith(
            color: MITIColor.gray300,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 170.h,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      child: Lottie.asset(
                        'assets/lottie/success.json',
                        width: 200,
                        height: 200,
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
                          SizedBox(height: 52.h),
                          Text(
                            type == GameCompleteType.create
                                ? '경기 생성 완료!'
                                : '경기 참가 완료!',
                            style: MITITextStyle.xxl140.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            '경기 정보를 확인해 보세요.',
                            style: MITITextStyle.sm150.copyWith(
                              color: MITIColor.gray300,
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
              Text(
                type == GameCompleteType.create
                    ? "새로운 경기를 생성하셨습니다."
                    : '경기 참여가 확정되었습니다.',
                style: MITITextStyle.md.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "경기에 참여하시기 전에 아래의 내용을 확인하세요.",
                style: MITITextStyle.sm150.copyWith(
                  color: MITIColor.gray300,
                ),
              ),
              SizedBox(height: 25.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 30.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: MITIColor.gray700,
                ),
                child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, idx) {
                      return info(idx);
                    },
                    separatorBuilder: (_, idx) {
                      return SizedBox(height: 32.h);
                    },
                    itemCount: 3),
              ),
              const Spacer(),
              SizedBox(
                height: 48.h,
                child: TextButton(
                  onPressed: () {
                    Map<String, String> pathParameters = {
                      'gameId': gameId.toString()
                    };

                    context.goNamed(
                      GameDetailScreen.routeName,
                      pathParameters: pathParameters,
                    );
                  },
                  style: TextButton.styleFrom(
                      fixedSize: Size(double.infinity, 48.h)),
                  child: const Text('경기 상세 정보 보기'),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
