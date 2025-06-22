import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/post/component/post_category.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../user/model/v2/base_user_response.dart';
import '../model/base_post_response.dart';

class PostCard extends StatelessWidget {
  final PostCategoryType category;
  final bool isAnonymous;
  final String title;
  final String content;
  final int numOfComments;
  final DateTime createdAt;
  final List<String> images;
  final List<int> likedUsers;
  final BaseUserResponse writer;
  final VoidCallback onTap;

  const PostCard(
      {super.key,
      required this.category,
      required this.isAnonymous,
      required this.title,
      required this.content,
      required this.numOfComments,
      required this.createdAt,
      required this.images,
      required this.likedUsers,
      required this.writer,
      required this.onTap});

  factory PostCard.fromModel(
      {required BasePostResponse model, required VoidCallback onTap}) {
    return PostCard(
        category: model.category,
        isAnonymous: model.isAnonymous,
        title: model.title,
        content: model.content,
        numOfComments: model.numOfComments,
        createdAt: model.createdAt,
        images: model.images,
        likedUsers: model.likedUsers,
        writer: model.writer,
        onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: MITIColor.gray750.withOpacity(.5), width: .5))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PostCategory(
                  category: category,
                ),
                Text(
                  "${DateTime.now().difference(createdAt).inMinutes}분전",
                  style: MITITextStyle.xxxsmLight
                      .copyWith(color: MITIColor.gray600),
                )
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            MITITextStyle.sm150.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        content,
                        style: MITITextStyle.xxxsmLight
                            .copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            writer.nickname,
                            style: MITITextStyle.xxxsm.copyWith(color: MITIColor.gray600),
                          ),
                          SizedBox(width: 10.w),
                          _SubInfo(
                            title: "댓글",
                            cnt: numOfComments,
                          ),
                          SizedBox(width: 10.w),
                          _SubInfo(
                            title: "좋아요",
                            cnt: likedUsers.length,
                          ),
                        ],
                      )

                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                if (images.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.network(
                          images.first,
                          width: 50.r,
                          height: 50.r,
                          fit: BoxFit.fill,
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                            bottom: 2.r,
                            right: 2.r,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 16.r, // 최소 너비
                                minHeight: 16.r, // 최소 높이
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(2.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF343434).withOpacity(.75),
                              ),
                              child: Text(
                                images.length.toString(),
                                style: MITITextStyle.xxxsmLight.copyWith(
                                  color: MITIColor.gray300,
                                ),
                              ),
                            ))
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubInfo extends StatelessWidget {
  final String title;
  final int cnt;

  const _SubInfo({super.key, required this.title, required this.cnt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: MITITextStyle.xxxsm.copyWith(color: MITIColor.gray600),
        ),
        SizedBox(width: 2.w),
        Text(
          cnt.toString(),
          style: MITITextStyle.xxxsm.copyWith(color: MITIColor.gray600),
        )
      ],
    );
  }
}
