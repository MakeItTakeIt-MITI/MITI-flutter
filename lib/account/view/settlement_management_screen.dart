import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/provider/account_provider.dart';
import 'package:miti/account/view/bank_transfer_form_screen.dart';
import 'package:miti/account/view/settlement_screen.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/skeleton.dart';
import 'package:miti/common/component/sliver_delegate.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/dispose_sliver_pagination_list_view.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../component/skeleton/bank_transfer_skeleton.dart';
import '../component/skeleton/settlement_skeleton.dart';
import '../model/account_model.dart';
import '../model/transfer_model.dart';
import '../provider/account_pagination_provider.dart';
import '../component/bank_transfer_card.dart';

class SettlementManagementScreen extends StatefulWidget {
  static String get routeName => 'settlementManagement';

  const SettlementManagementScreen({super.key});

  @override
  State<SettlementManagementScreen> createState() =>
      _SettlementManagementScreenState();
}

class _SettlementManagementScreenState extends State<SettlementManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray900,
      body: NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (_, __) {
            return [
              const DefaultAppBar(
                isSliver: true,
                title: '정산 관리',
                hasBorder: false,
              ),
              SliverPersistentHeader(
                delegate: SliverAppBarDelegate(
                    child: const _AccountInfo(), height: 100),
                pinned: true,
              ),
              SliverPersistentHeader(
                delegate: SliverAppBarDelegate(
                    child: Container(
                  color: MITIColor.gray800,
                  child: TabBar(
                    indicatorWeight: 2.w,
                    unselectedLabelColor: MITIColor.gray500,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: MITIColor.gray200,
                    labelStyle:
                        MITITextStyle.xxsm.copyWith(color: MITIColor.gray200),
                    controller: _tabController,
                    dividerColor: MITIColor.gray500,
                    onTap: (idx) {
                      _tabController.animateTo(idx);
                    },
                    tabs: [
                      Tab(
                        height: 44.h,
                        child: const Text('경기별 정산 내역'),
                      ),
                      Tab(
                        height: 44.h,
                        child: const Text('정산금 이체 내역'),
                      ),
                    ],
                  ),
                )),
                pinned: true,
              )
            ];
          },
          body: TabBarView(controller: _tabController, children: const [
            _SettlementHistoryComponent(),
            _TransferHistoryComponent(),
          ])),
    );
  }
}

class _SettlementHistoryComponent extends StatefulWidget {
  const _SettlementHistoryComponent({
    super.key,
  });

  @override
  State<_SettlementHistoryComponent> createState() =>
      _SettlementHistoryComponentState();
}

class _SettlementHistoryComponentState
    extends State<_SettlementHistoryComponent> {
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final userId = ref.watch(authProvider)!.id!;
            return DisposeSliverPaginationListView(
                provider:
                    settlementPageProvider(PaginationStateParam(path: userId)),
                itemBuilder: (BuildContext context, int index, Base pModel) {
                  final model = pModel as SettlementModel;

                  return SettlementCard.fromModel(
                    model: model,
                  );
                },
                skeleton: const SettlementListSkeleton(),
                controller: scrollController,
                separateSize: 4,
                emptyWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '정산 내역이 없습니다.',
                      style: MITITextStyle.xxl140.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '경기를 운영하고 정산금을 수령해 보세요!',
                      style: MITITextStyle.sm150
                          .copyWith(color: MITIColor.gray300),
                    ),
                  ],
                ));
          },
        )
      ],
    );
  }
}

class _TransferHistoryComponent extends StatefulWidget {
  const _TransferHistoryComponent({super.key});

  @override
  State<_TransferHistoryComponent> createState() =>
      _TransferHistoryComponentState();
}

class _TransferHistoryComponentState extends State<_TransferHistoryComponent> {
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final userId = ref.watch(authProvider)!.id!;
            return DisposeSliverPaginationListView(
                provider: bankTransferPageProvider(
                    PaginationStateParam(path: userId)),
                itemBuilder: (BuildContext context, int index, Base pModel) {
                  final model = pModel as TransferModel;
                  return BankTransferCard.fromModel(
                    model: model,
                  );
                },
                skeleton: const BankTransferListSkeleton(),
                controller: scrollController,
                separateSize: 4,
                emptyWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '이체 내역이 없습니다.',
                      style: MITITextStyle.xxl140.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '경기를 운영하고 정산금을 수령해 보세요!',
                      style: MITITextStyle.sm150
                          .copyWith(color: MITIColor.gray300),
                    ),
                  ],
                ));
          },
        ),
      ],
    );
  }
}

class _AccountInfo extends ConsumerWidget {
  const _AccountInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: MITIColor.gray800,
      padding: EdgeInsets.symmetric(horizontal: 21.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "이체 가능한 금액",
                  style: MITITextStyle.xxsm.copyWith(color: MITIColor.gray100),
                ),
                SizedBox(height: 12.h),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return Row(
                      children: [
                        Consumer(
                          builder: (BuildContext context, WidgetRef ref,
                              Widget? child) {
                            final result = ref.watch(accountProvider);
                            if (result is LoadingModel) {
                              return const BoxSkeleton(width: 94, height: 24);
                            } else if (result is ErrorModel) {
                              return Text("error");
                            }
                            final model =
                                (result as ResponseModel<AccountDetailModel>)
                                    .data!;
                            final amount = NumberUtil.format(
                                model.requestableTransferAmount.toString());
                            return Text(
                              amount,
                              style: MITITextStyle.xxl
                                  .copyWith(color: MITIColor.gray100),
                            );
                          },
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '원',
                          style: MITITextStyle.sm
                              .copyWith(color: MITIColor.gray100),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              context.pushNamed(BankTransferFormScreen.routeName);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: MITIColor.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '이체하기',
                style:
                    MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray800),
              ),
            ),
          )
        ],
      ),
    );
  }
}
