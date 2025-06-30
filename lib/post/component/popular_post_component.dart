import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/post/provider/popular_post_provider.dart';
import 'package:miti/post/view/post_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/default_model.dart';
import '../../util/util.dart';
import '../error/post_error.dart';
import '../model/popular_post_list_response.dart';

class PopularPostComponent extends ConsumerStatefulWidget {
  const PopularPostComponent({super.key});

  @override
  ConsumerState<PopularPostComponent> createState() =>
      _PopularPostComponentState();
}

class _PopularPostComponentState extends ConsumerState<PopularPostComponent> {
  int currentIdx = 0;
  late CarouselSliderController carouselController;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(popularPostProvider);
    if (result is LoadingModel) {
      return Container(
        decoration: BoxDecoration(
            color: const Color(0xFFD3180C).withOpacity(.25),
            borderRadius: BorderRadius.circular(8.r)),
      );
    } else if (result is ErrorModel) {
      PostError.fromModel(model: result)
          .responseError(context, PostApiType.getPopularList, ref);

      return const Text("Error");
    }
    final model = (result as ResponseListModel<PopularPostListResponse>).data!;

    final popularList = model
        .map((e) => Text(
              e.title,
              style: MITITextStyle.xxsm.copyWith(color: MITIColor.gray100),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ))
        .toList();
    if (model.isEmpty) {
      return  Container();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: GestureDetector(
        onTap: () {
          Map<String, String> pathParameters = {
            'postId': model[currentIdx].id.toString()
          };
          context.pushNamed(PostDetailScreen.routeName,
              pathParameters: pathParameters);
        },
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFFD3180C).withOpacity(.25),
              borderRadius: BorderRadius.circular(8.r)),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              Image.asset(
                AssetUtil.getAssetPath(
                    type: AssetType.icon, name: "hot", extension: 'png'),
                height: 12.r,
                width: 12.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CarouselSlider(
                  items: popularList,
                  // disableGesture: false,
                  options: CarouselOptions(
                      // enlargeCenterPage: true,
                      viewportFraction: 1,
                      height: 30.h,
                      initialPage: 0,
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 2),
                      scrollDirection: Axis.vertical,
                      pageSnapping: false,
                      onPageChanged: (idx, _) {
                        setState(() {
                          currentIdx = idx;
                          log('currentIdx = $currentIdx');
                        });
                      }),
                ),
              )

              // _PopularPost(model: model),
            ],
          ),
        ),
      ),
    );
  }
}
