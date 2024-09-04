import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/court/view/court_detail_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../account/view/bank_transfer_screen.dart';
import '../../account/view/settlement_screen.dart';
import '../../common/component/default_appbar.dart';
import '../../game/view/game_create_screen.dart';
import '../../support/view/faq_screen.dart';
import '../../support/view/support_screen.dart';
import '../../user/provider/user_provider.dart';
import '../../user/view/user_delete_screen.dart';
import '../../user/view/user_host_list_screen.dart';
import '../../user/view/user_profile_form_screen.dart';
import '../../user/view/user_review_screen.dart';

class MenuBody extends StatefulWidget {
  static String get routeName => 'menu';

  const MenuBody({
    super.key,
  });

  @override
  State<MenuBody> createState() => _MenuBodyState();
}

class _MenuBodyState extends State<MenuBody> {

  @override
  Widget build(BuildContext context) {
    log('나의 매치 build!!');
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          const DefaultAppBar(
            title: '나의 매치',
            isSliver: true,
          ),
        ];
      },
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            sliver: const SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GameComponent(),
                  _CourtComponent(),
                  _UserInfoComponent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameComponent extends StatelessWidget {
  const _GameComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '경기',
            style: MITITextStyle.sectionTitleStyle,
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    const extra = UserGameType.participation;
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      GameHostScreen.routeName,
                      extra: extra,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '나의 참여 경기',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    const extra = UserGameType.host;
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      GameHostScreen.routeName,
                      extra: extra,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '나의 호스팅 경기',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    context.pushNamed(
                      GameCreateScreen.routeName,
                    );
                  },
                  child: Text(
                    '경기 생성하기',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CourtComponent extends StatelessWidget {
  const _CourtComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '경기장',
            style: MITITextStyle.sectionTitleStyle,
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };

                    context.pushNamed(
                      CourtSearchListScreen.routeName,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '경기장 조회',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _UserInfoComponent extends StatelessWidget {
  const _UserInfoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '내 정보',
            style: MITITextStyle.sectionTitleStyle,
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final model = ref.watch(authProvider);
                    return InkWell(
                      onTap: () {
                        if (model == null) {
                          context.pushNamed(LoginScreen.routeName);
                        } else {
                          ref.read(authProvider.notifier).logout();
                        }
                      },
                      child: Text(
                        model == null ? '로그인' : '로그아웃',
                        style: MITITextStyle.menuChoiceStyle,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      UserWrittenReviewScreen.routeName,
                      extra: UserReviewType.written.value,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '작성 리뷰',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      UserWrittenReviewScreen.routeName,
                      extra: UserReviewType.receive.value,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '내 리뷰',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      UserProfileFormScreen.routeName,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '프로필 수정',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      SettlementListScreen.routeName,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '정산 내역',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      BankTransferScreen.routeName,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '송금 내역',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      FAQScreen.routeName,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    'FAQ',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': '3'
                    };
                    context.pushNamed(
                      SupportScreen.routeName,
                      queryParameters: queryParameters,
                    );
                  },
                  child: Text(
                    '고객센터',
                    style: MITITextStyle.menuChoiceStyle,
                  ),
                ),
                SizedBox(height: 20.h),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final model = ref.watch(authProvider);
                    if (model == null) {
                      return Container();
                    }
                    return child!;
                  },
                  child: InkWell(
                    onTap: () {
                      final Map<String, String> queryParameters = {
                        'bottomIdx': '3'
                      };
                      context.pushNamed(
                        UserDeleteScreen.routeName,
                        queryParameters: queryParameters,
                      );
                    },
                    child: Text(
                      '회원탈퇴',
                      style: MITITextStyle.menuChoiceStyle,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
