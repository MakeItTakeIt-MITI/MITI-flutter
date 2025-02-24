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
import '../../game/model/v2/report/base_report_reason_response.dart';
import '../../game/model/v2/report/base_report_type_response.dart';
import '../../util/util.dart';

class ReportListScreen extends StatelessWidget {
  final int gameId;
  final int? participationId;
  final ReportCategoryType reportType;

  static String get routeName => 'reportList';

  const ReportListScreen({
    super.key,
    required this.gameId,
    required this.reportType,
    this.participationId,
  });

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
          final result = ref.watch(reportProvider(reportType: reportType));
          if (result is LoadingModel) {
            return const CircularProgressIndicator();
          } else if (result is ErrorModel) {
            return const Text('error');
          }
          final List<BaseReportReasonResponse> modelList =
              (result as ResponseListModel<BaseReportTypeResponse>)
                      .data!
                      .firstOrNull
                      ?.reportReason ??
                  List.empty();
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

                            Map<String, String> queryParameters =
                                participationId != null
                                    ? {
                                        'participationId':
                                            participationId.toString()
                                      }
                                    : {};

                            context.pushNamed(
                              ReportFormScreen.routeName,
                              pathParameters: pathParameters,
                              queryParameters: queryParameters,
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
  final String title;
  final VoidCallback onTap;

  const ReportCard(
      {super.key, required this.id, required this.title, required this.onTap});

  factory ReportCard.fromModel(
      {required BaseReportReasonResponse model, required VoidCallback onTap}) {
    return ReportCard(
      id: model.id,
      title: model.title,
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
              title,
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
