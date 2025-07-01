import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/chat/provider/chat_member_provider.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../common/model/entity_enum.dart';
import '../../../theme/color_theme.dart';
import '../../../user/model/v2/user_player_profile_response.dart';
import '../../component/chat_member_skeleton.dart';
import '../../model/game_chat_member_response.dart';

class ChatMemberComponent extends ConsumerWidget {
  final int gameId;

  const ChatMemberComponent({
    super.key,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(chatMemberProvider(gameId: gameId));
    if (result is LoadingModel) {
      return const ChatMemberSkeleton();
    } else if (result is ErrorModel) {
      return Text("Error");
    }
    final model = (result as ResponseModel<GameChatMemberResponse>).data!;
    final host = model.host;
    final participants = model.participants;

    return Column(
      children: [
        _ChatMemberComponent.fromHost(host: host),
        SizedBox(height: 10.h),
        _ChatMemberComponent.fromGuest(members: participants),
      ],
    );
  }
}

class _ChatMemberComponent extends StatelessWidget {
  final bool isHost;
  final List<UserPlayerProfileResponse> members;

  const _ChatMemberComponent({
    super.key,
    required this.isHost,
    required this.members,
  });

  factory _ChatMemberComponent.fromHost(
      {required UserPlayerProfileResponse host}) {
    return _ChatMemberComponent(
      isHost: true,
      members: [host],
    );
  }

  factory _ChatMemberComponent.fromGuest(
      {required List<UserPlayerProfileResponse> members}) {
    return _ChatMemberComponent(
      isHost: false,
      members: members,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Text(
            isHost ? "호스트" : "게스트",
            style: MITITextStyle.lgBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
        ),
        if (members.isEmpty)
          Container(
            alignment: Alignment.center,
            height: 150.h,
            child: Text(
              "아직 참가자가 없습니다.",
              style: MITITextStyle.smBold.copyWith(color: MITIColor.white),
            ),
          )
        else
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, idx) => _MemberCard.fromResponse(
                    isHost: isHost,
                    model: members[idx],
                  ),
              separatorBuilder: (_, idx) => SizedBox(height: 5.h),
              itemCount: members.length),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final bool isHost;

  final int? id;
  final String nickname; // 닉네임
  final String profileImageUrl; // 프로필 이미지 URL
  final GenderType? gender; // 성별
  final int? height; // 신장
  final int? weight; // 체중
  final PlayerPositionType? position; // 포지션
  final PlayerRoleType? role; // 역할

  const _MemberCard(
      {super.key,
      required this.id,
      required this.nickname,
      required this.profileImageUrl,
      this.gender,
      this.height,
      this.weight,
      this.position,
      this.role,
      required this.isHost});

  factory _MemberCard.fromResponse(
      {required UserPlayerProfileResponse model, bool isHost = false}) {
    return _MemberCard(
      id: model.id,
      nickname: model.nickname,
      profileImageUrl: model.profileImageUrl,
      gender: model.playerProfile.gender,
      height: model.playerProfile.height,
      weight: model.playerProfile.weight,
      position: model.playerProfile.position,
      role: model.playerProfile.role,
      isHost: isHost,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> details = [
      if (gender?.displayName != null) gender!.displayName,
      if (height != null) "$height cm",
      if (weight != null) "$weight kg",
      if (position?.displayName != null) position!.displayName,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.5.h),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 16.r,
            backgroundImage: NetworkImage(profileImageUrl, scale: 32.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      nickname,
                      style: MITITextStyle.xxsmSemiBold.copyWith(
                        color: MITIColor.gray100,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    if (isHost)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.r),
                          color: MITIColor.gray600,
                        ),
                        child: Text(
                          "호스트",
                          style: MITITextStyle.xxxsmBold
                              .copyWith(color: MITIColor.primary),
                        ),
                      )
                  ],
                ),
                SizedBox(height: 8.h),
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
}
