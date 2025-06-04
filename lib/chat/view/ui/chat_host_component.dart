import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/model/entity_enum.dart';
import '../../../game/model/v2/participation/participation_guest_player_response.dart';
import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import '../../../user/model/v2/base_player_profile_response.dart';
import '../../../user/model/v2/user_guest_player_response.dart';

class ParticipationPlayerCard extends StatelessWidget {
  final int id;
  final UserGuestPlayerResponse user;
  final BasePlayerProfileResponse profile;

  const ParticipationPlayerCard({
    super.key,
    required this.id,
    required this.user,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> details = [
      if (profile.gender?.displayName != null) profile.gender!.displayName,
      if (profile.height != null) "${profile.height} cm",
      if (profile.weight != null) "${profile.weight} kg",
      if (profile.position?.displayName != null) profile.position!.displayName,
    ];

    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 16.r,
            backgroundImage: NetworkImage(user.profileImageUrl, scale: 32.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      user.nickname,
                      style: MITITextStyle.xxsmSemiBold.copyWith(
                        color: MITIColor.gray100,
                      ),
                    ),
                    SizedBox(width: 5.h),
                    getOption("호스트")
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  details.join(" • "),
                  style: MITITextStyle.sm.copyWith(color: MITIColor.gray400),
                )
              ],
            ),
          )
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


