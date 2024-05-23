import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/support/view/support_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_delete_screen.dart';
import 'package:miti/user/view/user_profile_form_screen.dart';
import 'package:miti/user/view/user_review_screen.dart';

import '../../account/view/bank_transfer_form_screen.dart';
import '../../account/view/bank_transfer_screen.dart';
import '../../account/view/settlement_screen.dart';
import '../../common/provider/scroll_provider.dart';
import '../../support/view/faq_screen.dart';
import '../../util/util.dart';
import '../model/user_model.dart';

class InfoBody extends ConsumerWidget {
  static String get routeName => 'info';

  const InfoBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(pageScrollControllerProvider);
    return NestedScrollView(
      controller: controller[2],
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          const DefaultAppBar(
            title: '내 정보',
            isSliver: true,
          )
        ];
      },
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const _UserInfoCard(),
                Container(
                  height: 5.h,
                  color: const Color(0xFFF6F6F6),
                ),
                const _UserButtonComponent(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _UserInfoCard extends ConsumerWidget {
  const _UserInfoCard({super.key});

  List<Widget> getStar(double rating) {
    List<Widget> result = [];
    for (int i = 0; i < 5; i++) {
      bool flag = false;
      if (i == rating.toInt()) {
        final decimalPoint = rating - rating.toInt();
        flag = decimalPoint != 0;
      }
      final String star = flag
          ? 'half_star'
          : rating >= i + 1
              ? 'fill_star'
              : 'unfill_star';
      result.add(SvgPicture.asset(
        'assets/images/icon/$star.svg',
        height: 14.r,
        width: 14.r,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      return Text('에러');
    }
    final model = (result as ResponseModel<UserModel>).data!;
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SvgPicture.asset(
                'assets/images/icon/user_thum.svg',
                width: 50.r,
                height: 50.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      model.nickname,
                      style: MITITextStyle.nicknameTextStyle
                          .copyWith(color: const Color(0xFF444444)),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      model.email,
                      style: MITITextStyle.emailTextStyle
                          .copyWith(color: const Color(0xFF969696)),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        ...getStar(model.rating.average_rating),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            model.rating.average_rating.toStringAsFixed(1),
                            style: MITITextStyle.emailTextStyle,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE7E7E7))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '💰 나의 지갑',
                      style: MITITextStyle.plainTextSStyle
                          .copyWith(color: const Color(0xFF333333)),
                    ),
                    Text(
                      '₩ ${NumberUtil.format(model.account.balance.toString())}',
                      style: MITITextStyle.nicknameCardStyle
                          .copyWith(color: const Color(0xFF333333)),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 36.h,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          4.r,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Map<String, String> pathParameters = {
                        'accountId': model.account.id.toString()
                      };
                      context.pushNamed(BankTransferFormScreen.routeName,
                          pathParameters: pathParameters);
                    },
                    child: Text(
                      '송금하기',
                      style: MITITextStyle.btnRStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded getInfoBox({required String title, required String content}) {
    final textStyle = TextStyle(
      fontSize: 10.sp,
      color: const Color(0xFF333333),
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      height: 16 / 10,
      letterSpacing: -0.25.sp,
    );
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE7E7E7))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: textStyle,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 5.h),
            Text(
              content,
              style: MITITextStyle.nicknameCardStyle
                  .copyWith(color: const Color(0xFF333333)),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserButtonComponent extends StatelessWidget {
  const _UserButtonComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['로그아웃', '', ''],
      [
        '작성 리뷰',
        UserWrittenReviewScreen.routeName,
        UserReviewType.written.value
      ],
      ['내 리뷰', UserWrittenReviewScreen.routeName, UserReviewType.receive.value],
      ['프로필 수정', UserProfileFormScreen.routeName, ''],
      ['정산 내역', SettlementListScreen.routeName, ''],
      ['송금 내역', BankTransferScreen.routeName, ''],
      ['FAQ', FAQScreen.routeName, ''],
      ['고객센터', SupportScreen.routeName, ''],
      ['회원탈퇴', UserDeleteScreen.routeName, ''],
    ];

    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 정보',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (_, idx) {
                return Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return InkWell(
                      onTap: () {
                        if (buttons[idx][1].isEmpty) {
                          ref.read(tokenProvider.notifier).logout();
                        } else {
                          final extra = buttons[idx][2];
                          context.pushNamed(buttons[idx][1], extra: extra);
                        }
                      },
                      child: Text(
                        buttons[idx][0],
                        style: MITITextStyle.menuChoiceStyle.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_, idx) {
                return SizedBox(height: 15.h);
              },
              itemCount: buttons.length,
            ),
          ),
        ],
      ),
    );
  }
}
