import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/account/param/account_param.dart';
import 'package:miti/account/provider/account_pagination_provider.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/game/component/game_state_label.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/custom_drop_down_button.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/component/dispose_sliver_pagination_list_view.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../model/bank_model.dart';

class BankTransferScreen extends ConsumerStatefulWidget {
  static String get routeName => 'bankTransfer';
  final int bottomIdx;

  const BankTransferScreen({
    super.key,
    required this.bottomIdx,
  });

  @override
  ConsumerState<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends ConsumerState<BankTransferScreen> {
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
    final provider =
        bankTransferPageProvider(PaginationStateParam(path: userId));
    ref.read(provider.notifier).paginate(
          path: userId,
          forceRefetch: true,
          param: BankTransferPaginationParam(
            status: status,
          ),
          paginationParams: const PaginationParam(page: 1),
        );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      '송금 완료',
      '대기중',
      '전체 보기',
    ];
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '송금 내역',
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
                      provider: bankTransferPageProvider(
                          PaginationStateParam(path: userId)),
                      itemBuilder:
                          (BuildContext context, int index, Base pModel) {
                        final model = pModel as BankModel;
                        return _BankTransferCard.fromModel(
                          model: model,
                        );
                      },
                      skeleton: Container(),
                      controller: _scrollController,
                      separateSize: 0,
                      emptyWidget: getEmptyWidget());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  BankType? getStatus(String? value) {
    switch (value) {
      case '대기중':
        return BankType.waiting;
      case '송금 완료':
        return BankType.completed;
      default:
        return null;
    }
  }

  void changeDropButton(String? value, WidgetRef ref) {
    final userId = ref.read(authProvider)!.id!;
    ref.read(dropDownValueProvider.notifier).update((state) => value);
    final status = getStatus(value!);
    log('status = ${status}');
    final provider =
        bankTransferPageProvider(PaginationStateParam(path: userId));
    ref.read(provider.notifier).paginate(
          path: userId,
          forceRefetch: true,
          param: BankTransferPaginationParam(
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

class _BankTransferCard extends ConsumerWidget {
  final int id;
  final String amount;
  final String account_bank;
  final String account_holder;
  final String account_number;
  final BankType status;
  final String created_at;

  const _BankTransferCard(
      {super.key,
      required this.id,
      required this.amount,
      required this.account_bank,
      required this.account_holder,
      required this.account_number,
      required this.status,
      required this.created_at});

  factory _BankTransferCard.fromModel({required BankModel model}) {
    return _BankTransferCard(
      amount: NumberUtil.format(model.amount.toString()),
      account_bank: model.account_bank,
      account_holder: model.account_holder,
      account_number: model.account_number,
      status: model.status,
      created_at: DateTimeUtil.parseMd(dateTime: model.created_at),
      id: model.id,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedProvider);
    return InkWell(
      onTap: () {
        final value = ref.read(selectedProvider);
        if (value == id) {
          ref.read(selectedProvider.notifier).update((state) => null);
        } else {
          ref.read(selectedProvider.notifier).update((state) => id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal:
                BorderSide(color: const Color(0xFFE8E8E8), width: 0.5.w),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 58.w,
                    child: Text(
                      created_at,
                      style: MITITextStyle.dropdownChoicesStyle.copyWith(
                        color: const Color(0xff999999),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 130.w,
                    child: Text(
                      '₩ $amount',
                      style: MITITextStyle.feeStyle.copyWith(
                        color: const Color(0xff4065f6),
                      ),
                    ),
                  ),
                  BankLabel(
                    bankType: status,
                  ),
                ],
              ),
              if (selected == id) SizedBox(height: 20.h),
              if (selected == id)
                Column(
                  children: [
                    getInfo('예금주', account_holder),
                    SizedBox(height: 8.h),
                    getInfo('입금 은행', account_bank),
                    SizedBox(height: 8.h),
                    getInfo('계좌번호', account_number),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Row getInfo(String title, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.plainTextMStyle.copyWith(
            color: const Color(0xff666666),
          ),
        ),
        Text(
          content,
          style: MITITextStyle.plainTextMStyle.copyWith(
            color: const Color(0xff333333),
          ),
        ),
      ],
    );
  }
}
