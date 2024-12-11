import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/report/model/report_model.dart';
import 'package:miti/report/provider/report_provider.dart';
import 'package:miti/report/view/report_form_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/entity_enum.dart';
import '../../util/util.dart';

class ReportListScreen extends StatelessWidget {
  final int gameId;

  static String get routeName => 'reportList';

  const ReportListScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        backgroundColor: MITIColor.gray750,
        title: '신고하기',
      ),
      backgroundColor: MITIColor.gray750,
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final result = ref.watch(reportProvider);
          if (result is LoadingModel) {
            return const CircularProgressIndicator();
          } else if (result is ErrorModel) {
            return const Text('error');
          }
          final modelList = (result as ResponseListModel<ReportModel>).data!;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '경기 신고 사유를 선택해 주세요.',
                  style: MITITextStyle.mdBold.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                SizedBox(height: 20.h),
                ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, idx) => ReportCard.fromModel(
                          model: modelList[idx],
                          onTap: () {
                            Map<String, String> pathParameters = {
                              'gameId': gameId.toString(),
                              'reportId': modelList[idx].id.toString()
                            };

                            context.pushNamed(
                              ReportFormScreen.routeName,
                              pathParameters: pathParameters,
                              extra: modelList[idx].subcategory,
                            );
                          },
                        ),
                    separatorBuilder: (_, idx) => SizedBox(height: 12.h),
                    itemCount: modelList.length)
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final int id;
  final ReportType category;
  final HostReportCategoryType subcategory;
  final VoidCallback onTap;

  const ReportCard(
      {super.key,
      required this.id,
      required this.category,
      required this.subcategory,
      required this.onTap});

  factory ReportCard.fromModel(
      {required ReportModel model, required VoidCallback onTap}) {
    return ReportCard(
      id: model.id,
      category: model.category,
      subcategory: model.subcategory,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: MITIColor.gray700,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subcategory.displayName,
              style: MITITextStyle.sm150.copyWith(
                color: MITIColor.gray200,
              ),
            ),
            SvgPicture.asset(
              AssetUtil.getAssetPath(
                  type: AssetType.icon, name: 'chevron_right'),
              colorFilter: const ColorFilter.mode(
                MITIColor.primary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
