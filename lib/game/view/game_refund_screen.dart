import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/defalut_flashbar.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/provider/router_provider.dart';
import '../error/game_error.dart';
import '../model/game_payment_model.dart';
import '../model/v2/payment/participation_refund_info_response.dart';
import '../model/v2/payment/payment_refund_amount.dart';
import 'game_create_screen.dart';
import 'game_payment_screen.dart';

class GameRefundScreen extends StatefulWidget {
  static String get routeName => 'gameRefund';
  final int participationId;
  final int gameId;

  const GameRefundScreen({
    super.key,
    required this.participationId,
    required this.gameId,
  });

  @override
  State<GameRefundScreen> createState() => _GameRefundScreenState();
}

class _GameRefundScreenState extends State<GameRefundScreen> {
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

  Widget getDivider() {
    return SliverToBoxAdapter(
      child: Container(
        height: 4.h,
        color: MITIColor.gray800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray750,
      bottomNavigationBar: BottomButton(
        button: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final valid = ref.watch(checkProvider(2));
            return TextButton(
              onPressed: valid
                  ? () async {
                      showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return BottomDialog(
                              hasPop: true,
                              title: '경기 참여 취소',
                              content:
                                  '경기 참여 취소 시, 결제 수수료 및 참여 취소 수수료를 제외한\n금액만 환불됩니다. 그래도 경기 참여를 취소하시겠습니까?',
                              btn: Consumer(
                                builder: (BuildContext context, WidgetRef ref,
                                    Widget? child) {
                                  return TextButton(
                                    onPressed: () async {
                                      await refund(ref, context);
                                    },
                                    style: TextButton.styleFrom(
                                      fixedSize: Size(double.infinity, 48.h),
                                      backgroundColor: MITIColor.error,
                                    ),
                                    child: Text(
                                      "참여 취소하기",
                                      style: MITITextStyle.mdBold.copyWith(
                                        color: MITIColor.gray100,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          });
                    }
                  : () {},
              style: TextButton.styleFrom(
                fixedSize: Size(double.infinity, 48.h),
                backgroundColor: valid ? MITIColor.error : MITIColor.gray700,
              ),
              child: Text(
                '참여 취소하기',
                style: MITITextStyle.btnTextBStyle.copyWith(
                  color: valid ? MITIColor.gray100 : MITIColor.gray50,
                ),
              ),
            );
          },
        ),
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '경기 환불 정보',
              backgroundColor: MITIColor.gray750,
            ),
          ];
        },
        body: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final result = ref.watch(refundInfoProvider(
                gameId: widget.gameId,
                participationId: widget.participationId));
            if (result is LoadingModel) {
              return Container();
            } else if (result is ErrorModel) {
              WidgetsBinding.instance.addPostFrameCallback((s) {
                GameError.fromModel(model: result)
                    .responseError(context, GameApiType.getRefundInfo, ref);
              });

              return const SliverToBoxAdapter(child: Text('에러'));
            }
            final model =
                (result as ResponseModel<ParticipationRefundInfoResponse>)
                    .data!;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: SummaryComponent.fromRefundModel(model: model.game)),
                getDivider(),
                _RefundInfoComponent(
                  model: model.refundInfo,
                ),
                getDivider(),
                const SliverToBoxAdapter(
                  child: PaymentAndRefundPolicyComponent(
                    title: '참여 취소 수수료 규정',
                    isPayment: false,
                  ),
                ),
                getDivider(),
                SliverToBoxAdapter(
                  child: PaymentCheckForm(
                    type: AgreementRequestType.participation_refund,
                    gameId: widget.gameId,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> refund(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(gameCancelProvider(
            gameId: widget.gameId, participationId: widget.participationId)
        .future);
    if (result is ErrorModel) {
      if (context.mounted) {
        context.pop();
        GameError.fromModel(model: result)
            .responseError(context, GameApiType.participationCancel, ref);
      }
    } else {
      await ref
          .read(gameDetailProvider(gameId: widget.gameId).notifier)
          .get(gameId: widget.gameId);
      if (context.mounted) {
        Map<String, String> pathParameters = {
          'gameId': widget.gameId.toString()
        };
        context.goNamed(
          GameDetailScreen.routeName,
          pathParameters: pathParameters,
        );
        Future.delayed(const Duration(milliseconds: 100), () {
          FlashUtil.showFlash(context, '경기 참여가 취소되었습니다.');
        });
      }
    }
  }
}

class _RefundInfoComponent extends ConsumerWidget {
  final PaymentRefundAmount model;

  const _RefundInfoComponent({
    super.key,
    required this.model,
  });

  String formatFee(int fee) {
    return NumberFormat.decimalPattern().format(fee);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '환불 정보',
              style: MITITextStyle.mdBold.copyWith(
                color: MITIColor.gray100,
              ),
            ),
            SizedBox(height: 20.h),
            getPayment(
                title: '경기 참여 비용',
                fee: formatFee(model.paymentAmount.totalAmount)),
            SizedBox(height: 12.h),
            getPayment(
              title: '결제 수수료',
              fee: formatFee(
                  model.refundCommissionAmount.paymentCommissionAmount),
              color: MITIColor.gray100,
            ),
            SizedBox(height: 12.h),
            getPayment(
              title: '참여 취소 수수료',
              fee: formatFee(
                  model.refundCommissionAmount.cancelationCommissionAmount),
              color: MITIColor.gray100,
            ),
            getDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 환불 금액',
                  style: MITITextStyle.mdBold.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                Text(
                  '₩ ${formatFee(model.finalRefundAmount)}',
                  style: MITITextStyle.mdBold.copyWith(
                    color: MITIColor.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Row getPayment({required String title, required String fee, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.sm.copyWith(
            color: MITIColor.gray100,
          ),
        ),
        Text(
          color != null ? '- ₩ $fee' : '₩ $fee',
          style: MITITextStyle.sm.copyWith(
            color: color ?? MITIColor.gray100,
          ),
        ),
      ],
    );
  }

  Divider getDivider() {
    return Divider(
      color: MITIColor.gray700,
      height: 41.h,
    );
  }
}

final checkProvider =
    StateProvider.family.autoDispose<bool, int>((ref, id) => false);

class _CommissionInfoComponent extends ConsumerWidget {
  const _CommissionInfoComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(checkProvider(1));
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '참여 취소 수수료 규정',
            style: MITITextStyle.sectionTitleStyle,
          ),
          SizedBox(height: 20.h),
          Text(
            '참여 취소 환불 수수료 정책',
            style: MITITextStyle.sectionSubTitleStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            '• 경기 시작 48시간 전 : 무료취소',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 24시간 전 : 80% 환급',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 12시간 전 : 60% 환급',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 6시간 전 : 40% 환급',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 2시간 전 : 20% 환급',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 2시간 이내인 경기에 참여할 경우 참여 취소가 불가능하니 유의해주세요!',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xffE92C2C),
            ),
          ),
          SizedBox(height: 14.h),
          InkWell(
            onTap: () {
              ref.read(checkProvider(1).notifier).update((state) => !state);
            },
            child: Row(
              children: [
                Text(
                  '위 환불 규정의 동의합니다.',
                  style: MITITextStyle.gameTitleMainStyle.copyWith(
                    color: selected
                        ? const Color(0xff4065f5)
                        : const Color(0xFF666666),
                  ),
                ),
                SizedBox(width: 7.w),
                SvgPicture.asset(
                  'assets/images/icon/system_success.svg',
                  colorFilter: ColorFilter.mode(
                      selected
                          ? const Color(0xFF4065F5)
                          : const Color(0xFF666666),
                      BlendMode.srcIn),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
