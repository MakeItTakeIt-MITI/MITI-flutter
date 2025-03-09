import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/support/provider/support_provider.dart';
import 'package:miti/support/view/support_detail_screen.dart';
import 'package:miti/support/view/support_form_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../game/model/v2/support/base_user_question_response.dart';
import '../component/qna_label.dart';
import '../component/skeleton/support_skeleton.dart';
import '../model/support_model.dart';

class SupportScreen extends StatefulWidget {
  static String get routeName => 'support';

  const SupportScreen({
    super.key,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomButton(
        hasBorder: false,
        button: TextButton(
          onPressed: () => context.pushNamed(SupportFormScreen.routeName),
          style: TextButton.styleFrom(
            backgroundColor: MITIColor.gray750,
            side: const BorderSide(
              color: MITIColor.gray600,
            ),
          ),
          child: Text(
            '새로운 문의 작성하기',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
        ),
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '1:1 문의하기',
            ),
          ];
        }),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              sliver: SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                sliver: SliverMainAxisGroup(slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Text(
                        '나의 문의 내역',
                        style: MITITextStyle.mdBold
                            .copyWith(color: MITIColor.gray100),
                      ),
                    ),
                  ),
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final userId = ref.watch(authProvider)!.id!;
                      return DisposeSliverPaginationListView(
                        provider: supportPageProvider(
                            PaginationStateParam(path: userId)),
                        itemBuilder:
                            (BuildContext context, int index, Base pModel) {
                          final model = pModel as BaseUserQuestionResponse;

                          return _SupportCard.fromModel(
                            model: model,
                          );
                        },
                        skeleton: const SupportCardListSkeleton(),
                        controller: _scrollController,
                        emptyWidget: getEmptyWidget(),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '문의 내역이 없습니다.',
          style: MITITextStyle.xxl140.copyWith(color: Colors.white),
        ),
        SizedBox(height: 20.h),
        Text(
          '문의할 내용이 있으시다면\n아래 버튼을 통해 공유해 주세요!',
          style: MITITextStyle.sm150.copyWith(
            color: MITIColor.gray300,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}

class _SupportCard extends StatelessWidget {
  final int id;
  final String title;
  final int num_of_answers;
  final String created_at;
  // final String modified_at;

  const _SupportCard({
    super.key,
    required this.id,
    required this.title,
    required this.num_of_answers,
    required this.created_at,
    // required this.modified_at,
  });

  factory _SupportCard.fromModel({required BaseUserQuestionResponse model}) {
    DateFormat dateFormat = DateFormat('yyyy년 MM월 dd일', 'ko');
    final datetime = dateFormat.format(model.createdAt);
    // final modified_at =
    //     model.modifiedAt != null ? dateFormat.format(model.modifiedAt!) : null;
    return _SupportCard(
      id: model.id,
      title: model.title,
      num_of_answers: model.numOfAnswers,
      created_at: datetime,
      // modified_at: modified_at,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Map<String, String> pathParameters = {'questionId': id.toString()};
        final Map<String, String> queryParameters = {};
        context.pushNamed(
          SupportDetailScreen.routeName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: MITIColor.gray700,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: MITITextStyle.sm.copyWith(color: MITIColor.gray200),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              created_at,
              style: MITITextStyle.xxsmLight.copyWith(
                color: MITIColor.gray300,
              ),
            ),
            SizedBox(height: 16.h),
            QnaLabel(
              num_of_answers: num_of_answers,
            ),
          ],
        ),
      ),
    );
  }
}
