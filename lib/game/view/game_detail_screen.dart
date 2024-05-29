import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/game/model/game_model.dart';
import 'package:miti/game/model/game_payment_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:collection/collection.dart';
import 'package:miti/game/view/game_participation_screen.dart';
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/theme/text_theme.dart';
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
  Widget build(BuildContext context) {
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            DefaultAppBar(
              title: '경기 상세',
              isSliver: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                )
              ],
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
                      getBottomButton(model, ref, context),
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

  Widget getBottomButton(
      GameDetailModel model, WidgetRef ref, BuildContext context) {
    Widget? button;
    final buttonTextStyle = MITITextStyle.btnTextBStyle.copyWith(
      color: Colors.white,
      height: 1,
    );
    final editButton = TextButton(
      onPressed: () {
        Map<String, String> pathParameters = {'gameId': model.id.toString()};
        context.pushNamed(GameUpdateScreen.routeName,
            pathParameters: pathParameters);
      },
      style: TextButton.styleFrom(
        fixedSize: Size(double.infinity, 48.h),
        backgroundColor: const Color(0xFF52A2D0),
      ),
      child: Text(
        '경기 수정하기',
        style: buttonTextStyle,
      ),
    );
    final cancelButton = TextButton(
      onPressed: () async {
        Map<String, String> pathParameters = {
          'gameId': widget.gameId.toString(),
          'participationId': participationId!.toString(),
        };
        context.pushNamed(GameRefundScreen.routeName,
            pathParameters: pathParameters);
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
      child: Text(
        '경기 참가하기',
        style: buttonTextStyle,
      ),
    );
    final reviewButton = TextButton(
      onPressed: () {
        final participationId = model.participation?.id;
        Map<String, String> pathParameters = {'gameId': model.id.toString()};
        Map<String, String> queryParameters = {};
        if (participationId != null) {
          queryParameters['participationId'] = participationId.toString();
        }
        context.pushNamed(
          GameParticipationScreen.routeName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );
      },
      style: TextButton.styleFrom(
        fixedSize: Size(double.infinity, 48.h),
      ),
      child: Text(
        '리뷰 작성하기',
        style: buttonTextStyle,
      ),
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

    return button != null
        ? Positioned(bottom: 8.h, right: 16.w, left: 16.w, child: button)
        : Container();
  }

  Widget getDivider() {
    return Container(
      height: 5.h,
      color: const Color(0xFFF8F8F8),
    );
  }
}

class InfoComponent extends StatelessWidget {
  final String info;

  const InfoComponent({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '모집 정보',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            info,
            style: MITITextStyle.gameInfoStyle,
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
          ? 'half_star'
          : rating >= i + 1
              ? 'fill_star'
              : 'unfill_star';
      result.add(SvgPicture.asset(
        'assets/images/icon/$star.svg',
        height: 14.r,
        width: 14.r,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isHost ? "호스트 소개" : '게스트 소개',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff222222),
              height: 18 / 16,
            ),
          ),
          SizedBox(height: 19.h),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return Column(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon/user_thum.svg',
                        width: 40.r,
                        height: 40.r,
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                nickname,
                                style: MITITextStyle.nicknameTextStyle
                                    .copyWith(color: const Color(0xFF444444)),
                              ),
                              SizedBox(width: 5.w),
                              SvgPicture.asset(
                                'assets/images/icon/authentication.svg',
                                width: 14.r,
                                height: 14.r,
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ...getStar(rating.average_rating),
                                SizedBox(width: 3.w),
                                Text(
                                  rating.average_rating.toStringAsFixed(1),
                                  style:
                                      MITITextStyle.gameTimePlainStyle.copyWith(
                                    color: const Color(0xFF222222),
                                  ),
                                ),
                                SizedBox(width: 9.w),
                                Text(
                                  '후기 ${rating.num_of_reviews}',
                                  style:
                                      MITITextStyle.gameTimePlainStyle.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 19.h),
                  ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, idx) {
                        return Text(
                          reviews[idx].comment,
                          overflow: TextOverflow.ellipsis,
                          style: MITITextStyle.reviewSummaryStyle
                              .copyWith(color: const Color(0xFF666666)),
                        );
                      },
                      separatorBuilder: (_, idx) {
                        return SizedBox(height: 8.h);
                      },
                      itemCount: reviews.length),
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
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "참가 완료된 게스트 ($num_of_confirmed_participations/$max_invitation)",
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10.h),
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
                            SizedBox(width: 16.w),
                          ],
                        )),
                  ],
                )),
          if (confimed_participations.isEmpty)
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Text(
                "경기의 첫번째 플레이어가 되어보세요!",
                style: MITITextStyle.plainTextMStyle.copyWith(
                  color: const Color(0xff999999),
                ),
                textAlign: TextAlign.center,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // CircleAvatar(
        //   backgroundImage: NetworkImage(imageUrl),
        //   radius: 20.r,
        // ),
        SvgPicture.asset(
          'assets/images/icon/user_thum.svg',
          width: 40.r,
          height: 40.r,
        ),
        SizedBox(height: 4.h),
        Text(
          "$name 님",
          style: TextStyle(
            fontFamily: "Pretendard",
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff666666),
            letterSpacing: -0.25.sp,
            height: 20 / 14,
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
  final String fee;
  final int max_invitation;
  final int num_of_confirmed_participations;

  const SummaryComponent(
      {super.key,
      this.gameStatus,
      required this.title,
      required this.gameDate,
      required this.address,
      required this.fee,
      required this.max_invitation,
      required this.num_of_confirmed_participations,
      this.bankStatus});

  factory SummaryComponent.fromDetailModel({required GameDetailModel model}) {
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
      fee: NumberUtil.format(model.fee.toString()),
      max_invitation: model.max_invitation,
      num_of_confirmed_participations: model.num_of_confirmed_participations,
    );
  }

  factory SummaryComponent.fromPaymentModel({required GamePaymentModel model}) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (gameStatus != null) GameStateLabel(gameStatus: gameStatus!),
          if (bankStatus != null) SettlementLabel(bankType: bankStatus!),
          SizedBox(height: 13.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff222222),
              letterSpacing: -0.25.sp,
              height: 18 / 16,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            gameDate,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xff999999),
              letterSpacing: -0.25.sp,
              height: 16 / 14,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 13.h),
          Row(children: [
            SvgPicture.asset('assets/images/icon/map_pin.svg'),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                address,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff444444),
                  letterSpacing: -0.25.sp,
                  height: 16 / 14,
                ),
                textAlign: TextAlign.left,
              ),
            )
          ]),
          SizedBox(height: 4.h),
          Row(children: [
            SvgPicture.asset('assets/images/icon/people.svg'),
            SizedBox(width: 4.w),
            Text(
              "총 $max_invitation명 중 $num_of_confirmed_participations명 모집 완료",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xff444444),
                letterSpacing: -0.25.sp,
                height: 16 / 14,
              ),
              textAlign: TextAlign.left,
            )
          ]),
          SizedBox(height: 13.h),
          Text(
            "₩ $fee",
            style: TextStyle(
              fontFamily: "Pretendard",
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff4065f6),
              letterSpacing: -0.25.sp,
              height: 18 / 16,
            ),
            textAlign: TextAlign.left,
          )
        ],
      ),
    );
  }
}
