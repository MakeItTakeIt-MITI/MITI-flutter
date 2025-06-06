import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';

import '../../common/model/entity_enum.dart';
import '../../theme/color_theme.dart';
import '../../user/error/user_error.dart';
import '../../user/model/review_model.dart';
import '../../user/provider/user_provider.dart';
import '../../user/view/review_detail_screen.dart';
import '../component/skeleton/review_detail_skeleton.dart';
import '../model/v2/guest_review_response.dart';
import '../model/v2/host_review_response.dart';

class MyReviewDetailScreen extends StatelessWidget {
  final UserReviewType userReviewType;
  final int reviewId;
  final ReviewType reviewType;

  static String get routeName => 'myReviewDetail';

  const MyReviewDetailScreen(
      {super.key,
      required this.userReviewType,
      required this.reviewId,
      required this.reviewType});

  Widget getDivider() {
    return Divider(
      color: MITIColor.gray600,
      indent: 13.w,
      endIndent: 13.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            final title = userReviewType == UserReviewType.receive
                ? '평가받은 리뷰 상세 내용'
                : '내가 작성한 리뷰 상세 내용';
            return [
              DefaultAppBar(
                isSliver: true,
                title: title,
                hasBorder: false,
              )
            ];
          },
          body: CustomScrollView(
            slivers: [
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result = ref.watch(myReviewProvider(
                      userReviewType: userReviewType,
                      reviewType: reviewType,
                      reviewId: reviewId));
                  if (result is LoadingModel) {
                    return SliverToBoxAdapter(
                      child: ReviewDetailSkeleton(
                        reviewType: reviewType,
                      ),
                    );
                  } else if (result is ErrorModel) {
                    UserError.fromModel(model: result)
                        .responseError(context, UserApiType.getReviewDetail, ref);
                    return const SliverToBoxAdapter(
                      child: Text('error'),
                    );
                  }

                  String nickname = '';
                  String profileImageUrl = '';
                  final model =
                      (result as ResponseModel<BaseReviewResponse>).data!;
                  // if (UserReviewType.written == userReviewType) {
                  //   nickname = (model as MyWrittenReviewDetailModel).reviewee;
                  // } else {
                  //   nickname = (model as MyReceiveReviewDetailModel).reviewer;
                  // }

                  if (ReviewType.guest_review == reviewType) {
                    if (UserReviewType.written == userReviewType) {
                      nickname =
                          (model as GuestReviewResponse).reviewee.nickname;
                      profileImageUrl = (model).reviewee.profileImageUrl;
                    } else {
                      nickname =
                          (model as GuestReviewResponse).reviewer.nickname;
                      profileImageUrl = (model).reviewer.profileImageUrl;
                    }
                  } else {
                    if (UserReviewType.written == userReviewType) {
                      nickname =
                          (model as HostReviewResponse).reviewee.nickname;
                      profileImageUrl = (model).reviewee.profileImageUrl;
                    } else {
                      nickname =
                          (model as HostReviewResponse).reviewer.nickname;
                      profileImageUrl = (model).reviewer.profileImageUrl;
                    }
                  }

                  MyReceiveReviewDetailModel;
                  final title = userReviewType == UserReviewType.receive
                      ? '리뷰 작성자'
                      : reviewType == ReviewType.host_review
                          ? '호스트'
                          : '게스트';

                  return SliverToBoxAdapter(
                    child: Column(
                      children: [
                        UserInfoComponent(
                          nickname: nickname,
                          title: title,
                          profileImageUrl: profileImageUrl,
                        ),
                        getDivider(),
                        GameInfoComponent.fromModel(model: model.game),
                        getDivider(),
                        ReviewInfoComponent(
                          rating: model.rating,
                          tags: model.tags,
                          comment: model.comment,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }
}
