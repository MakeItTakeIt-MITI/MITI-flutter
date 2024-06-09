import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/provider/router_provider.dart';
import '../error/game_error.dart';
import '../model/game_payment_model.dart';

class GameRefundScreen extends StatefulWidget {
  static String get routeName => 'gameRefund';
  final int participationId;
  final int gameId;
  final int bottomIdx;

  const GameRefundScreen(
      {super.key,
      required this.participationId,
      required this.gameId,
      required this.bottomIdx});

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
    return Container(
      height: 5.h,
      color: const Color(0xFFF8F8F8),
    );
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
            const DefaultAppBar(
              isSliver: true,
              title: '참여 경기 취소',
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _RefundInfoComponent(
                          gameId: widget.gameId,
                          participationId: widget.participationId,
                        ),
                        getDivider(),
                        const _CommissionInfoComponent(),
                      ],
                    ),
                  ),
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final valid = ref.watch(checkProvider(1));
                      return Positioned(
                        bottom: 8.h,
                        right: 16.w,
                        left: 16.w,
                        child: TextButton(
                          onPressed: valid
                              ? () async {
                                  await refund(ref, context);
                                }
                              : () {},
                          style: TextButton.styleFrom(
                            fixedSize: Size(double.infinity, 48.h),
                            backgroundColor: valid
                                ? const Color(0xFF4065F5)
                                : const Color(0xffE8E8E8),
                          ),
                          child: Text(
                            '참여 취소하기',
                            style: MITITextStyle.btnTextBStyle.copyWith(
                              color: valid
                                  ? Colors.white
                                  : const Color(0xff969696),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refund(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(gameCancelProvider(
            gameId: widget.gameId, participationId: widget.participationId)
        .future);
    if (result is ErrorModel) {
    } else {
      ref
          .read(gameDetailProvider(gameId: widget.gameId).notifier)
          .get(gameId: widget.gameId);
      if (context.mounted) {
        final extra = CustomDialog(
          title: '경기 참여 취소',
          content: '경기 참여가 정상적으로 취소되었습니다.',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            Map<String, String> pathParameters = {
              'gameId': widget.gameId.toString()
            };
            final Map<String, String> queryParameters = {
              'bottomIdx': widget.bottomIdx.toString()
            };
            context.goNamed(
              GameDetailScreen.routeName,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
            );
          },
        );
        context.pushNamed(DialogPage.routeName, extra: extra);
      }
    }
  }
}

class _RefundInfoComponent extends ConsumerWidget {
  final int gameId;
  final int participationId;

  const _RefundInfoComponent({
    super.key,
    required this.gameId,
    required this.participationId,
  });

  String formatFee(int fee) {
    return NumberFormat.decimalPattern().format(fee);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(
        refundInfoProvider(gameId: gameId, participationId: participationId));
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      GameError.fromModel(model: result)
          .responseError(context, GameApiType.getRefundInfo, ref);
      return Text('에러');
    }
    final model = (result as ResponseModel<RefundModel>).data!;
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '환불 정보',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 14.h),
          getPayment(
              title: '경기 참여비',
              fee: formatFee(model.payment_amount.total_amount)),
          getDivider(),
          getPayment(
              title: '결제 수수료', fee: formatFee(model.commission_amount.payment_commission_amount)),
          SizedBox(height: 12.h),
          getPayment(
              title: '참여 취소 수수료',
              fee: formatFee(
                  model.commission_amount.cancelation_commission_amount)),
          getDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 환불 금액',
                style: MITITextStyle.gameTitleMainStyle.copyWith(
                  color: const Color(0xFF222222),
                ),
              ),
              Text(
                '₩ ${formatFee(model.final_refund_amount)}',
                style: MITITextStyle.feeStyle.copyWith(
                  color: const Color(0xFFF45858),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Row getPayment({required String title, required String fee, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.plainTextMStyle.copyWith(
            color: color ?? const Color(0xFF666666),
          ),
        ),
        Text(
          '₩ $fee',
          style: MITITextStyle.feeSStyle.copyWith(
            color: color ?? const Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Divider getDivider() {
    return Divider(
      color: const Color(0xFFE8E8E8),
      height: 25.h,
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
