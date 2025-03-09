import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/notification/model/unread_push_model.dart';
import 'package:miti/notification/provider/notification_provider.dart';
import 'package:miti/notification/view/notification_screen.dart';
import 'package:miti/support/view/guide_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/component/skeleton/profile_skeleton.dart';
import 'package:miti/user/view/profile_update_screen.dart';
import 'package:miti/user/view/user_payment_screen.dart';
import 'package:miti/user/view/profile_screen.dart';

import '../../account/view/settlement_management_screen.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/entity_enum.dart';
import '../../etc/view/tc_policy_screen.dart';
import '../../game/model/game_model.dart';
import '../../notification/view/notification_setting_screen.dart';
import '../../review/model/v2/base_guest_rating_response.dart';
import '../../review/view/receive_review_list_screen.dart';
import '../../review/view/written_review_list_screen.dart';
import '../../support/view/faq_screen.dart';
import '../../support/view/support_screen.dart';
import '../../theme/color_theme.dart';
import '../component/skeleton/receive_review_skeleton.dart';
import '../error/user_error.dart';
import '../model/user_model.dart';
import '../model/v2/user_info_response.dart';
import '../provider/user_provider.dart';
import '../../util/util.dart';

class ProfileBody extends ConsumerStatefulWidget {
  static String get routeName => 'profileMenu';

  const ProfileBody({
    super.key,
  });

  @override
  ConsumerState<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<ProfileBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((s) {
      ref
          .read(scrollControllerProvider.notifier)
          .update((s) => _scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          DefaultAppBar(
            title: '마이페이지',
            isSliver: true,
            hasBorder: false,
            actions: [
              //todo 뱃지 위치 적용 필요

              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result = ref.watch(unreadPushProvider);
                  bool unconfirmed = false;
                  if (result is ResponseModel<UnreadPushModel>) {
                    unconfirmed = result.data!.pushCnt > 0;
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 13.w),
                    child: GestureDetector(
                      onTap: () {
                        context.pushNamed(NotificationScreen.routeName);
                      },
                      child: Badge(
                        backgroundColor:
                            unconfirmed ? MITIColor.primary : MITIColor.gray800,
                        // alignment: const Alignment(1,-1),
                        smallSize: 4.r,
                        largeSize: 4.r,
                        child: SvgPicture.asset(
                          AssetUtil.getAssetPath(
                            type: AssetType.icon,
                            name: 'alram',
                          ),
                          height: 24.r,
                          width: 24.r,
                          colorFilter: const ColorFilter.mode(
                            MITIColor.gray100,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ];
      },
      body: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileComponent(),
                _ReviewComponent(),
                _MenuComponent(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// class Menu{
//   final String title;
//   final
// }

class _MenuComponent extends ConsumerWidget {
  const _MenuComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return Container();
    } else if (result is ErrorModel) {
      WidgetsBinding.instance.addPostFrameCallback((s) =>
          UserError.fromModel(model: result)
              .responseError(context, UserApiType.get, ref));
      return const Text("error");
    }
    final model = (result as ResponseModel<UserInfoResponse>).data!;

    Map<String, List<_MenuItem>> gameMenu = getMyPageMenu(context, model);

    final menu = gameMenu.keys.toList();
    return Padding(
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 32.h),
      child: Column(
        children: [
          ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, idx) {
                final items = gameMenu[menu[idx]]!;
                return _Menu(title: menu[idx], items: items);
              },
              separatorBuilder: (_, idx) => SizedBox(height: 20.h),
              itemCount: menu.length),
        ],
      ),
    );
  }

  Map<String, List<_MenuItem>> getMyPageMenu(
      BuildContext context, UserInfoResponse model) {
    final Map<String, List<_MenuItem>> gameMenu = {
      '경기 관련 정보': [
        _MenuItem(
          onTap: () => context.pushNamed(WrittenReviewListScreen.routeName),
          title: '내가 작성한 리뷰',
        ),
        _MenuItem(
          onTap: () => context.pushNamed(ReceiveReviewListScreen.routeName),
          title: '나를 평가한 리뷰',
        ),
        _MenuItem(
          onTap: () => context.pushNamed(UserPaymentScreen.routeName),
          title: '결제 내역 확인',
          option: getOption('게스트'),
        ),
        _MenuItem(
          onTap: () => context.pushNamed(SettlementManagementScreen.routeName),
          title: '정산 관리',
          option: getOption('호스트'),
        ),
      ],
      '계정 설정': [
        _MenuItem(
          onTap: () {
            context.pushNamed(ProfileUpdateScreen.routeName);
          },
          title: '프로필 수정',
        ),
        _MenuItem(
          onTap: () => context.pushNamed(UserProfileScreen.routeName),
          title: '내 정보 수정',
        ),
        _MenuItem(
          onTap: () => context.pushNamed(NotificationSettingScreen.routeName),
          title: '알림 설정',
        ),
      ],
      '고객센터': [
        _MenuItem(
          onTap: () => context.pushNamed(FAQScreen.routeName),
          title: '자주 묻는 질문',
        ),
        _MenuItem(
          onTap: () => context.pushNamed(SupportScreen.routeName),
          title: '문의하기',
        ),
        _MenuItem(
          onTap: () => context.pushNamed(GuideScreen.routeName),
          title: '서비스 이용 안내',
        ),
      ],
      '기타': [
        _MenuItem(
          onTap: () => context.pushNamed(TcPolicyScreen.routeName),
          title: '약관 및 정책',
        ),
        // _MenuItem(
        //   onTap: () => context.pop(),
        //   title: '앱 정보',
        // ),
      ],
    };
    return gameMenu;
  }

  Container getOption(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.r),
        color: MITIColor.gray600,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Text(
        title,
        style: MITITextStyle.xxxsmBold.copyWith(
          color: MITIColor.primary,
        ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _Menu({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Text(
            title,
            style: MITITextStyle.sm.copyWith(
              color: MITIColor.gray500,
            ),
          ),
        ),
        ListView.separated(
            padding: EdgeInsets.only(top: 12.h),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, idx) {
              return items[idx];
            },
            separatorBuilder: (_, idx) => SizedBox(height: 12.h),
            itemCount: items.length),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final Widget? option;
  final VoidCallback onTap;

  const _MenuItem(
      {super.key, required this.onTap, required this.title, this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: MITIColor.gray800,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: MITITextStyle.mdLight.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                SizedBox(width: 12.w),
                if (option != null) option!,
              ],
            ),
            SvgPicture.asset(
              AssetUtil.getAssetPath(
                type: AssetType.icon,
                name: 'chevron_right',
              ),
              colorFilter: const ColorFilter.mode(
                MITIColor.gray400,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewComponent extends ConsumerWidget {
  const _ReviewComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return const ReceiveReviewSkeleton();
    } else if (result is ErrorModel) {
      WidgetsBinding.instance.addPostFrameCallback((s) =>
          UserError.fromModel(model: result)
              .responseError(context, UserApiType.get, ref));
      return const Text("error");
    }
    final model = (result as ResponseModel<UserInfoResponse>).data!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '내가 받은 리뷰 평점',
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              OverlayTooltipDemo(),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _ReviewCard(
                  type: ReviewType.guest_review,
                  rating: model.guestRating,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                  child: _ReviewCard(
                type: ReviewType.host_review,
                rating: model.hostRating,
              )),
            ],
          )
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewType type;
  final BaseRatingResponse rating;

  const _ReviewCard({super.key, required this.type, required this.rating});

  List<Widget> getStar(double rating) {
    List<Widget> result = [];
    for (int i = 0; i < 5; i++) {
      bool flag = false;
      if (i == rating.toInt()) {
        final decimalPoint = rating - rating.toInt();
        flag = decimalPoint != 0;
      }
      final String star = flag
          ? 'star_s_half'
          : rating >= i + 1
              ? 'star_s_full'
              : 'star_s_empty';
      result.add(SvgPicture.asset(
        AssetUtil.getAssetPath(type: AssetType.icon, name: star),
        height: 16.r,
        width: 16.r,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final title = type == ReviewType.guest_review ? '게스트' : '호스트';
    final add = rating.numOfReviews != 0 ? '+' : '';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: MITIColor.gray750,
      ),
      height: 82.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$title 리뷰 (${rating.numOfReviews}$add)',
            style: MITITextStyle.xxsm.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 12.h),
          if (rating.numOfReviews != 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...getStar(rating.averageRating ?? 0),
                SizedBox(width: 8.w),
                Text(
                  "${rating.averageRating ?? 0}",
                  style: MITITextStyle.lg.copyWith(
                    color: MITIColor.gray100,
                  ),
                )
              ],
            )
          else
            Text(
              '아직 작성된 리뷰가 없어요',
              style:
                  MITITextStyle.xxsmLight150.copyWith(color: MITIColor.gray400),
            )
        ],
      ),
    );
  }
}

class OverlayTooltipDemo extends StatefulWidget {
  @override
  _OverlayTooltipDemoState createState() => _OverlayTooltipDemoState();
}

class _OverlayTooltipDemoState extends State<OverlayTooltipDemo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        richMessage: TextSpan(children: [
          TextSpan(
            text: '게스트 리뷰\n',
            style: MITITextStyle.xxsmBold.copyWith(color: MITIColor.gray700),
          ),
          // SizedBox(height: 4.h),
          TextSpan(
            text: '게스트로 참여한 경기에서 다른 게스트 및 호스트 모두에게 받은 평점의 평균이에요.\n',
            style: MITITextStyle.xxxsm140.copyWith(color: MITIColor.gray700),
          ),
          // SizedBox(height: 12.h),
          TextSpan(
            text: '호스트 리뷰\n',
            style: MITITextStyle.xxsmBold.copyWith(color: MITIColor.gray700),
          ),
          // SizedBox(height: 5),
          TextSpan(
            text: '호스트로 주최하여 참여한 경기에서\n게스트들에게 받은 평점의 평균이에요.',
            style: MITITextStyle.xxxsm140.copyWith(color: MITIColor.gray700),
          ),
        ]),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.only(left: 90.w, right: 50.w),
        padding: EdgeInsets.all(8.0),
        preferBelow: true,
        verticalOffset: -90,
        showDuration: const Duration(seconds: 2),
        child: Icon(
          Icons.help_outline,
          size: 24.r,
          color: MITIColor.gray100,
        ),
      ),
    );
  }
}

class _ProfileComponent extends ConsumerWidget {
  const _ProfileComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return const ProfileSkeleton();
    } else if (result is ErrorModel) {
      WidgetsBinding.instance.addPostFrameCallback((s) =>
          UserError.fromModel(model: result)
              .responseError(context, UserApiType.get, ref));
      return const Text("error");
    }
    final model = (result as ResponseModel<UserInfoResponse>).data!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 21.w,
        vertical: 20.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.nickname,
                  style: MITITextStyle.xl.copyWith(color: MITIColor.gray100),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () {
                    context.pushNamed(ProfileUpdateScreen.routeName);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200.r),
                      border: Border.all(
                        color: MITIColor.gray300,
                      ),
                    ),
                    child: Text(
                      '프로필 수정',
                      style: MITITextStyle.xxsm.copyWith(
                        color: MITIColor.gray300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(model.profileImageUrl != null)
            CircleAvatar(
              radius: 30.r,
              backgroundImage: NetworkImage(model.profileImageUrl, scale: 60.r),
            )else
            SvgPicture.asset(
              AssetUtil.getAssetPath(
                  type: AssetType.icon, name: 'user_thum2'),
              width: 60.r,
              height: 60.r,
            ),
        ],
      ),
    );
  }
}
