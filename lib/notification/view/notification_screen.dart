import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/common/component/sliver_delegate.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/notification/param/notification_param.dart';
import 'package:miti/notification/provider/notification_pagination_provider.dart';
import 'package:miti/notification/provider/widget/unconfirmed_provider.dart';
import 'package:miti/notification/repository/notification_repository.dart';
import 'package:miti/notification/skeleton/notice_skeleton.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/provider/router_provider.dart';
import '../../game/view/game_create_screen.dart';
import '../model/notice_model.dart';
import '../model/push_model.dart';
import '../model/unread_push_model.dart';
import '../provider/notification_provider.dart';
import '../skeleton/push_skeleton.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  static String get routeName => 'notification';

  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  bool isNotification = true;

  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void refreshPush(int userId) {
    final provider = pushPProvider(PaginationStateParam(path: userId));
    ref.read(provider.notifier).paginate(
          path: userId,
          forceRefetch: true,
          param: NotificationParam(),
          paginationParams: const PaginationParam(page: 1),
        );
  }

  void refreshNotice() {
    final provider = noticePProvider(PaginationStateParam());
    ref.read(provider.notifier).paginate(
          forceRefetch: true,
          param: NotificationParam(),
          paginationParams: const PaginationParam(page: 1),
        );
  }

  Widget getNotificationBody(WidgetRef ref) {
    final userId = ref.watch(authProvider)!.id!;
    if (isNotification) {
      return RefreshIndicator(
        onRefresh: () async {
          refreshPush(userId);
        },
        child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [
              DisposeSliverPaginationListView(
                provider: pushPProvider(
                  PaginationStateParam(path: userId),
                ),
                itemBuilder: (BuildContext context, int index, Base pModel) {
                  final model = (pModel as PushModel);
                  return PushCard.fromModel(model: model);
                },
                separateSize: 0,
                skeleton: const PushListSkeleton(),
                controller: scrollController,
                emptyWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '활동 알림이 아직 없습니다.',
                      style: MITITextStyle.xxl140.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '경기에 참여하시고 활동 알림을 받아보세요',
                      style:
                          MITITextStyle.sm.copyWith(color: MITIColor.gray300),
                    ),
                  ],
                ),
              ),
            ]),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        refreshNotice();
      },
      child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          slivers: [
            DisposeSliverPaginationListView(
              provider: noticePProvider(
                PaginationStateParam(),
              ),
              itemBuilder: (BuildContext context, int index, Base pModel) {
                final model = (pModel as NoticeModel);
                return NotificationCard.fromModel(model: model);
              },
              separateSize: 0,
              skeleton: const NoticeListSkeleton(),
              controller: scrollController,
              emptyWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '공지사항이 없습니다.',
                    style: MITITextStyle.xxl140.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    '빠르게 개선해 업데이트 되도록 노력할게요!',
                    style: MITITextStyle.sm.copyWith(color: MITIColor.gray300),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (_, __) {
          return [
            DefaultAppBar(
              title: '알림',
              isSliver: true,
              hasBorder: false,
              backgroundColor: MITIColor.gray800,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final result = ref.watch(unreadPushProvider);
                      bool unconfirmed = false;
                      if (result is ResponseModel<UnreadPushModel>) {
                        unconfirmed = result.data!.pushCnt > 0;
                      }
                      return GestureDetector(
                        onTap: unconfirmed
                            ? () {
                                final result =
                                    ref.read(allReadPushProvider.future);
                                if (result is ErrorModel) {
                                } else {
                                  final userId = ref.read(authProvider)?.id;
                                  ref
                                      .read(pushPProvider(
                                        PaginationStateParam(path: userId),
                                      ).notifier)
                                      .allRead(ref: ref);
                                }
                              }
                            : null,
                        child: Text(
                          unconfirmed ? '모두 읽기' : '모두 읽음',
                          style: MITITextStyle.xxsm.copyWith(
                              color: unconfirmed
                                  ? MITIColor.primary
                                  : MITIColor.gray300),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            SliverPersistentHeader(
                pinned: true,
                delegate: SliverAppBarDelegate(
                  height: 54.h,
                  child: Container(
                    color: MITIColor.gray800,
                    height: 54.h,
                    padding: EdgeInsets.symmetric(horizontal: 21.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Consumer(
                              builder: (BuildContext context, WidgetRef ref,
                                  Widget? child) {
                                final result = ref.watch(unreadPushProvider);
                                bool unconfirmed = false;
                                if (result is ResponseModel<UnreadPushModel>) {
                                  unconfirmed = result.data!.pushCnt > 0;
                                }
                                return _TabBar(
                                  title: '활동 알림',
                                  isSelected: isNotification,
                                  onTap: () {
                                    setState(() {
                                      isNotification = true;
                                    });
                                  },
                                  unconfirmed: unconfirmed,
                                );
                              },
                            ),
                            SizedBox(
                              width: 12.w,
                            ),
                            _TabBar(
                              title: '공지사항',
                              isSelected: !isNotification,
                              onTap: () {
                                setState(() {
                                  isNotification = false;
                                });
                              },
                              unconfirmed: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
          ];
        },
        body: getNotificationBody(ref),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final String title;
  final bool unconfirmed;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabBar({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.unconfirmed,
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
            smallSize: 4.r,
            largeSize: 4.r,
            backgroundColor:
                unconfirmed ? MITIColor.primary : MITIColor.gray800,
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

class PushCard extends ConsumerStatefulWidget {
  final int id;
  final PushNotificationTopicType topic;
  final String title;
  final String body;
  final PushDataModel data;
  final bool isRead;
  final String createdAt;

  const PushCard({
    super.key,
    required this.id,
    required this.topic,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory PushCard.fromModel({required PushModel model}) {
    return PushCard(
      id: model.id,
      topic: model.topic,
      title: model.title,
      body: model.body,
      data: model.data,
      isRead: model.isRead,
      createdAt: formatDateTime(model.createdAt),
    );
  }

  static String formatDateTime(String inputDateTime) {
    // 입력된 날짜를 DateTime 객체로 파싱
    DateTime parsedDate = DateTime.parse(inputDateTime);

    // 현재 시간 가져오기
    DateTime now = DateTime.now();

    // 두 시간 차이를 계산
    Duration difference = now.difference(parsedDate);

    // 1시간 이내인 경우
    if (difference.inHours < 1) {
      return "${difference.inMinutes}분 전";
    }
    // 24시간 이내인 경우
    else if (difference.inHours < 24) {
      return "${difference.inHours}시간 전";
    }
    // 24시간 이상인 경우
    else {
      // 일 단위로 계산
      return "${difference.inDays}일 전";
    }
  }

  @override
  ConsumerState<PushCard> createState() => _PushCardState();
}

class _PushCardState extends ConsumerState<PushCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.data.gameId != null) {
          final userId = ref.read(authProvider)!.id!;
          Map<String, String> pathParameters = {
            'gameId': widget.data.gameId.toString()
          };
          ref
              .read(pushProvider(pushId: widget.id).notifier)
              .get(pushId: widget.id);
          ref
              .read(pushPProvider(PaginationStateParam(path: userId)).notifier)
              .read(pushId: widget.id, ref: ref);

          context.pushNamed(
            GameDetailScreen.routeName,
            pathParameters: pathParameters,
          );
        } else {
          Map<String, String> pathParameters = {'id': widget.id.toString()};
          context.pushNamed(
            NoticeDetailScreen.routeName,
            pathParameters: pathParameters,
            extra: NoticeScreenType.push,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: widget.isRead ? MITIColor.gray800 : MITIColor.gray700,
          border: const Border(
            bottom: BorderSide(color: MITIColor.gray700),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.topic.displayName,
                  style: MITITextStyle.xxsmLight.copyWith(
                    color: MITIColor.gray300,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.createdAt,
                      style: MITITextStyle.xxsmLight.copyWith(
                        color: MITIColor.gray300,
                      ),
                    ),
                    Visibility(
                      visible: !widget.isRead,
                      child: Row(
                        children: [
                          SizedBox(width: 4.w),
                          Badge(
                            smallSize: 4.r,
                            largeSize: 4.r,
                            backgroundColor: MITIColor.primary,
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              widget.title,
              style: MITITextStyle.smSemiBold.copyWith(
                color: MITIColor.gray200,
              ),
            )
          ],
        ),
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
    return GestureDetector(
      onTap: () {
        Map<String, String> pathParameters = {'id': id.toString()};
        context.pushNamed(
          NoticeDetailScreen.routeName,
          pathParameters: pathParameters,
          extra: NoticeScreenType.notification,
        );
      },
      child: Container(
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
              style: MITITextStyle.xxsmLight.copyWith(
                color: MITIColor.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
