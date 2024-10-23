import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/html_component.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/game/model/game_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/report/provider/report_provider.dart';
import 'package:miti/report/provider/widget/report_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/component/custom_dialog.dart';
import '../../common/component/default_layout.dart';
import '../../common/provider/router_provider.dart';
import '../../game/view/review_form_screen.dart';
import '../../theme/text_theme.dart';
import '../error/report_error.dart';
import '../model/report_model.dart';

class ReportFormScreen extends StatefulWidget {
  final int gameId;
  final int reportId;
  final HostReportCategoryType type;

  static String get routeName => 'reportForm';

  const ReportFormScreen({
    super.key,
    required this.gameId,
    required this.reportId,
    required this.type,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MITIColor.gray750,
        bottomNavigationBar: BottomButton(
          button: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final form = ref.watch(reportFormProvider(category: widget.type));
              final valid = form.content.isNotEmpty;
              return TextButton(
                onPressed: valid
                    ? () async {
                        final result = await ref.read(createReportProvider(
                                gameId: widget.gameId, category: widget.type)
                            .future);

                        if (result is ErrorModel) {
                          ReportError.fromModel(model: result).responseError(
                              context, ReportApiType.report, ref);
                        } else {
                          final model = (ref.read(
                                      gameDetailProvider(gameId: widget.gameId))
                                  as ResponseModel<GameDetailModel>)
                              .data!;
                          Map<String, String> pathParameters = {
                            'gameId': model.id.toString()
                          };
                          context.goNamed(GameDetailScreen.routeName,
                              pathParameters: pathParameters);
                          Future.delayed(const Duration(milliseconds: 200), () {
                            showModalBottomSheet(
                                isDismissible: false,
                                context: rootNavKey.currentState!.context!,
                                builder: (_) {
                                  return BottomDialog(
                                    title: '경기 신고 완료',
                                    content:
                                        '‘${model.title}’ 경기의 신고가 접수되었습니다.',
                                    btn: Consumer(
                                      builder: (BuildContext context,
                                          WidgetRef ref, Widget? child) {
                                        return TextButton(
                                          onPressed: () async {
                                            context.pop();
                                          },
                                          style: TextButton.styleFrom(
                                            fixedSize:
                                                Size(double.infinity, 48.h),
                                          ),
                                          child: const Text(
                                            "확인",
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                });
                          });
                        }
                      }
                    : () {},
                style: TextButton.styleFrom(
                  backgroundColor: valid ? MITIColor.error : MITIColor.gray500,
                ),
                child: Text(
                  '신고하기',
                  style: MITITextStyle.btnTextBStyle.copyWith(
                    color: valid ? MITIColor.gray100 : MITIColor.gray50,
                  ),
                ),
              );
            },
          ),
        ),
        appBar: const DefaultAppBar(
          title: '신고하기',
          backgroundColor: MITIColor.gray750,
        ),
        body: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final result =
                ref.watch(reportDetailProvider(reportId: widget.reportId));
            if (result is LoadingModel) {
              return CircularProgressIndicator();
            } else if (result is ErrorModel) {
              return Text('error');
            }
            final model = (result as ResponseModel<ReportDetailModel>).data!;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  SliverToBoxAdapter(
                    child: Text(
                      model.subcategory.displayName,
                      style: MITITextStyle.lgBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: HtmlComponent(content: model.content),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                  SliverToBoxAdapter(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints.tight(Size(double.infinity, 200.h)),
                      child: MultiLineTextFormField(
                        onChanged: (val) {
                          ref
                              .read(reportFormProvider(category: widget.type)
                                  .notifier)
                              .update(content: val);
                        },
                        hint: '신고 내용을 작성해주세요.',
                        context: context,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
