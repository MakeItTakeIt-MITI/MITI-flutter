import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/system_button_bottom.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/component/coupon_card.dart';
import 'package:miti/user/model/coupon_response.dart';
import 'package:miti/user/param/user_profile_param.dart';
import 'package:miti/user/provider/user_pagination_provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/dispose_sliver_cursor_pagination_list_view.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../util/util.dart';
import '../component/skeleton/payment_card_skeleton.dart';

class CouponListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'couponList';

  const CouponListScreen({super.key});

  @override
  ConsumerState<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends ConsumerState<CouponListScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44.h),
        child: _buildAppBar(),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCouponList(isActive: true),
                _buildCouponList(isActive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return DefaultAppBar(
      title: "쿠폰함",
      hasBorder: false,
      actions: [
        GestureDetector(
          onTap: _onTapMenu,
          child: Padding(
            padding: EdgeInsetsGeometry.only(right: 10.w),
            child: SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.icon, name: 'menu_solid'),
              width: 24.r,
              height: 24.r,
            ),
          ),
        ),
      ],
    );
  }

  void _onTapMenu() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) {
        return SystemButtonBottom(
          buttons: [
            TextButton(
                onPressed: () => context.pop(),
                style:
                TextButton.styleFrom(
                    backgroundColor: V2MITIColor.gray11),
                child: Text(
                  "추천인 입력하기",
                  style: V2MITITextStyle.regularBoldNormal
                      .copyWith(color: V2MITIColor.primary5),
                )),
            TextButton(
                onPressed: () => context.pop(),
                style:
                    TextButton.styleFrom(
                        backgroundColor: V2MITIColor.gray11),
                child: Text(
                  "쿠폰코드 입력하기",
                  style: V2MITITextStyle.regularBoldNormal
                      .copyWith(color: V2MITIColor.white),
                )),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      width: double.infinity,
      child: TabBar(
        controller: _tabController,
        indicatorColor: V2MITIColor.primary5,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: V2MITIColor.gray6,
        labelColor: V2MITIColor.primary5,
        unselectedLabelColor: V2MITIColor.gray6,
        labelStyle: V2MITITextStyle.tinyMediumNormal,
        unselectedLabelStyle: V2MITITextStyle.tinyMediumNormal,
        tabs: const [
          Tab(text: '사용 가능한 쿠폰'),
          Tab(text: '만료 쿠폰'),
        ],
      ),
    );
  }

  Widget _buildCouponList({required bool isActive}) {
    final userId = ref.watch(authProvider)!.id!;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        DisposeSliverCursorPaginationListView(
          provider: userCouponProvider(PaginationStateParam(
              param: UserCouponParam(
                  status: isActive
                      ? [CouponStatusType.active]
                      : [CouponStatusType.expired]),
              path: userId)),
          itemBuilder: (BuildContext context, int index, Base pModel) {
            pModel as CouponResponse;

            return CouponCard.fromModel(model: pModel);
          },
          skeleton: const PaymentCardListSkeleton(),
          param: UserCouponParam(
              status: isActive
                  ? [CouponStatusType.active]
                  : [CouponStatusType.expired]),
          controller: _scrollController,
          separateSize: 0,
          emptyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '발금 받은 쿠폰이 없습니다!',
                style: V2MITITextStyle.regularMediumNormal.copyWith(
                  color: V2MITIColor.gray7,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
