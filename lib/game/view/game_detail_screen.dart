import 'dart:developer';

import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/component/defalut_flashbar.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/model/game_model.dart';
import 'package:miti/game/model/game_payment_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:collection/collection.dart';
import 'package:miti/game/view/game_participation_screen.dart';
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:share_plus/share_plus.dart';
import '../../account/model/account_model.dart';
import '../../common/model/entity_enum.dart';
import '../../court/view/court_map_screen.dart';
import '../../default_screen.dart';
import '../../menu/view/menu_screen.dart';
import '../../user/model/review_model.dart';
import '../../user/view/user_info_screen.dart';
import '../../util/util.dart';
import 'game_payment_screen.dart';
import 'game_screen.dart';
import 'game_update_screen.dart';

class GameDetailScreen extends StatefulWidget {
  static String get routeName => 'gameDetail';
  final int gameId;
  final int bottomIdx;

  const GameDetailScreen(
      {super.key, required this.gameId, required this.bottomIdx});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  int? participationId;
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
      backgroundColor: MITIColor.gray750,
      floatingActionButton: GestureDetector(
        onTap: () async {
          final result = await Share.shareUri(Uri(scheme: "naver"));
        },
        child: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF000000).withOpacity(0.6),
          ),
          child: SvgPicture.asset(
            AssetUtil.getAssetPath(type: AssetType.icon, name: 'share'),
          ),
        ),
      ),
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final result = ref.watch(gameDetailProvider(gameId: widget.gameId));
          if (result is LoadingModel) {
            // todo skeleton
            return Container();
          } else if (result is ErrorModel) {
            return Container();
          }
          result as ResponseModel<GameDetailModel>;
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
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              title: '경기 상세 정보',
              isSliver: true,
              backgroundColor: MITIColor.gray750,
            ),
          ];
        },
        body: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final result = ref.watch(gameDetailProvider(gameId: widget.gameId));
            if (result is LoadingModel) {
              // todo skeleton
              return CustomScrollView(
                slivers: [],
              );
            } else if (result is ErrorModel) {
              return Text('에러');
            }
            result as ResponseModel<GameDetailModel>;
            final model = result.data!;
            log('model is_host ${model.is_host} model.is_participated = ${model.is_participated}');
            participationId = model.participation?.id;
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SummaryComponent.fromDetailModel(model: model),
                            getDivider(),
                            ParticipationComponent.fromModel(model: model),
                            getDivider(),
                            HostComponent.fromModel(model: model.host),
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
    );
  }

  Widget? getBottomButton(
      GameDetailModel model, WidgetRef ref, BuildContext context) {
    Widget? button;
    final buttonTextStyle = MITITextStyle.btnTextBStyle.copyWith(
      color: Colors.white,
      height: 1,
    );
    final editButton = Row(
      children: [
        SizedBox(
          width: 98.w,
          child: TextButton(
            onPressed: () {
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
                                    onPressed: () {},
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                MITIColor.gray800)),
                                    child: Text(
                                      "취소하기",
                                      style: MITITextStyle.mdBold.copyWith(
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
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(MITIColor.gray700),
            ),
            child: Text(
              "경기 취소",
              style: MITITextStyle.md.copyWith(color: MITIColor.error),
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
              final Map<String, String> queryParameters = {
                'bottomIdx': widget.bottomIdx.toString()
              };
              context.pushNamed(
                GameUpdateScreen.routeName,
                pathParameters: pathParameters,
                queryParameters: queryParameters,
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
        final Map<String, String> queryParameters = {
          'bottomIdx': widget.bottomIdx.toString(),
        };
        context.pushNamed(
          GameRefundScreen.routeName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
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
    final cancelDisableButton = TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        fixedSize: Size(double.infinity, 48.h),
        backgroundColor: const Color(0xFFE8E8E8),
      ),
      child: Text(
        '참여 취소하기',
        style: buttonTextStyle.copyWith(
          color: const Color(0xff969696),
          height: 1,
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
    final reviewButton = TextButton(
      onPressed: () {
        Map<String, String> pathParameters = {'gameId': model.id.toString()};
        Map<String, String> queryParameters = {
          'bottomIdx': widget.bottomIdx.toString()
        };
        context.pushNamed(
          GameParticipationScreen.routeName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );
      },
      style: TextButton.styleFrom(
        fixedSize: Size(double.infinity, 48.h),
      ),
      child: const Text('리뷰 작성하기'),
    );
    final gameStatus = model.game_status;
    final startTime = DateTime.parse('${model.startdate} ${model.starttime}');
    final policyValid = DateTime.now().difference(startTime).inHours <= -2;
    log('policyValid $policyValid');

    switch (gameStatus) {
      case GameStatus.open:
        if (model.is_host) {
          button = editButton;
        } else if (model.is_participated) {
          if (policyValid) {
            button = cancelButton;
          } else {
            button = cancelDisableButton;
          }
        } else {
          button = participationButton;
        }
        break;
      case GameStatus.closed:
        if (model.is_host) {
          button = editButton;
        } else if (model.is_participated) {
          button = participationButton;
        } else {
          button = null;
        }
        break;
      case GameStatus.canceled:
        button = null;
        break;
      case GameStatus.completed:
        if (model.is_participated || model.is_host) {
          button = reviewButton;
        }
        break;
    }

    return button;
  }

  Widget getDivider() {
    return Container(
      height: 4.h,
      color: MITIColor.gray800,
    );
  }
}

class InfoComponent extends StatelessWidget {
  final String info;

  const InfoComponent({super.key, required this.info});

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
          Text(
            info,
            style: MITITextStyle.sm150.copyWith(color: MITIColor.gray100),
          )
        ],
      ),
    );
  }
}

class HostComponent extends StatelessWidget {
  final String nickname;
  final RatingModel rating;
  final List<WrittenReviewModel> reviews;
  final bool isHost;

  const HostComponent({
    super.key,
    required this.nickname,
    required this.rating,
    required this.reviews,
    this.isHost = true,
  });

  factory HostComponent.fromModel(
      {required UserReviewModel model, bool isHost = true}) {
    return HostComponent(
      nickname: model.nickname,
      rating: model.rating,
      reviews: model.reviews,
      isHost: isHost,
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
              ? 'fill_star'
              : 'unfill_star';
      result.add(SvgPicture.asset(
        AssetUtil.getAssetPath(type: AssetType.icon, name: star),
        // height: 16.r,
        // width: 16.r,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isHost ? "호스트 소개" : '게스트 소개',
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 20.h),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return Column(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetUtil.getAssetPath(
                            type: AssetType.icon, name: "user_thum"),
                        width: 36.r,
                        height: 36.r,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nickname,
                            style: MITITextStyle.smBold
                                .copyWith(color: MITIColor.gray100),
                          ),
                          SizedBox(height: 4.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ...getStar(rating.average_rating),
                                SizedBox(width: 6.w),
                                Text(
                                  rating.average_rating.toStringAsFixed(1),
                                  style: MITITextStyle.sm.copyWith(
                                    color: MITIColor.gray100,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '리뷰 ${rating.num_of_reviews}',
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class ParticipationComponent extends StatelessWidget {
  final int max_invitation;
  final int num_of_confirmed_participations;
  final List<ConfirmedParticipationModel> confimed_participations;

  const ParticipationComponent(
      {super.key,
      required this.confimed_participations,
      required this.max_invitation,
      required this.num_of_confirmed_participations});

  factory ParticipationComponent.fromModel({required GameDetailModel model}) {
    return ParticipationComponent(
      confimed_participations: model.confirmed_participations,
      max_invitation: model.max_invitation,
      num_of_confirmed_participations: model.num_of_confirmed_participations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "참가 완료된 게스트 ($num_of_confirmed_participations / $max_invitation)",
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 20.h),
          if (confimed_participations.isNotEmpty)
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...confimed_participations.mapIndexed((idx, e) => Row(
                          children: [
                            _GuestTile(
                              name: confimed_participations[idx].nickname,
                            ),
                            SizedBox(width: 12.w),
                          ],
                        )),
                  ],
                )),
          if (confimed_participations.isEmpty)
            Text(
              "아직 참여한 게스트가 없습니다.",
              style: MITITextStyle.xxsm.copyWith(
                color: MITIColor.gray100,
              ),
            )
        ],
      ),
    );
  }
}

class _GuestTile extends StatelessWidget {
  final String name;

  const _GuestTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final subName = name.length > 5 ? '${name.substring(0, 5)}...' : name;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AssetUtil.getAssetPath(type: AssetType.icon, name: "user_thum"),
          width: 36.r,
          height: 36.r,
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
  final GameStatus? gameStatus;
  final SettlementType? bankStatus;
  final String title;
  final String gameDate;
  final String address;
  final String? fee;
  final String duration;
  final int max_invitation;
  final int num_of_confirmed_participations;
  final int? gameId;
  final bool isUpdateForm;

  const SummaryComponent(
      {super.key,
      this.gameStatus,
      required this.title,
      required this.gameDate,
      required this.address,
      this.fee,
      required this.max_invitation,
      required this.num_of_confirmed_participations,
      this.bankStatus,
      required this.duration,
      this.gameId,
      this.isUpdateForm = false});

  factory SummaryComponent.fromDetailModel(
      {required GameDetailModel model, bool isUpdateForm = false}) {
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
    final address =
        '${model.court.address} ${model.court.address_detail ?? ''}';
    return SummaryComponent(
      gameId: model.id,
      gameStatus: model.game_status,
      title: model.title,
      gameDate: gameDate,
      address: address,
      fee: NumberUtil.format(model.fee.toString()),
      max_invitation: model.max_invitation,
      num_of_confirmed_participations: model.num_of_confirmed_participations,
      duration: end.difference(start).inMinutes.toString(),
      isUpdateForm: isUpdateForm,
    );
  }

  factory SummaryComponent.fromPaymentModel({required GamePaymentModel model}) {
    final start = DateTime.parse("${model.startdate} ${model.starttime}");
    final end = DateTime.parse("${model.enddate} ${model.endtime}");
    final startDate = model.startdate.replaceAll('-', '. ');
    final endDate = model.startdate.replaceAll('-', '. ');

    final time =
        '${model.starttime.substring(0, 5)} ~ ${model.endtime.substring(0, 5)}';
    final gameDate = startDate == endDate
        ? '$startDate $time'
        : '$startDate ${model.starttime.substring(0, 5)} ~ $endDate ${model.endtime.substring(0, 5)}';
    final address =
        '${model.court.address} ${model.court.address_detail ?? ''}';
    return SummaryComponent(
      gameStatus: model.game_status,
      title: model.title,
      gameDate: gameDate,
      address: address,
      fee: NumberUtil.format(
          model.payment_information.payment_amount.game_fee_amount.toString()),
      max_invitation: model.max_invitation,
      num_of_confirmed_participations: model.num_of_confirmed_participations,
      duration: end.difference(start).inMinutes.toString(),
    );
  }

  factory SummaryComponent.fromSettlementModel(
      {required SettlementDetailModel model}) {
    final game = model.game;
    final startDate = game.startdate.replaceAll('-', '. ');
    final endDate = game.startdate.replaceAll('-', '. ');

    final time =
        '${game.starttime.substring(0, 5)} ~ ${game.endtime.substring(0, 5)}';
    final gameDate = startDate == endDate
        ? '$startDate $time'
        : '$startDate ${game.starttime.substring(0, 5)} ~ $endDate ${game.endtime.substring(0, 5)}';
    final address = '${game.court.address} ${game.court.address_detail ?? ''}';
    return SummaryComponent(
      bankStatus: model.status,
      title: game.title,
      gameDate: gameDate,
      address: address,
      fee: NumberUtil.format(game.fee.toString()),
      max_invitation: game.max_invitation,
      num_of_confirmed_participations: game.num_of_confirmed_participations,
      duration: '',
    );
  }

  Row gameInfoComponent({required String title, required String svgPath}) {
    return Row(children: [
      SvgPicture.asset(
        width: 16.r,
        height: 16.r,
        colorFilter: const ColorFilter.mode(MITIColor.gray100, BlendMode.srcIn),
        AssetUtil.getAssetPath(
          type: AssetType.icon,
          name: svgPath,
        ),
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: MITITextStyle.sm.copyWith(color: MITIColor.gray100),
          textAlign: TextAlign.left,
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
                          return TextButton(
                            onPressed: () async {
                              final result = await ref.read(
                                  gameFreeProvider(gameId: gameId!).future);

                              if (context.mounted) {
                                if (result is ErrorModel) {
                                  GameError.fromModel(model: result)
                                      .responseError(
                                          context, GameApiType.free, ref);
                                } else {
                                  context.pop();
                                  FlashUtil.showFlash(
                                      context, "무료 경기로 전환되었습니다.");
                                  // todo
                                }
                              }
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

  @override
  Widget build(BuildContext context) {
    final desc = [
      "$duration분 경기",
      address,
      "$num_of_confirmed_participations / $max_invitation"
    ];
    final svgPath = ["clock", "map_pin", "people"];

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (gameStatus != null) GameStateLabel(gameStatus: gameStatus!),
          if (bankStatus != null) SettlementLabel(bankType: bankStatus!),
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
              shrinkWrap: true,
              itemBuilder: (_, idx) {
                return gameInfoComponent(
                  title: desc[idx],
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
