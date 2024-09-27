import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/custom_time_picker.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/support/provider/support_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:collection/collection.dart';
import '../model/support_model.dart';
import 'package:url_launcher/url_launcher.dart';

class GuideScreen extends StatefulWidget {
  static String get routeName => 'guide';

  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  UserGuideType category = UserGuideType.game;
  int currentIdx = 0;
  late final CarouselSliderController carouselController;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(headerSliverBuilder: (_, __) {
        return [
          const DefaultAppBar(
            title: '서비스 이용 안내',
            isSliver: true,
            hasBorder: false,
          )
        ];
      }, body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final result = ref.watch(guideProvider);
          if (result is LoadingModel) {
            return CircularProgressIndicator();
          } else if (result is ErrorModel) {
            return Text("error");
          }
          final model = (result as ResponseListModel<GuideModel>).data!;
          final List<String> images =
              model.firstWhereOrNull((m) => m.category == category)?.image ??
                  [];
          final String title =
              model.firstWhereOrNull((m) => m.category == category)?.title ??
                  '';
          final String content =
              model.firstWhereOrNull((m) => m.category == category)?.content ??
                  '';
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 38.h,
                  margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
                  child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 21.w),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, idx) {
                        return _GuideChip(
                          title: model[idx].category.displayName,
                          onTap: () {
                            setState(() {
                              category = model[idx].category;
                              carouselController.jumpToPage(0);
                            });
                          },
                          selected: category == model[idx].category,
                        );
                      },
                      separatorBuilder: (_, idx) {
                        return SizedBox(width: 8.w);
                      },
                      itemCount: model.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    CarouselSlider(
                      carouselController: carouselController,
                      options: CarouselOptions(
                          enlargeCenterPage: true,
                          viewportFraction: 1,
                          height: 220.h,
                          enlargeStrategy: CenterPageEnlargeStrategy.height,
                          animateToClosest: false,
                          onPageChanged: (idx, _) {
                            setState(() {
                              currentIdx = idx;
                            });
                          }),
                      items: images.map((image) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Image.network(
                                image,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return Container(
                            width: 4.r,
                            height: 4.r,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: entry.key == currentIdx
                                  ? MITIColor.primary
                                  : MITIColor.gray400,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: MITITextStyle.mdBold150.copyWith(
                          color: MITIColor.gray100,
                        ),
                      ),
                      SizedBox(
                        height: 28.h,
                      ),
                      Html(
                        data: content,
                        style: {
                          'body': Style(margin: Margins.all(0)),
                          'p': Style(
                            fontSize: FontSize(16.sp),
                            color: MITIColor.gray100,
                          ),
                          'ul': Style(
                            listStyleType: ListStyleType.none,
                            margin: Margins.zero,
                            padding: HtmlPaddings.all(5.r),
                            fontSize: FontSize(12.sp),
                            lineHeight: LineHeight.em(1.5),
                          ),
                          'b': Style(
                            color: MITIColor.gray100,
                          ),
                          'li': Style(
                            margin: Margins.all(4.r),
                            fontSize: FontSize(12.sp),
                            listStyleType: ListStyleType.none,
                            lineHeight: LineHeight.em(1.5),
                            color: MITIColor.gray100,
                            listStylePosition: ListStylePosition.inside,
                          ),
                          'h1': Style(
                            color: MITIColor.gray100,
                          ),
                          'h2': Style(
                            color: MITIColor.gray100,
                          ),
                          'h3': Style(
                            color: MITIColor.gray100,
                          ),
                          'h4': Style(
                            color: MITIColor.gray100,
                          ),
                          'h5': Style(
                            color: MITIColor.gray100,
                          ),
                          'h6': Style(
                            color: MITIColor.gray100,
                          ),
                        },
                        onLinkTap: (url, _, __) async {
                          if (url != null) {
                            final Uri _url = Uri.parse(url);
                            await launchUrl(_url);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      )),
    );
  }
}

class _GuideChip extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool selected;

  const _GuideChip(
      {super.key,
      required this.title,
      required this.onTap,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: selected ? MITIColor.primary : MITIColor.gray700,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        alignment: Alignment.center,
        child: Text(
          title,
          style: MITITextStyle.smSemiBold.copyWith(
            color: selected ? MITIColor.gray800 : MITIColor.gray400,
          ),
        ),
      ),
    );
  }
}
