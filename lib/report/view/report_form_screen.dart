import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
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
import '../../game/model/v2/game/game_detail_response.dart';
import '../../game/model/v2/report/base_report_reason_response.dart';
import '../../game/view/review_form_screen.dart';
import '../../theme/text_theme.dart';
import '../error/report_error.dart';
import '../model/report_model.dart';

class ReportFormScreen extends ConsumerStatefulWidget {
  final int gameId;
  final int reportId;
  final int? participationId;

  static String get routeName => 'reportForm';

  const ReportFormScreen({
    super.key,
    required this.gameId,
    required this.reportId,
    this.participationId,
  });

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  late Throttle<int> _throttler;
  int throttleCnt = 0;
  GlobalKey key = GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) async {
      setState(() {
        isLoading = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
      await _report(ref, context);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _throttler.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MITIColor.gray750,
        bottomNavigationBar: BottomButton(
          button: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final form =
                  ref.watch(reportFormProvider(reportReason: widget.reportId));
              final valid = form.content.isNotEmpty;
              return TextButton(
                onPressed: valid && !isLoading
                    ? () async {
                        _throttler.setValue(throttleCnt + 1);
                      }
                    : () {},
                style: TextButton.styleFrom(
                  backgroundColor:
                      valid && !isLoading ? MITIColor.error : MITIColor.gray500,
                ),
                child: Text(
                  '신고하기',
                  style: MITITextStyle.btnTextBStyle.copyWith(
                    color: valid && !isLoading
                        ? MITIColor.gray100
                        : MITIColor.gray50,
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
              return const Center(child: CircularProgressIndicator());
            } else if (result is ErrorModel) {
              ReportError.fromModel(model: result)
                  .responseError(context, ReportApiType.get, ref);
              return const Text('error');
            }
            final model =
                (result as ResponseModel<BaseReportReasonResponse>).data!;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  SliverToBoxAdapter(
                    child: Text(
                      model.briefTitle,
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
                              .read(reportFormProvider(
                                      reportReason: widget.reportId)
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

  Future<void> _report(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(createReportProvider(
            gameId: widget.gameId,
            reportId: widget.reportId,
            participationId: widget.participationId)
        .future);
    if (context.mounted) {
      if (result is ErrorModel) {
        if (widget.participationId != null) {
          ReportError.fromModel(model: result)
              .responseError(context, ReportApiType.guestReport, ref);
        } else {
          ReportError.fromModel(model: result)
              .responseError(context, ReportApiType.hostReport, ref);
        }
      } else {
        final model = (ref.read(gameDetailProvider(gameId: widget.gameId))
                as ResponseModel<GameDetailResponse>)
            .data!;
        Map<String, String> pathParameters = {'gameId': model.id.toString()};
        context.goNamed(GameDetailScreen.routeName,
            pathParameters: pathParameters);
        Future.delayed(const Duration(milliseconds: 200), () {
          String reportType = widget.participationId != null ? '게스트' : '호스트';

          showModalBottomSheet(
              isDismissible: false,
              context: rootNavKey.currentState!.context!,
              builder: (_) {
                return BottomDialog(
                  title: '$reportType 신고 완료',
                  content: '경기 $reportType 신고가 완료되었습니다.',
                  btn: Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      return TextButton(
                        onPressed: () async {
                          context.pop();
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size(double.infinity, 48.h),
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
  }
}
