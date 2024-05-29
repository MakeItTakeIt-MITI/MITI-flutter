import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/support/provider/support_provider.dart';
import 'package:miti/support/view/support_detail_screen.dart';
import 'package:miti/support/view/support_form_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../model/support_model.dart';

class SupportScreen extends StatefulWidget {
  static String get routeName => 'support';
  final int bottomIdx;

  const SupportScreen({super.key, required this.bottomIdx});

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
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '고객 센터',
            ),
          ];
        }),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: TextButton(
                  onPressed: () {
                    final Map<String, String> queryParameters = {
                      'bottomIdx': widget.bottomIdx.toString()
                    };
                    context.pushNamed(
                      SupportFormScreen.routeName,
                      queryParameters: queryParameters,
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    side: const BorderSide(
                      color: Color(0xFFE8E8E8),
                    ),
                  ),
                  child: Text(
                    '문의하기',
                    style: MITITextStyle.gameTitleMainStyle.copyWith(
                      color: Colors.black,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16.r),
              sliver: SliverMainAxisGroup(slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Text(
                      '나의 문의 내역',
                      style: MITITextStyle.sectionTitleStyle,
                    ),
                  ),
                ),
                DisposeSliverPaginationListView(
                  provider: supportPageProvider(PaginationStateParam()),
                  itemBuilder: (BuildContext context, int index, Base pModel) {
                    final model = pModel as SupportModel;

                    return _SupportCard.fromModel(
                      model: model, bottomIdx: widget.bottomIdx,
                    );
                  },
                  skeleton: Container(),
                  controller: _scrollController,
                  emptyWidget: getEmptyWidget(),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '문의 내역이 없습니다.',
          style: MITITextStyle.pageMainTextStyle,
        ),
        SizedBox(height: 20.h),
        Text(
          '경기를 운영하고 정산을 받으세요!',
          style: MITITextStyle.pageSubTextStyle,
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
  final DateTime modified_at;
  final int bottomIdx;

  const _SupportCard(
      {super.key,
      required this.id,
      required this.title,
      required this.num_of_answers,
      required this.created_at,
      required this.modified_at, required this.bottomIdx});

  factory _SupportCard.fromModel({required SupportModel model, required int bottomIdx}) {
    DateFormat dateFormat = DateFormat('yyyy.MM.dd aa hh시 mm분', 'ko');
    final datetime = dateFormat.format(model.created_at);
    return _SupportCard(
      id: model.id,
      title: model.title,
      num_of_answers: model.num_of_answers,
      created_at: datetime,
      modified_at: model.modified_at, bottomIdx: bottomIdx,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Map<String, String> pathParameters = {'questionId': id.toString()};
        final Map<String, String> queryParameters = {'bottomIdx': bottomIdx.toString()};
        context.pushNamed(
          SupportDetailScreen.routeName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
          ),
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: MITITextStyle.cardTitleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  created_at,
                  style: MITITextStyle.cardTimeStyle.copyWith(
                    color: const Color(0xff666666),
                  ),
                ),
                Text(
                  '답변: $num_of_answers개',
                  style: MITITextStyle.plainTextSStyle,
                ),
              ],
            )),
            SvgPicture.asset(
              'assets/images/icon/chevron_right.svg',
              height: 14.h,
              width: 7.w,
            ),
          ],
        ),
      ),
    );
  }
}
