import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/support/model/support_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/util/util.dart';
import 'package:expandable/expandable.dart';
import '../../common/component/default_appbar.dart';
import '../../theme/text_theme.dart';

class FAQScreen extends StatefulWidget {
  static String get routeName => 'faq';

  const FAQScreen({
    super.key,
  });

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
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
    List<String> categories = [
      '전체',
      '경기',
      '정산',
      '리뷰',
      '신고',
      '기타',
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const DefaultAppBar(
          hasBorder: false,
          title: '자주 묻는 질문',
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h, bottom: 60.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '무엇을 도와드릴까요?',
                      style: MITITextStyle.xl.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomTextFormField(
                      height: 40,
                      hintText: '궁금한 내용을 검색해보세요.',
                      borderRadius: BorderRadius.circular(12.r),
                      textStyle:
                          MITITextStyle.sm.copyWith(color: MITIColor.gray100),
                      hintTextStyle:
                          MITITextStyle.sm.copyWith(color: MITIColor.gray600),
                      suffixIcon: SvgPicture.asset(
                        AssetUtil.getAssetPath(
                          type: AssetType.icon,
                          name: 'search',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 검색 결과가 없을 때
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "검색 결과가 없습니다.",
                      style: MITITextStyle.xxl140.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '다른 키워드로 다시 검색해 보세요.',
                      style: MITITextStyle.sm.copyWith(
                        color: MITIColor.gray300,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 16.sp,
                alignment: Alignment.centerLeft,
                child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, idx) {
                      return GestureDetector(
                        onTap: () {},
                        child: Text(
                          categories[idx],
                          style: MITITextStyle.mdBold.copyWith(
                            color:
                                false ? MITIColor.primary : MITIColor.gray500,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(
                          width: 20.w,
                        ),
                    itemCount: categories.length),
              ),

              // CustomScrollView(
              //   slivers: [
              //     SliverPadding(
              //       padding: EdgeInsets.all(12.r),
              //       sliver: DisposeSliverPaginationListView(
              //           provider: faqProvider(PaginationStateParam()),
              //           itemBuilder: (BuildContext context, int index, Base pModel) {
              //             final model = pModel as FAQModel;
              //
              //             return _FAQComponent.fromModel(
              //               model: model,
              //             );
              //           },
              //           skeleton: Container(),
              //           controller: _scrollController,
              //           emptyWidget: getEmptyWidget()),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '송금 내역이 없습니다.',
          style: MITITextStyle.pageMainTextStyle,
        ),
        SizedBox(height: 20.h),
        Text(
          '송금 요청을 통해 정산금을 받아보세요!',
          style: MITITextStyle.pageSubTextStyle,
        )
      ],
    );
  }
}

class _FAQComponent extends ConsumerWidget {
  final int id;
  final String title;
  final String content;
  final DateTime created_at;
  final DateTime modified_at;

  const _FAQComponent(
      {super.key,
      required this.title,
      required this.content,
      required this.created_at,
      required this.modified_at,
      required this.id});

  factory _FAQComponent.fromModel({required FAQModel model}) {
    return _FAQComponent(
      title: model.title,
      content: model.content,
      created_at: model.created_at,
      modified_at: model.modified_at,
      id: model.id,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: MITIColor.gray600,
      ))),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: ExpandableNotifier(
        // <-- Provides ExpandableController to its children
        child: ExpandablePanel(
          theme: ExpandableThemeData(
            useInkWell: false,
            iconColor: MITIColor.gray400,
            iconSize: 24.r,
            iconPadding: EdgeInsets.zero,
          ),
          header: Align(
            alignment: const Alignment(-1, 0),
            child: Column(
              children: [
                Text(
                  '어쩌구저쩌구인 경우에는 어떻게 하나요?어쩌구저쩌구인 경우에는 어떻게 하나요?어쩌구저쩌구인 경우에는 어떻게 하나요?',
                  style: MITITextStyle.md.copyWith(
                    color: MITIColor.gray50,
                  ),
                ),
              ],
            ),
          ),
          collapsed: Container(),
          expanded: ExpandableButton(
            theme: const ExpandableThemeData(useInkWell: false),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: MITIColor.gray750,
              ),
              margin: EdgeInsets.only(top: 20.h),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  Text(
                    title,
                    style: MITITextStyle.sm150.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    content,
                    style: MITITextStyle.sm150.copyWith(
                      color: MITIColor.gray300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
