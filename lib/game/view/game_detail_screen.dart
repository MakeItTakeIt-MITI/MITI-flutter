import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/chat/provider/chat_approve_provider.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/component/defalut_flashbar.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/model/widget/user_reivew_short_info_model.dart';
import 'package:miti/game/provider/game_provider.dart' hide Rating;
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/game/view/game_review_list_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../chat/model/game_chat_room_approved_users_response.dart';
import '../../chat/view/chat_room_screen.dart';
import '../../common/component/share_fab_component.dart';
import '../../common/model/entity_enum.dart';
import '../../court/view/court_detail_screen.dart';
import '../../report/view/report_list_screen.dart';
import '../../review/model/v2/base_guest_rating_response.dart';
import '../../user/model/v2/user_host_rating_response.dart';
import '../../util/naver_map_util.dart';
import '../../util/util.dart';
import '../component/skeleton/game_detail_skeleton.dart';
import '../model/v2/game/game_detail_response.dart';
import '../model/v2/game/game_participation_payment_detail_response.dart';
import '../model/v2/game/game_with_court_response.dart';
import '../model/v2/participation/base_participation_response.dart';
import 'game_participation_screen.dart';
import 'game_payment_screen.dart';
import 'game_screen.dart';
import 'game_update_screen.dart';

class GameDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'gameDetail';
  final int gameId;

  const GameDetailScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends ConsumerState<GameDetailScreen> {
  late final FocusNode focusNode;
  int? participationId;
  final fabKey = GlobalKey<ExpandableFabState>();
  late final ScrollController _scrollController;
  late Throttle<int> _throttler;
  int throttleCnt = 0;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) {
      _cancel(ref, context);
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
    });

    _scrollController = ScrollController();
    ref
        .read(chatApproveProvider(gameId: widget.gameId).notifier)
        .get(gameId: widget.gameId);
    log("gameDetail initState");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log("gameDetail didChangeDependencies");
  }

  @override
  void didUpdateWidget(covariant GameDetailScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _throttler.cancel();
    _scrollController.dispose();
    fabKey.currentState?.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectableRegion(
        focusNode: focusNode,
        selectionControls: materialTextSelectionControls,
        child: Scaffold(
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              GameDetailResponse? model;
              final result =
                  ref.watch(gameDetailProvider(gameId: widget.gameId));
              if (result is ResponseModel<GameDetailResponse>) {
                model = result.data!;
              }
              return ShareFabComponent(
                id: widget.gameId,
                type: ShareType.games,
                globalKey: fabKey,
                model: model,
              );
            },
          ),
          bottomNavigationBar: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final result =
                  ref.watch(gameDetailProvider(gameId: widget.gameId));
              if (result is LoadingModel) {
                // todo skeleton
                return const SizedBox(height: 0);
              } else if (result is ErrorModel) {
                return const SizedBox(height: 0);
              }
              result as ResponseModel<GameDetailResponse>;
              final model = result.data!;
              final button = getBottomButton(model, ref, context);
              return button != null
                  ? BottomButton(
                      button: button,
                    )
                  : const SizedBox();
            },
          ),
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                DefaultAppBar(
                  title: '경기 상세 정보',
                  isSliver: true,
                  hasBorder: false,
                  actions: [
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final userId = ref.watch(authProvider)?.id;

                        final result = ref
                            .watch(chatApproveProvider(gameId: widget.gameId));
                        bool visible = false;
                        if (result is LoadingModel || result is ErrorModel) {
                          visible = false;
                        } else {
                          final model = (result as ResponseModel<
                                  GameChatRoomApprovedUsersResponse>)
                              .data!;
                          visible = model.approvedUsers.contains(userId);
                        }

                        return Visibility(
                          visible: visible,
                          child: child!,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 13.w),
                        child: InkWell(
                          onTap: () {
                            Map<String, String> pathParameters = {
                              'gameId': widget.gameId.toString()
                            };
                            context.pushNamed(ChatRoomScreen.routeName,
                                pathParameters: pathParameters);
                          },
                          child: SvgPicture.asset(
                            AssetUtil.getAssetPath(
                                type: AssetType.icon, name: 'comments'),
                            width: 24.r,
                            height: 24.r,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ];
            },
            body: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final result =
                    ref.watch(gameDetailProvider(gameId: widget.gameId));
                if (result is LoadingModel) {
                  return const SingleChildScrollView(
                      child: GameDetailSkeleton());
                } else if (result is ErrorModel) {
                  WidgetsBinding.instance.addPostFrameCallback((s) =>
                      GameError.fromModel(model: result)
                          .responseError(context, GameApiType.get, ref));
                  return Text('에러입니다.');
                }
                result as ResponseModel<GameDetailResponse>;
                final model = result.data!;
                // log('model is_host ${model.is_host} model.is_participated = ${model.is_participated}');

                participationId = model.user_participation_id;
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                CourtMapComponent(
                                  latLng: NLatLng(
                                    double.parse(model.court.latitude),
                                    double.parse(model.court.longitude),
                                  ),
                                ),
                                SummaryComponent.fromDetailModel(model: model),
                                getDivider(),
                                ParticipationComponent.fromModel(model: model),
                                getDivider(),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: 20.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 21.w),
                                      child: Text(
                                        '호스트 소개',
                                        style: MITITextStyle.mdBold
                                            .copyWith(color: MITIColor.gray100),
                                      ),
                                    ),
                                    UserShortInfoComponent.fromHostModel(
                                        model: model.host),
                                  ],
                                ),
                                getDivider(),
                                InfoComponent(
                                  info: model.info,
                                ),
                                SizedBox(height: 60.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }

  Widget? getBottomButton(
      GameDetailResponse model, WidgetRef ref, BuildContext context) {
    Widget? button;
    final gameStatus = model.game_status;
    final startTime = DateTime.parse('${model.startdate} ${model.starttime}');
    final createdAt = DateTime.parse('${model.created_at}');
    final policyValid = startTime.difference(DateTime.now()).inHours > 2;
    final policyCreatedAtValid =
        createdAt.difference(DateTime.now()).inHours >= -2;
    log('policyValid $policyValid policyCreatedAtValid = $policyCreatedAtValid ');
    log('DateTime.now().difference(createdAt).inHours = ${createdAt.difference(DateTime.now()).inHours}');
    final editValid = policyValid && policyCreatedAtValid;
    final buttonTextStyle = MITITextStyle.btnTextBStyle.copyWith(
      color: Colors.white,
      height: 1,
    );
    final editButton = Row(
      children: [
        SizedBox(
          width: 98.w,
          child: TextButton(
            onPressed: editValid
                ? () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return BottomDialog(
                              title: "경기 취소",
                              content:
                                  "경기 취소 시, 모집 완료된 참가자와 경기 정보가 모두 삭제됩니다.\n경기를 취소하시겠습니까?",
                              btn: Row(
                                children: [
                                  Expanded(
                                      child: TextButton(
                                          onPressed: () {
                                            _throttler
                                                .setValue(throttleCnt + 1);
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                      MITIColor.gray800)),
                                          child: Text(
                                            "취소하기",
                                            style:
                                                MITITextStyle.mdBold.copyWith(
                                              color: MITIColor.primary,
                                            ),
                                          ))),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                      child: TextButton(
                                          onPressed: () => context.pop(),
                                          child: const Text("경기 유지하기"))),
                                ],
                              ));
                        });
                  }
                : null,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(MITIColor.gray700),
            ),
            child: Text(
              "경기 취소",
              style: MITITextStyle.md.copyWith(
                  color: editValid ? MITIColor.error : MITIColor.gray500),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: TextButton(
            onPressed: () {
              Map<String, String> pathParameters = {
                'gameId': model.id.toString()
              };

              context.pushNamed(
                GameUpdateScreen.routeName,
                pathParameters: pathParameters,
              );
            },
            style: TextButton.styleFrom(
              fixedSize: Size(double.infinity, 48.h),
            ),
            child: const Text('경기 수정하기'),
          ),
        ),
      ],
    );
    final cancelButton = TextButton(
      onPressed: () async {
        Map<String, String> pathParameters = {
          'gameId': widget.gameId.toString(),
          'participationId': participationId!.toString(),
        };

        context.pushNamed(
          GameRefundScreen.routeName,
          pathParameters: pathParameters,
        );
      },
      style: TextButton.styleFrom(
        fixedSize: Size(double.infinity, 48.h),
        backgroundColor: const Color(0xFFF64061),
      ),
      child: Text(
        '참여 취소하기',
        style: buttonTextStyle,
      ),
    );
    final cancelDisableButton = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 17.h),
        child: Text(
          '경기 시간 2시간 이내에는 참여 취소가 불가능합니다.',
          style: MITITextStyle.sm.copyWith(
            color: MITIColor.gray50,
          ),
        ),
      ),
    );
    final participationButton = TextButton(
      onPressed: () {
        Map<String, String> pathParameters = {'gameId': model.id.toString()};
        context.pushNamed(GamePaymentScreen.routeName,
            pathParameters: pathParameters);
      },
      style: TextButton.styleFrom(
        fixedSize: Size(double.infinity, 48.h),
      ),
      child: const Text(
        '경기 참여하기',
      ),
    );
    final disabledParticipationButton = TextButton(
      onPressed: null,
      style: TextButton.styleFrom(
          fixedSize: Size(double.infinity, 48.h),
          backgroundColor: MITIColor.gray700),
      child: Text(
        '경기 참여하기',
        style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray500),
      ),
    );
    final reviewButton = TextButton(
      onPressed: () {
        Map<String, String> pathParameters = {'gameId': model.id.toString()};

        context.pushNamed(
          GameReviewListScreen.routeName,
          pathParameters: pathParameters,
        );
      },
      style: TextButton.styleFrom(
        fixedSize: Size(double.infinity, 48.h),
        maximumSize: Size(double.infinity, 48.h),
        minimumSize: Size(double.infinity, 48.h),
      ),
      child: const Text('리뷰 작성하기'),
    );
    final reportButton = TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                title: '경기 신고하기',
                content: '‘${model.title}’ 경기를 신고하시겠습니까?',
                button: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: MITIColor.gray700),
                        onPressed: () => context.pop(),
                        child: Text(
                          '취소하기',
                          style: MITITextStyle.mdSemiBold.copyWith(
                            color: MITIColor.gray200,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: MITIColor.error),
                        onPressed: () {
                          Map<String, String> queryParameters = {
                            'gameId': widget.gameId.toString(),
                          };
                          context.pop();
                          context.pushNamed(
                            ReportListScreen.routeName,
                            queryParameters: queryParameters,
                            extra: ReportCategoryType.host_report,
                          );
                        },
                        child: Text(
                          '신고하기',
                          style: MITITextStyle.mdSemiBold.copyWith(
                            color: MITIColor.gray200,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        style: TextButton.styleFrom(
          fixedSize: Size(98.w, 48.h),
          maximumSize: Size(98.w, 48.h),
          minimumSize: Size(98.w, 48.h),
          backgroundColor: MITIColor.gray700,
        ),
        child: Text(
          "신고하기",
          style: MITITextStyle.md.copyWith(
            color: MITIColor.error,
          ),
        ));

    if (model.is_host) {
      switch (gameStatus) {
        case GameStatusType.open || GameStatusType.closed:
          button = editButton;
          // if (!policyValid || !policyCreatedAtValid) {
          // } else if (policyValid && policyCreatedAtValid) {
          //   button = editButton;
          // }
          break;
        case GameStatusType.canceled:
          button = null;
          break;
        case GameStatusType.completed:
          // if (model.user_participation_id != null) {
          button = reviewButton;
          // }
          break;
      }
    } else {
      switch (gameStatus) {
        case GameStatusType.open || GameStatusType.closed:
          if (model.user_participation_id == null &&
              gameStatus == GameStatusType.open) {
            button = participationButton;
          } else if (model.user_participation_id == null &&
              gameStatus == GameStatusType.closed) {
            button = disabledParticipationButton;
          } else if (model.user_participation_id != null) {
            if (policyValid) {
              button = cancelButton;
            } else {
              button = cancelDisableButton;
            }
          }
          break;
        case GameStatusType.canceled:
          button = null;
          break;
        case GameStatusType.completed:
          if (model.user_participation_id == null) {
            button = null;
          } else {
            button = Align(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  reportButton,
                  SizedBox(width: 12.w),
                  Expanded(child: reviewButton)
                ],
              ),
            );
          }
          break;
      }
    }

    return button;
  }

  Future<void> _cancel(WidgetRef ref, BuildContext context) async {
    final result =
        await ref.read(cancelRecruitGameProvider(gameId: widget.gameId).future);

    if (result is ErrorModel) {
      if (context.mounted) {
        GameError.fromModel(model: result)
            .responseError(context, GameApiType.cancel, ref);
        context.pop();
      }
    } else {
      if (context.mounted) {
        context.goNamed(GameScreen.routeName);
      }
    }
  }

  Widget getDivider() {
    return Container(
      height: 1.h,
      color: MITIColor.gray750,
    );
  }
}

class InfoComponent extends StatelessWidget {
  final String info;

  const InfoComponent({super.key, required this.info});

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '모집 정보',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          Linkify(
            onOpen: _onOpen,
            text: info,
            style: MITITextStyle.sm150.copyWith(color: MITIColor.gray100),
            options: const LinkifyOptions(
              humanize: false,
              removeWww: false,
            ),
          ),
        ],
      ),
    );
  }
}

class UserShortInfoComponent extends StatelessWidget {
  final String profileImageUrl;
  final String nickname;
  final BaseRatingResponse rating;

  const UserShortInfoComponent({
    super.key,
    required this.nickname,
    required this.rating,
    required this.profileImageUrl,
  });

  factory UserShortInfoComponent.fromModel(
      {required UserReviewShortInfoModel model}) {
    return UserShortInfoComponent(
      nickname: model.nickname,
      rating: model.rating,
      profileImageUrl: model.profileImageUrl,
    );
  }

  factory UserShortInfoComponent.fromHostModel(
      {required UserHostRatingResponse model}) {
    return UserShortInfoComponent(
      nickname: model.nickname,
      rating: model.hostRating,
      profileImageUrl: model.profileImageUrl,
    );
  }

  List<Widget> getStar(double rating) {
    List<Widget> result = [];
    for (int i = 0; i < 5; i++) {
      bool flag = false;
      if (i == rating.toInt()) {
        final decimalPoint = rating - rating.toInt();
        flag = decimalPoint != 0;
      }
      final String star = flag
          ? 'Star_half_v2'
          : rating >= i + 1
              ? 'fill_star2'
              : 'unfill_star2';
      result.add(Padding(
        padding: EdgeInsets.only(right: 2.w),
        child: SvgPicture.asset(
          AssetUtil.getAssetPath(type: AssetType.icon, name: star),
          height: 16.r,
          width: 16.r,
        ),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            children: [
              Row(
                children: [
                  if (profileImageUrl != null)
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          NetworkImage(profileImageUrl, scale: 36.r),
                    )
                  else
                    SvgPicture.asset(
                      AssetUtil.getAssetPath(
                          type: AssetType.icon, name: 'user_thum'),
                      width: 36.r,
                      height: 36.r,
                    ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$nickname 님",
                        style: MITITextStyle.smBold
                            .copyWith(color: MITIColor.gray100),
                      ),
                      SizedBox(height: 4.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...getStar(rating.averageRating ?? 0),
                            SizedBox(width: 6.w),
                            Text(
                              rating.averageRating?.toStringAsFixed(1) ?? '0',
                              style: MITITextStyle.sm.copyWith(
                                color: MITIColor.gray100,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '리뷰 ${rating.numOfReviews}',
                              style: MITITextStyle.sm.copyWith(
                                  color: MITIColor.gray100,
                                  decoration: TextDecoration.underline,
                                  decorationColor: MITIColor.gray100),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              // SizedBox(height: 19.h),
              // ListView.separated(
              //     padding: EdgeInsets.zero,
              //     shrinkWrap: true,
              //     physics: const NeverScrollableScrollPhysics(),
              //     itemBuilder: (_, idx) {
              //       return Text(
              //         reviews[idx].comment,
              //         overflow: TextOverflow.ellipsis,
              //         style: MITITextStyle.reviewSummaryStyle
              //             .copyWith(color: const Color(0xFF666666)),
              //       );
              //     },
              //     separatorBuilder: (_, idx) {
              //       return SizedBox(height: 8.h);
              //     },
              //     itemCount: reviews.length),
            ],
          ),
        );
      },
    );
  }
}

class ParticipationComponent extends StatelessWidget {
  final int gameId;
  final int max_invitation;
  final int num_of_confirmed_participations;
  final int? user_participation_id;
  final List<BaseParticipationResponse> participations;
  final bool isHost;

  const ParticipationComponent({
    super.key,
    required this.participations,
    required this.max_invitation,
    required this.num_of_confirmed_participations,
    required this.gameId,
    required this.user_participation_id,
    required this.isHost,
  });

  factory ParticipationComponent.fromModel(
      {required GameDetailResponse model}) {
    return ParticipationComponent(
      participations: model.participations,
      max_invitation: model.max_invitation,
      num_of_confirmed_participations: model.num_of_participations,
      gameId: model.id,
      user_participation_id: model.user_participation_id,
      isHost: model.is_host,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isParticipation = user_participation_id != null || isHost;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: isParticipation
                ? () {
                    Map<String, String> pathParameters = {
                      'gameId': gameId.toString()
                    };
                    context.pushNamed(
                      GameParticipationScreen.routeName,
                      pathParameters: pathParameters,
                    );
                  }
                : null,
            child: Container(
              color: MITIColor.gray800,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "참가 완료된 게스트 ($num_of_confirmed_participations / $max_invitation)",
                    style:
                        MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
                    textAlign: TextAlign.left,
                  ),
                  Visibility(
                    visible: isParticipation,
                    child: SvgPicture.asset(
                      AssetUtil.getAssetPath(
                        type: AssetType.icon,
                        name: 'chevron_right',
                      ),
                      colorFilter: const ColorFilter.mode(
                        MITIColor.gray400,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          if (participations.isNotEmpty)
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...participations.mapIndexed((idx, e) => Row(
                          children: [
                            _GuestTile(
                              name: participations[idx].user.nickname,
                              profileImageUrl:
                                  participations[idx].user.profileImageUrl,
                            ),
                            SizedBox(width: 12.w),
                          ],
                        )),
                  ],
                )),
          if (participations.isEmpty)
            SizedBox(
              height: 56.h,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "아직 참여한 게스트가 없습니다.",
                  style: MITITextStyle.xxsm.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class _GuestTile extends StatelessWidget {
  final String name;
  final String profileImageUrl;

  const _GuestTile(
      {super.key, required this.name, required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    final subName = name.length > 5 ? '${name.substring(0, 5)}...' : name;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 18.r,
          backgroundImage: NetworkImage(profileImageUrl, scale: 36.r),
        ),
        SizedBox(height: 8.h),
        Text(
          "$subName 님",
          style: MITITextStyle.xxsm.copyWith(
            color: MITIColor.gray100,
          ),
        )
      ],
    );
  }
}

class SummaryComponent extends StatelessWidget {
  final GameStatusType? gameStatus;
  final SettlementStatusType? bankStatus;
  final String title;
  final String gameDate;
  final String address;
  final String? courtName;
  final String? fee;
  final String duration;
  final int max_invitation;
  final int num_of_participations;
  final int? gameId;
  final bool isUpdateForm;
  final String? latitude;
  final String? longitude;

  const SummaryComponent({
    super.key,
    this.gameStatus,
    required this.title,
    required this.gameDate,
    required this.address,
    this.courtName,
    this.fee,
    required this.max_invitation,
    required this.num_of_participations,
    this.bankStatus,
    required this.duration,
    this.gameId,
    this.isUpdateForm = false,
    this.latitude,
    this.longitude,
  });

  factory SummaryComponent.fromDetailModel(
      {required GameDetailResponse model, bool isUpdateForm = false}) {
    final start = DateTime.parse("${model.startdate} ${model.starttime}");
    final end = DateTime.parse("${model.enddate} ${model.endtime}");

    log("start $start");
    final startDate = model.startdate.replaceAll('-', '. ');
    final endDate = model.startdate.replaceAll('-', '. ');

    final time =
        '${model.starttime.substring(0, 5)} ~ ${model.endtime.substring(0, 5)}';
    final gameDate = startDate == endDate
        ? '$startDate $time'
        : '$startDate ${model.starttime.substring(0, 5)} ~ $endDate ${model.endtime.substring(0, 5)}';
    return SummaryComponent(
      gameId: model.id,
      gameStatus: model.game_status,
      title: model.title,
      gameDate: gameDate,
      address: model.court.address,
      courtName: model.court.name!,
      fee: NumberUtil.format(model.fee.toString()),
      max_invitation: model.max_invitation,
      num_of_participations: model.num_of_participations,
      duration: end.difference(start).inMinutes.toString(),
      isUpdateForm: isUpdateForm,
      latitude: model.court.latitude,
      longitude: model.court.longitude,
    );
  }

  factory SummaryComponent.fromPaymentModel(
      {required GameParticipationPaymentDetailResponse model}) {
    final start = DateTime.parse("${model.startDate} ${model.startTime}");
    final end = DateTime.parse("${model.endDate} ${model.endTime}");
    final startDate = model.startDate.replaceAll('-', '. ');
    final endDate = model.endDate.replaceAll('-', '. ');

    final time =
        '${model.startTime.substring(0, 5)} ~ ${model.endTime.substring(0, 5)}';
    final gameDate = startDate == endDate
        ? '$startDate $time'
        : '$startDate ${model.startTime.substring(0, 5)} ~ $endDate ${model.endTime.substring(0, 5)}';
    final address = '${model.court.address} ${model.court.addressDetail ?? ''}';
    return SummaryComponent(
      gameStatus: model.gameStatus,
      title: model.title,
      gameDate: gameDate,
      address: address,
      fee: NumberUtil.format(
          model.paymentInformation.paymentAmount.gameFeeAmount.toString()),
      max_invitation: model.maxInvitation,
      num_of_participations: model.numOfParticipations,
      duration: end.difference(start).inMinutes.toString(),
    );
  }

  factory SummaryComponent.fromRefundModel(
      {required GameWithCourtResponse model}) {
    final start = DateTime.parse("${model.startDate} ${model.startTime}");
    final end = DateTime.parse("${model.endDate} ${model.endTime}");
    final startDate = model.startDate.replaceAll('-', '. ');
    final endDate = model.endDate.replaceAll('-', '. ');

    final time =
        '${model.startTime.substring(0, 5)} ~ ${model.endTime.substring(0, 5)}';
    final gameDate = startDate == endDate
        ? '$startDate $time'
        : '$startDate ${model.startTime.substring(0, 5)} ~ $endDate ${model.endTime.substring(0, 5)}';
    final address = '${model.court.address} ${model.court.addressDetail ?? ''}';
    return SummaryComponent(
      gameStatus: model.gameStatus,
      title: model.title,
      gameDate: gameDate,
      address: address,
      // fee: NumberUtil.format(
      //     model.payment_information.payment_amount.game_fee_amount.toString()),
      max_invitation: model.maxInvitation,
      num_of_participations: model.numOfParticipations,
      duration: end.difference(start).inMinutes.toString(),
    );
  }

  Row gameInfoComponent(
      {required String title, String? content, required String svgPath}) {
    return Row(children: [
      SvgPicture.asset(
        width: 16.r,
        height: 16.r,
        colorFilter: ColorFilter.mode(
            content != null ? MITIColor.primary : MITIColor.gray100,
            BlendMode.srcIn),
        AssetUtil.getAssetPath(
          type: AssetType.icon,
          name: svgPath,
        ),
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: GestureDetector(
          onTap: () async {
            if (content == null) return;
            await NaverMapUtil.searchRoute(
              destinationAddress: address,
              destinationLat: double.parse(latitude!),
              destinationLng: double.parse(longitude!),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MITITextStyle.sm.copyWith(
                    color: content != null
                        ? MITIColor.primary
                        : MITIColor.gray100),
                textAlign: TextAlign.left,
              ),
              if (content != null)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MITITextStyle.sm.copyWith(color: MITIColor.primary),
                    textAlign: TextAlign.left,
                  ),
                ),
            ],
          ),
        ),
      )
    ]);
  }

  Widget _freeChip({required String title}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.r),
        color: MITIColor.gray600,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Text(
        title,
        style: MITITextStyle.smBold.copyWith(
          color: MITIColor.primary,
        ),
      ),
    );
  }

  Widget feeComponent(BuildContext context) {
    if (fee == "0") {
      return _freeChip(title: "무료 경기");
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "참가비 $fee 원",
          style: MITITextStyle.mdBold.copyWith(
            color: MITIColor.primary,
          ),
          textAlign: TextAlign.left,
        ),
        if (isUpdateForm)
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return BottomDialog(
                      hasPop: true,
                      title: '경기 참가비 무료로 전환',
                      content:
                          '무료 경기로 변경 시, 기존 참가자의 결제는 자동으로 취소되며\n이후 참가비 변경이 불가능합니다.',
                      btn: Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          final throttler = Throttle(
                            const Duration(seconds: 1),
                            initialValue: false,
                            checkEquality: true,
                          );
                          throttler.values.listen((bool s) {
                            _changeFree(ref, context);
                          });
                          return TextButton(
                            onPressed: () async {
                              throttler.setValue(true);
                            },
                            child: const Text("무료 경기로 전환"),
                          );
                        },
                      ),
                    );
                  });
            },
            child: _freeChip(title: "무료 경기로 전환하기"),
          ),
      ],
    );
  }

  Future<void> _changeFree(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(gameFreeProvider(gameId: gameId!).future);

    if (context.mounted) {
      if (result is ErrorModel) {
        GameError.fromModel(model: result)
            .responseError(context, GameApiType.free, ref);
      } else {
        context.pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          FlashUtil.showFlash(context, '무료 경기로 전환되었습니다.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final desc = [
      "$duration분 경기",
      "$num_of_participations / $max_invitation",
      address,
    ];
    final svgPath = ["clock", "people", "map_pin"];

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (gameStatus != null) GameStateLabel(gameStatus: gameStatus!),
          if (bankStatus != null) SettlementLabel(settlementType: bankStatus!),
          SizedBox(height: 12.h),
          Text(
            title,
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            gameDate,
            style: MITITextStyle.sm.copyWith(color: MITIColor.gray400),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 20.h),
          ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (_, idx) {
                final content = idx == 2 ? courtName : null;
                return gameInfoComponent(
                  title: desc[idx],
                  content: content,
                  svgPath: svgPath[idx],
                );
              },
              separatorBuilder: (_, idx) => SizedBox(height: 4.h),
              itemCount: 3),
          Visibility(
              visible: gameId != null,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  feeComponent(context),
                ],
              ))
        ],
      ),
    );
  }
}
