import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/model/game_player_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/entity_enum.dart';

class GameParticipationScreen extends StatelessWidget {
  static String get routeName => 'participation';
  final int gameId;

  const GameParticipationScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: '참가한 게스트',
        hasBorder: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final result = ref.watch(gamePlayerProfileProvider(gameId: gameId));
            if (result is LoadingModel) {
              return const CircularProgressIndicator();
            } else if (result is ErrorModel) {
              return Text('error');
            }
            final model =
                (result as ResponseListModel<GameParticipationPlayerModel>)
                    .data!;
            log('model length = ${model.length}');

            return ListView.separated(
                shrinkWrap: true,
                itemBuilder: (_, idx) {
                  return _ParticipationPlayerCard.fromModel(model: model[idx]);
                },
                separatorBuilder: (_, idx) {
                  return SizedBox(height: 12.h);
                },
                itemCount: model.length);
          },
        ),
      ),
    );
  }
}

class _ParticipationPlayerCard extends StatelessWidget {
  final int id;
  final ParticipationStatusType participation_status;
  final PlayerModel user;

  const _ParticipationPlayerCard({
    super.key,
    required this.id,
    required this.participation_status,
    required this.user,
  });

  factory _ParticipationPlayerCard.fromModel(
      {required GameParticipationPlayerModel model}) {
    return _ParticipationPlayerCard(
      id: model.id,
      participation_status: model.participation_status,
      user: model.user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: MITIColor.gray700),
        color: MITIColor.gray750,
      ),
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                user.nickname,
                style: MITITextStyle.smBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              SizedBox(height: 8.h),
            ],
          )
        ],
      ),
    );
  }
}
