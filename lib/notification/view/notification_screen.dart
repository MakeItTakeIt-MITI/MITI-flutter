import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/notification/param/notification_param.dart';
import 'package:miti/notification/provider/notification_pagination_provider.dart';
import 'package:miti/notification/repository/notification_repository.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/model_id.dart';
import '../model/notice_model.dart';

class NotificationScreen extends StatefulWidget {
  static String get routeName => 'notification';

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController scrollController;
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              const DefaultAppBar(
                title: '알림',
                isSliver: true,
                hasBorder: false,
                backgroundColor: MITIColor.gray800,
              )
            ];
          },
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 21.w, vertical: 12.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TabBar(
                        title: '활동 알림',
                        isSelected: true,
                        onTap: () {
                        },
                      ),
                      SizedBox(
                        width: 12.w,
                      ),
                      _TabBar(
                        title: '공지 사항',
                        isSelected: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                    // physics: NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: [
                      CustomScrollView(slivers: [
                        DisposeSliverPaginationListView(
                          provider: noticePProvider(
                            PaginationStateParam(),
                          ),
                          itemBuilder:
                              (BuildContext context, int index, Base pModel) {
                            final model = (pModel as NoticeModel);
                            return NotificationCard.fromModel(model: model);
                          },
                          separateSize: 0,
                          skeleton: Container(),
                          controller: scrollController,
                          emptyWidget: Container(),
                        ),
                      ]),
                      CustomScrollView(slivers: [
                        DisposeSliverPaginationListView(
                          provider: noticePProvider(
                            PaginationStateParam(),
                          ),
                          itemBuilder:
                              (BuildContext context, int index, Base pModel) {
                            final model = (pModel as NoticeModel);
                            return Container();
                          },
                          separateSize: 0,
                          skeleton: Container(),
                          controller: scrollController,
                          emptyWidget: Container(),
                        ),
                      ]),
                    ]),
              ),
            ],
          )),
    );
  }
}

class _TabBar extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabBar({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Badge(
            alignment: Alignment.topRight,
            backgroundColor: MITIColor.primary,
            child: SizedBox(
              height: 6.h,
              width: 60.w,
            ),
          ),
          Text(
            title,
            style: MITITextStyle.smBold.copyWith(
              color: isSelected ? MITIColor.gray100 : MITIColor.gray500,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.r),
              color: isSelected ? MITIColor.gray100 : MITIColor.gray800,
            ),
            height: 2.r,
            width: 60.w,
          )
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final int id;
  final String title;
  final String date;

  const NotificationCard({
    super.key,
    required this.id,
    required this.title,
    required this.date,
  });

  factory NotificationCard.fromModel({required NoticeModel model}) {
    final date = DateTime.parse(model.createdAt);

    return NotificationCard(
      id: model.id,
      title: model.title,
      date: DateFormat('yyyy년 MM월 dd일', "ko").format(date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MITIColor.gray700),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 21.w,
        vertical: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: MITITextStyle.smSemiBold.copyWith(
              color: MITIColor.gray200,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            date,
            style: MITITextStyle.smSemiBold.copyWith(
              color: MITIColor.gray200,
            ),
          ),
        ],
      ),
    );
  }
}
