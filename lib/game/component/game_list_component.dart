import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../model/base_game_meta_response.dart';
import 'game_card.dart';

class GameCardByDate extends StatelessWidget {
  final List<BaseGameMetaResponse> model;

  const GameCardByDate({
    super.key,
    required this.model,
  });

  factory GameCardByDate.fromModel({required List<BaseGameMetaResponse> model}) {
    return GameCardByDate(
      model: model,
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(model.first.startDate);
    final formatDate = DateFormat('yyyy년 MM월 dd일 (EEE', "ko").format(date);
    return Column(
      spacing: 12.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$formatDate요일)",
          style: V2MITITextStyle.smallMediumNormal
              .copyWith(color: V2MITIColor.white),
        ),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, idx) {
            return GameCard.fromMetaModel(model: model[idx]);
          },
          separatorBuilder: (_, idx) {
            return SizedBox(height: 18.h);
          },
          itemCount: model.length,
        ),
      ],
    );
  }
}
