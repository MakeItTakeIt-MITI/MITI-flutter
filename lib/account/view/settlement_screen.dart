import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/model/account_model.dart';
import 'package:miti/account/provider/account_pagination_provider.dart';
import 'package:miti/account/view/settlement_detail_screen.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../common/component/custom_drop_down_button.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../game/component/game_state_label.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../param/account_param.dart';

class SettlementListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'settlements';
  final int bottomIdx;

  const SettlementListScreen({
    super.key,
    required this.bottomIdx,
  });

  @override
  ConsumerState<SettlementListScreen> createState() =>
      _SettlementListScreenState();
}

class _SettlementListScreenState extends ConsumerState<SettlementListScreen> {
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

  Future<void> refresh() async {
    final userId = ref.read(authProvider)!.id!;
    final value = ref.read(dropDownValueProvider);
    final status = getStatus(value!);
    log('status = ${status}');
    final provider = settlementPageProvider(PaginationStateParam(path: userId));
    ref.read(provider.notifier).paginate(
          path: userId,
          forceRefetch: true,
          param: SettlementPaginationParam(
            status: status,
          ),
          paginationParams: const PaginationParam(page: 1),
        );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      '정산 완료',
      '부분 정산',
      '대기중',
      '전체 보기',
    ];

    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '정산 내역',
            ),
          ];
        }),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: 14.w, top: 14.h, bottom: 14.h),
                  child: Row(
                    children: [
                      const Spacer(),
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          return CustomDropDownButton(
                            initValue: '전체 보기',
                            onChanged: (value) {
                              changeDropButton(value, ref);
                            },
                            items: items,
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final userId = ref.watch(authProvider)!.id!;
                  return DisposeSliverPaginationListView(
                      provider: settlementPageProvider(
                          PaginationStateParam(path: userId)),
                      itemBuilder:
                          (BuildContext context, int index, Base pModel) {
                        final model = pModel as SettlementModel;

                        return SettlementCard.fromModel(
                          model: model,
                          bottomIdx: widget.bottomIdx,
                        );
                      },
                      skeleton: Container(),
                      controller: _scrollController,
                      emptyWidget: getEmptyWidget());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  SettlementType? getStatus(String? value) {
    switch (value) {
      case '대기중':
        return SettlementType.waiting;
      case '정산 완료':
        return SettlementType.completed;
      case '부분 정산':
        return SettlementType.partial_completed;
      default:
        return null;
    }
  }

  void changeDropButton(String? value, WidgetRef ref) {
    final userId = ref.read(authProvider)!.id!;
    ref.read(dropDownValueProvider.notifier).update((state) => value);
    final status = getStatus(value!);
    log('status = ${status}');
    final provider = settlementPageProvider(PaginationStateParam(path: userId));
    ref.read(provider.notifier).paginate(
          path: userId,
          forceRefetch: true,
          param: SettlementPaginationParam(
            status: status,
          ),
          paginationParams: const PaginationParam(page: 1),
        );
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '정산 내역이 없습니다.',
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

class SettlementCard extends StatelessWidget {
  final int id;
  final String title;
  final String datetime;
  final String address;
  final String fee;
  final SettlementType status;
  final int bottomIdx;

  const SettlementCard({
    super.key,
    required this.title,
    required this.datetime,
    required this.address,
    required this.id,
    required this.fee,
    required this.status,
    required this.bottomIdx,
  });

  factory SettlementCard.fromModel({
    required SettlementModel model,
    required int bottomIdx,
  }) {
    final game = model.game;
    final datetime =
        '${game.startdate.replaceAll('-', '.')} ${game.starttime.substring(0, 5)} ~ ${game.enddate.replaceAll('-', '.')} ${game.endtime.substring(0, 5)}';
    return SettlementCard(
      title: game.title,
      datetime: datetime,
      address: '${game.court.address} ${game.court.address_detail ?? ''}',
      id: model.id,
      fee: NumberUtil.format(game.fee.toString()),
      status: model.status,
      bottomIdx: bottomIdx,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: InkWell(
        onTap: () {
          Map<String, String> pathParameters = {'settlementId': id.toString()};
          final Map<String, String> queryParameters = {
            'bottomIdx': bottomIdx.toString()
          };
          context.pushNamed(
            SettlementDetailScreen.routeName,
            pathParameters: pathParameters,
            queryParameters: queryParameters,
          );
        },
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8E8E8)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettlementLabel(
                bankType: status,
              ),
              SizedBox(height: 7.h),
              Text(
                title,
                style: MITITextStyle.gameTitleMainStyle.copyWith(
                  color: const Color(0xff333333),
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                datetime,
                style: MITITextStyle.gameTimeCardMStyle.copyWith(
                  color: const Color(0xff999999),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      address,
                      style: MITITextStyle.gameTimeCardMStyle.copyWith(
                        color: const Color(0xff999999),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Text(
                      '₩ $fee',
                      style: MITITextStyle.feeStyle.copyWith(
                        color: const Color(0xff4065f6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
