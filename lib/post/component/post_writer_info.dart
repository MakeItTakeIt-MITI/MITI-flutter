import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../user/model/v2/base_user_response.dart';
import '../../util/util.dart';

class PostWriterInfo extends StatelessWidget {
  final String nickname;
  final String profileImageUrl;
  final String createdAt;
  final bool isAnonymous;
  final VoidCallback? onTap;

  const PostWriterInfo(
      {super.key,
        required this.nickname,
        required this.profileImageUrl,
        required this.createdAt,
        required this.onTap,
        required this.isAnonymous});

  factory PostWriterInfo.fromModel({
    required BaseUserResponse model,
    required String createdAt,
    required bool isAnonymous,
    VoidCallback? onTap,
  }) {
    return PostWriterInfo(
      nickname: model.nickname,
      profileImageUrl: model.profileImageUrl,
      createdAt: createdAt,
      onTap: onTap,
      isAnonymous: isAnonymous,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: onTap == null ? 18.r : 16.r,
          backgroundColor: Colors.transparent,
          backgroundImage:
          NetworkImage(profileImageUrl, scale: onTap == null ? 36.r : 32.r),
        ),
        SizedBox(width: onTap == null ? 10.w : 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAnonymous ? '익명' : nickname, // todo 익명 사용자만의 특정 키워드
              style: MITITextStyle.smSemiBold.copyWith(color: Colors.white),
            ),
            SizedBox(height: 3.h),
            Text(
              DateTimeUtil.formatStringDateTime(createdAt),
              style: MITITextStyle.xxsm.copyWith(color: MITIColor.gray500),
            ),
          ],
        ),
        const Spacer(),
        if (onTap != null)
          IconButton(
            onPressed: onTap,
            icon: SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.icon, name: 'more'),
              width: 24.r,
              height: 24.r,
              colorFilter:
              const ColorFilter.mode(MITIColor.gray100, BlendMode.srcIn),
            ),
          )
      ],
    );
  }
}
