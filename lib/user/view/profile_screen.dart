import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/view/court_search_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../account/view/bank_transfer_screen.dart';
import '../../account/view/settlement_screen.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../../game/view/game_create_screen.dart';
import '../../support/view/faq_screen.dart';
import '../../support/view/support_screen.dart';
import '../../theme/color_theme.dart';
import '../model/user_model.dart';
import '../provider/user_provider.dart';
import 'user_delete_screen.dart';
import 'user_host_list_screen.dart';
import 'user_profile_form_screen.dart';
import 'user_review_screen.dart';
import '../../util/util.dart';

class ProfileBody extends StatefulWidget {
  static String get routeName => 'profile';

  const ProfileBody({
    super.key,
  });

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          DefaultAppBar(
            title: '마이페이지',
            isSliver: true,
            hasBorder: false,
            actions: [
              //todo 뱃지 위치 적용 필요
              Align(
                child: Padding(
                  padding: EdgeInsets.only(right: 13.w),
                  child: GestureDetector(
                    onTap: () {},
                    child: Badge(
                      backgroundColor: MITIColor.primary,
                      // alignment: const Alignment(1,-1),
                      offset: Offset(10, 0),
                      padding: EdgeInsets.all(2.4),
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
                ),
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

class _MenuComponent extends StatelessWidget {
  const _MenuComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 32.h),
      child: Column(
        children: [
          // ListView.separated(
          //     shrinkWrap: true,
          //     physics: const NeverScrollableScrollPhysics(),
          //     itemBuilder: (_, idx) {},
          //     separatorBuilder: (_, idx) => SizedBox(height: 20.h),
          //     itemCount: 4),
          _Menu(
            title: '경기 관련 정보',
            items: [
              _MenuItem(
                onTap: () {},
                title: '내가 작성한 리뷰',
                option: getOption('게스트'),
              ),
            ],
          ),
        ],
      ),
    );
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
    );
  }
}

class _ReviewComponent extends ConsumerWidget {
  const _ReviewComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      return Text("error");
    }
    final model = (result as ResponseModel<UserModel>).data!.rating;
    model.guest_rating;

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
              _ReviewCard(type: ReviewType.guest, rating: model.guest_rating),
              _ReviewCard(type: ReviewType.host, rating: model.host_rating),
            ],
          )
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewType type;
  final Rating rating;

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
          ? 'Star_half_v2'
          : rating >= i + 1
              ? 'fill_star2'
              : 'unfill_star2';
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
    final title = type == ReviewType.guest ? '게스트' : '호스트';
    final add = rating.num_of_reviews != 0 ? '+' : '';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: MITIColor.gray750,
      ),
      child: Column(
        children: [
          Text(
            '$title 리뷰 (${rating.num_of_reviews}$add)',
            style: MITITextStyle.xxsm.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              ...getStar(rating.average_rating ?? 0),
              SizedBox(width: 8.w),
              Text(
                "${rating.average_rating ?? 0}",
                style: MITITextStyle.lg.copyWith(
                  color: MITIColor.gray100,
                ),
              )
            ],
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
  late final GlobalKey _globalKey;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _globalKey = GlobalKey();
  }

  // Create the overlay entry (pop-up content)
  OverlayEntry _createOverlayEntry() {
    final renderBox =
        _globalKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - 100,
        right: position.dx - 250,
        width: 250,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '게스트 리뷰',
                    style: MITITextStyle.xxsmBold
                        .copyWith(color: MITIColor.gray700),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '게스트로 참여한 경기에서 다른 게스트 및 호스트 모두에게 받은 평점의 평균이에요.',
                    style: MITITextStyle.xxxsm140
                        .copyWith(color: MITIColor.gray700),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '호스트 리뷰',
                    style: MITITextStyle.xxsmBold
                        .copyWith(color: MITIColor.gray700),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '호스트로 주최하여 참여한 경기에서\n게스트들에게 받은 평점의 평균이에요.',
                    style: MITITextStyle.xxxsm140
                        .copyWith(color: MITIColor.gray700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to show the overlay
  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  // Method to hide the overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "FSDAFSADFDSAFSADFASDFSADF",
      child: GestureDetector(
        key: _globalKey,
        onTap: () {
          // if (_overlayEntry == null) {
          //   _showOverlay();
          // } else {
          //   _removeOverlay();
          // }
        },
        child: Icon(
          Icons.help_outline,
          size: 24.r,
          color: MITIColor.gray100,
        ),
      ),
    );
    ;
  }
}

class _ProfileComponent extends ConsumerWidget {
  const _ProfileComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      return Text("error");
    }
    final model = (result as ResponseModel<UserModel>).data!;

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
                  onTap: () {},
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
          SvgPicture.asset(
            AssetUtil.getAssetPath(type: AssetType.icon, name: 'user_thum'),
            width: 60.r,
            height: 60.r,
          )
        ],
      ),
    );
  }
}
