// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:miti/user/model/review_model.dart';
// import 'package:miti/user/view/review_detail_screen.dart';
//
// import '../../common/model/entity_enum.dart';
// import '../../game/component/game_state_label.dart';
// import '../../theme/text_theme.dart';
// import '../provider/user_provider.dart';
//
// class ReviewCard extends ConsumerWidget {
//   final int id;
//   final String reviewee;
//   final int rating;
//   final String? comment;
//   final ReviewType review_type;
//   final String? game_title;
//   final int bottomIdx;
//
//   const ReviewCard({
//     super.key,
//     required this.id,
//     required this.reviewee,
//     required this.rating,
//     required this.comment,
//     required this.review_type,
//     this.game_title,
//     required this.bottomIdx,
//   });
//
//   factory ReviewCard.fromWrittenModel(
//       {required WrittenReviewModel model, required int bottomIdx}) {
//     return ReviewCard(
//       id: model.id,
//       reviewee: model.reviewee,
//       rating: model.rating,
//       comment: model.comment,
//       review_type: model.review_type,
//       bottomIdx: bottomIdx,
//     );
//   }
//
//   factory ReviewCard.fromReceiveModel(
//       {required ReceiveReviewModel model, required int bottomIdx}) {
//     return ReviewCard(
//       id: model.id,
//       reviewee: model.reviewer,
//       rating: model.rating,
//       comment: model.comment,
//       review_type: model.review_type,
//       bottomIdx: bottomIdx,
//     );
//   }
//
//   List<Widget> getStar(int rating) {
//     List<Widget> result = [];
//     for (int i = 0; i < 5; i++) {
//       final String star = rating >= i + 1 ? 'fill_star' : 'unfill_star';
//       result.add(SvgPicture.asset(
//         'assets/images/icon/$star.svg',
//         height: 14.r,
//         width: 14.r,
//       ));
//     }
//     return result;
//   }
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return InkWell(
//       onTap: () {
//         Map<String, String> pathParameters = {'reviewId': id.toString()};
//         final UserReviewType extra = game_title == null
//             ? UserReviewType.written
//             : UserReviewType.receive;
//         final Map<String, String> queryParameters = {
//           'bottomIdx': bottomIdx.toString()
//         };
//         context.pushNamed(
//           ReviewDetailScreen.routeName,
//           pathParameters: pathParameters,
//           extra: extra,
//           queryParameters: queryParameters,
//         );
//       },
//       child: Container(
//         padding: EdgeInsets.all(12.r),
//         decoration: BoxDecoration(
//             border: Border.all(color: const Color(0xFFE8E8E8)),
//             borderRadius: BorderRadius.circular(8.r)),
//         child: Row(
//           children: [
//             SvgPicture.asset(
//               'assets/images/icon/user_thum.svg',
//               width: 40.r,
//               height: 40.r,
//             ),
//             SizedBox(width: 10.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ReviewLabel(reviewType: review_type),
//                   if (reviewer_nickname != null) SizedBox(height: 2.h),
//                   if (reviewer_nickname != null)
//                     Text(
//                       reviewee,
//                       style: MITITextStyle.nicknameCardStyle
//                           .copyWith(color: const Color(0xFF444444)),
//                     ),
//                   SizedBox(height: 2.h),
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         ...getStar(rating),
//                         SizedBox(width: 3.w),
//                         Text(
//                           '$rating',
//                           style: MITITextStyle.gameTimeCardMStyle.copyWith(
//                             color: const Color(0xFF222222),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     comment,
//                     style: MITITextStyle.reviewCardStyle
//                         .copyWith(color: const Color(0xFF666666)),
//                   ),
//                   if (game_title != null) SizedBox(height: 2.h),
//                   if (game_title != null)
//                     Text(
//                       game_title!,
//                       style: MITITextStyle.gameTitleCardLStyle
//                           .copyWith(color: const Color(0xFF333333)),
//                     ),
//                 ],
//               ),
//             ),
//             SvgPicture.asset(
//               'assets/images/icon/chevron_right.svg',
//               height: 14.h,
//               width: 7.w,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
