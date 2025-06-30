import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/html_component.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/support/provider/support_provider.dart';
import 'package:miti/support/provider/widget/support_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/util/util.dart';
import 'package:expandable/expandable.dart';
import '../../common/component/default_appbar.dart';
import '../../game/model/v2/support/frequently_asked_question_response.dart';
import '../../theme/text_theme.dart';
import '../component/skeleton/faq_skeleton.dart';

class FAQScreen extends StatefulWidget {
  static String get routeName => 'faq';

  const FAQScreen({
    super.key,
  });

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<FaqCategoryType> faqCategories = FaqCategoryType.values;

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
                padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
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
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        return CustomTextFormField(
                          height: 40,
                          hintText: '궁금한 내용을 검색해보세요.',
                          borderRadius: BorderRadius.circular(12.r),
                          textStyle: MITITextStyle.sm
                              .copyWith(color: MITIColor.gray100),
                          hintTextStyle: MITITextStyle.sm
                              .copyWith(color: MITIColor.gray600),
                          suffixIcon: SvgPicture.asset(
                            AssetUtil.getAssetPath(
                              type: AssetType.icon,
                              name: 'search',
                            ),
                          ),
                          onChanged: (v) {
                            log("search = $v");
                            final param = ref
                                .read(fAQSearchFormProvider.notifier)
                                .update(search: v);
                            final result = ref
                                .read(fAQProvider.notifier)
                                .updateDebounce(param: param);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final selectCategory = ref.watch(faqCategoryProvider);
                  final result = ref.watch(fAQProvider);
                  if (result is LoadingModel) {
                    return const FaqSkeleton();
                  } else if (result is ErrorModel) {
                    return Text('error');
                  }
                  final modelList = (result
                          as ResponseListModel<FrequentlyAskedQuestionResponse>)
                      .data!
                      .where((f) {
                    if (selectCategory == FaqCategoryType.all) {
                      return true;
                    } else if (f.category == selectCategory) {
                      return true;
                    }
                    return false;
                  }).toList();

                  final form = ref.watch(fAQSearchFormProvider);

                  /// 검색 결과가 없을 때
                  if (modelList.isEmpty && form.search.isNotEmpty) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    );
                  } else if (form.search.isNotEmpty) {
                    return Expanded(
                      child: SingleChildScrollView(
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, idx) {
                            return _FAQComponent.fromModel(
                                model: modelList[idx]);
                          },
                          separatorBuilder: (_, idx) {
                            return Container();
                          },
                          shrinkWrap: true,
                          itemCount: modelList.length,
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
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
                                  onTap: () {
                                    ref
                                        .read(faqCategoryProvider.notifier)
                                        .update((f) => faqCategories[idx]);
                                  },
                                  child: Text(
                                    faqCategories[idx].displayName,
                                    style: MITITextStyle.mdBold.copyWith(
                                      color:
                                          selectCategory == faqCategories[idx]
                                              ? MITIColor.primary
                                              : MITIColor.gray500,
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) => SizedBox(
                                    width: 20.w,
                                  ),
                              itemCount: faqCategories.length),
                        ),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (_, idx) {
                                return _FAQComponent.fromModel(
                                    model: modelList[idx]);
                              },
                              separatorBuilder: (_, idx) {
                                return Container();
                              },
                              shrinkWrap: true,
                              itemCount: modelList.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQComponent extends ConsumerWidget {
  final int id;
  final FaqCategoryType category;
  final String title;
  final String content;
  final DateTime created_at;
  final DateTime? modified_at;

  const _FAQComponent(
      {super.key,
      required this.category,
      required this.title,
      required this.content,
      required this.created_at,
      required this.modified_at,
      required this.id});

  factory _FAQComponent.fromModel(
      {required FrequentlyAskedQuestionResponse model}) {
    return _FAQComponent(
      title: model.title,
      content: model.content,
      created_at: model.createdAt,
      modified_at: model.modifiedAt,
      id: model.id,
      category: model.category,
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
            headerAlignment: ExpandablePanelHeaderAlignment.center,
          ),
          header: Text(
            title,
            style: MITITextStyle.md.copyWith(
              color: MITIColor.gray50,
            ),
          ),
          collapsed: Container(),
          expanded: ExpandableButton(
            theme: const ExpandableThemeData(useInkWell: false),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: MITIColor.gray750,
              ),
              margin: EdgeInsets.only(top: 20.h),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: HtmlComponent(content: content),
            ),
          ),
        ),
      ),
    );
  }
}
