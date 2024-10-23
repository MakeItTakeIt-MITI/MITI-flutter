import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/game/model/game_payment_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/kakaopay/error/pay_error.dart';
import 'package:miti/kakaopay/model/pay_model.dart';
import 'package:miti/kakaopay/provider/pay_provider.dart';
import 'package:miti/report/model/agreement_policy_model.dart';
import 'package:miti/report/provider/report_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../auth/view/signup/signup_screen.dart';
import '../../common/view/operation_term_screen.dart';
import '../../kakaopay/view/approval_screen.dart';
import '../../kakaopay/view/payment_screen.dart';
import '../component/skeleton/game_payment_skeleton.dart';
import '../error/game_error.dart';
import 'game_create_complete_screen.dart';
import 'game_create_screen.dart';
import 'game_detail_screen.dart';
import 'package:collection/collection.dart';

class GamePaymentScreen extends ConsumerStatefulWidget {
  static String get routeName => 'paymentInfo';
  final int gameId;

  const GamePaymentScreen({super.key, required this.gameId});

  @override
  ConsumerState<GamePaymentScreen> createState() => _GamePaymentScreenState();
}

class _GamePaymentScreenState extends ConsumerState<GamePaymentScreen> {
  late Throttle<bool> _throttler;
  late PaymentMethodType type;

  @override
  void initState() {
    super.initState();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: false,
      checkEquality: true,
    );
    _throttler.values.listen((bool s) {
      onPay(ref, context, type);
    });
  }

  Widget getDivider() {
    return Container(
      height: 4.h,
      color: MITIColor.gray800,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(paymentProvider(gameId: widget.gameId));
    GamePaymentModel? model;
    if (result is ResponseModel<GamePaymentModel>) {
      model = result.data!;
    }
    final fee = model?.payment_information.final_payment_amount;
    type = fee != null && fee == 0
        ? PaymentMethodType.empty_pay
        : PaymentMethodType.kakao_pay;

    return Scaffold(
      backgroundColor: MITIColor.gray750,
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          bool validCheckBox = true;

          final result = ref.watch(agreementPolicyProvider(
              type: AgreementRequestType.game_participation));
          final isCheckBoxes = ref.watch(
              gameParticipationFormProvider(gameId: widget.gameId, type: type)
                  .select((s) => s.isCheckBoxes));
          if (result is ResponseListModel<AgreementPolicyModel>) {
            final model = (result).data!;
            for (int i = 0; i < model.length; i++) {
              if (model[i].is_required && !isCheckBoxes[i]) {
                validCheckBox = false;
                break;
              }
            }
          }

          final valid = fee == null || fee != 0
              ? ref.watch(checkProvider(1)) && validCheckBox
              : validCheckBox;
          return BottomButton(
            button: TextButton(
              onPressed: valid
                  ? () async {
                      _throttler.setValue(true);
                    }
                  : () {},
              style: TextButton.styleFrom(
                fixedSize: Size(double.infinity, 48.h),
                backgroundColor: valid ? MITIColor.primary : MITIColor.gray700,
              ),
              child: Text(
                fee != null && fee == 0 ? '참여하기' : '결제하기',
                style: MITITextStyle.btnTextBStyle.copyWith(
                  color: valid ? MITIColor.gray800 : MITIColor.gray50,
                ),
              ),
            ),
          );
        },
      ),
      body: NestedScrollView(
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '경기 결제 정보',
              backgroundColor: MITIColor.gray750,
            ),
          ];
        }),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result =
                      ref.watch(paymentProvider(gameId: widget.gameId));
                  if (result is LoadingModel) {
                    return SingleChildScrollView(
                        child: GamePaymentSkeleton(
                      type: AgreementRequestType.game_participation,
                      gameId: widget.gameId,
                      payType: type,
                    ));
                  } else if (result is ErrorModel) {
                    GameError.fromModel(model: result).responseError(
                        context, GameApiType.getPaymentInfo, ref);
                    return Text('에러');
                  }

                  final model =
                      (result as ResponseModel<GamePaymentModel>).data!;
                  final visiblePay = model
                          .payment_information.payment_amount.game_fee_amount !=
                      0;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SummaryComponent.fromPaymentModel(model: model),
                        getDivider(),
                        PaymentComponent.fromModel(
                            model: model.payment_information),
                        Visibility(
                            visible: visiblePay,
                            child: Column(
                              children: [
                                getDivider(),
                                const PayWayButton(),
                              ],
                            )),
                        getDivider(),
                        const PaymentAndRefundPolicyComponent(
                          title: '결제 및 환불 정책',
                        ),
                        getDivider(),
                        PaymentCheckForm(
                          type: AgreementRequestType.game_participation,
                          gameId: widget.gameId,
                          payType: type,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onPay(
      WidgetRef ref, BuildContext context, PaymentMethodType type) async {
    final result = await ref
        .read(readyPayProvider(gameId: widget.gameId, type: type).future);
    if (context.mounted) {
      if (result is ErrorModel) {
        PayError.fromModel(model: result)
            .responseError(context, PayApiType.ready, ref);
      } else {
        switch (type) {
          case PaymentMethodType.kakao_pay:
            final model = (result as ResponseModel<PayBaseModel>).data!;
            model as PayReadyModel;
            // log('model = ${model.runtimeType}');

            final pathParameters = {'gameId': widget.gameId.toString()};
            final queryParameters = {
              'redirectUrl': model.next_redirect_mobile_url
            };
            context.goNamed(
              PaymentScreen.routeName,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
            );
            break;
          case PaymentMethodType.empty_pay:
            log("무료 경기 참여 완료");
            Map<String, String> pathParameters = {
              'gameId': widget.gameId.toString()
            };
            const GameCompleteType extra = GameCompleteType.payment;

            context.goNamed(
              GameCompleteScreen.routeName,
              pathParameters: pathParameters,
              extra: extra,
            );
            break;
        }
      }
    }
  }
}

class PaymentCheckForm extends ConsumerStatefulWidget {
  final int gameId;
  final PaymentMethodType? payType;
  final AgreementRequestType type;

  const PaymentCheckForm({
    super.key,
    required this.gameId,
    this.payType,
    required this.type,
  });

  @override
  ConsumerState<PaymentCheckForm> createState() => PaymentCheckFormState();
}

class PaymentCheckFormState extends ConsumerState<PaymentCheckForm> {
  List<bool> isCheckBoxes = [false, false];

  void onCheck(WidgetRef ref, int idx) {
    bool allChecked = false;
    if (widget.type == AgreementRequestType.game_participation) {
      allChecked = !ref
          .read(gameParticipationFormProvider(
                  gameId: widget.gameId, type: widget.payType!)
              .notifier)
          .onCheck(idx)
          .contains(false);
    } else {
      allChecked = !ref
          .read(gameRefundFormProvider.notifier)
          .onCheck(idx)
          .contains(false);
    }

    ref.read(checkProvider(2).notifier).update((state) => allChecked);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(agreementPolicyProvider(type: widget.type));
    if (result is LoadingModel) {
      return Container();
    } else if (result is ErrorModel) {
      return Container();
    }
    final model = (result as ResponseListModel<AgreementPolicyModel>).data!;
    if (widget.payType != null) {
      final payForm = ref.watch(gameParticipationFormProvider(
          gameId: widget.gameId, type: widget.payType!));
      isCheckBoxes = payForm.isCheckBoxes;
    } else {
      final payForm = ref.watch(gameRefundFormProvider);
      isCheckBoxes = payForm.isCheckBoxes;
    }

    final checkBoxes = model.mapIndexed((idx, e) {
      return CustomCheckBox(
          title: '${e.is_required ? '[필수] ' : '[선택] '} ${e.policy.name}',
          textStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray200),
          check: isCheckBoxes[idx],
          hasDetail: e.is_required,
          showDetail: () {
            showDialog(
                context: context,
                barrierColor: MITIColor.gray800,
                builder: (context) {
                  return OperationTermScreen(
                    title: model[idx].policy.name,
                    desc: model[idx].policy.content,
                    onPressed: () {
                      if (!isCheckBoxes[idx]) {
                        onCheck(ref, idx);
                      }
                      context.pop();
                    },
                  );
                });
          },
          onTap: () {
            onCheck(ref, idx);
          });
    }).toList();
    return Padding(
      padding:
          EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 28.h),
      child: CheckBoxFormV2(
        checkBoxes: checkBoxes,
        allTap: () {
          ref.read(checkProvider(2).notifier).update((state) => !state);
          final List<bool> isCheckBoxes = List.generate(
              result.data!.length, (e) => ref.read(checkProvider(2)));
          if (widget.type == AgreementRequestType.game_participation) {
            ref
                .read(gameParticipationFormProvider(
                        gameId: widget.gameId, type: widget.payType!)
                    .notifier)
                .update(isCheckBoxes: isCheckBoxes);
          } else {
            ref
                .read(gameRefundFormProvider.notifier)
                .update(isCheckBoxes: isCheckBoxes);
          }
        },
      ),
    );
  }
}

class PaymentComponent extends StatelessWidget {
  final String game_fee_amount;
  final String commission_amount;
  final String vat_amount;
  final String totalAmount;
  final String promotion_amount;
  final String final_payment_amount;

  const PaymentComponent(
      {super.key,
      required this.game_fee_amount,
      required this.commission_amount,
      required this.vat_amount,
      required this.totalAmount,
      required this.promotion_amount,
      required this.final_payment_amount});

  factory PaymentComponent.fromModel({required PaymentModel model}) {
    final payment = model.payment_amount;
    final game_fee_amount =
        NumberFormat.decimalPattern().format(payment.game_fee_amount);
    final miti_commission_amount =
        NumberFormat.decimalPattern().format(payment.commission_amount);
    final vat_amount = NumberFormat.decimalPattern().format(payment.vat_amount);
    final totalAmount =
        NumberFormat.decimalPattern().format(payment.total_amount);
    final promotion_amount = NumberFormat.decimalPattern()
        .format(model.discount_amount.promotion_amount);
    final final_payment_amount =
        NumberFormat.decimalPattern().format(model.final_payment_amount);
    return PaymentComponent(
      game_fee_amount: game_fee_amount,
      commission_amount: miti_commission_amount,
      vat_amount: vat_amount,
      totalAmount: totalAmount,
      promotion_amount: promotion_amount,
      final_payment_amount: final_payment_amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '결제 및 할인 정보',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          getPayment(
              title: '경기 참여 비용',
              fee: game_fee_amount == '0' ? '무료' : '₩ $game_fee_amount'),
          Visibility(
              visible: final_payment_amount != '0',
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  getPayment(title: '결제 수수료', fee: '₩ $commission_amount'),
                  // SizedBox(height: 12.h),
                  // getPayment(
                  //     title: '프로모션 할인',
                  //     fee: promotion_amount,
                  //     color: MITIColor.error),
                ],
              )),
          getDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 결제 금액',
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              Text(
                final_payment_amount == '0' ? '무료' : '₩ $final_payment_amount',
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.primary,
                ),
              ),
            ],
          ),
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
          style: MITITextStyle.sm.copyWith(
            color: MITIColor.gray100,
          ),
        ),
        Text(
          fee,
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

class PayWayButton extends ConsumerWidget {
  const PayWayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(checkProvider(1));
    return Padding(
      padding:
          EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '결제 수단',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 44.h,
            child: TextButton(
              onPressed: () {
                ref.read(checkProvider(1).notifier).update((state) => !state);
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    selected ? const Color(0xFFFFF100) : MITIColor.gray800,
                fixedSize: Size(double.infinity, 44.h),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color:
                        selected ? const Color(0xFFFFF100) : MITIColor.gray700,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                ),
              ),
              child: SvgPicture.asset(
                AssetUtil.getAssetPath(type: AssetType.icon, name: 'kakaopay'),
                colorFilter: ColorFilter.mode(
                    selected
                        ? const Color(0xFF040000)
                        : const Color(0xFFFFF100),
                    BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentAndRefundPolicyComponent extends StatelessWidget {
  final String title;

  const PaymentAndRefundPolicyComponent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    List<String> contents = [
      '• 경기 시작 48시간 전 : 무료취소',
      '• 경기 시작 24시간 전 : 80% 환급',
      '• 경기 시작 12시간 전 : 50% 환급',
      '• 경기 시작 6시간 전 : 40% 환급',
      '• 경기 시작 2시간 전 : 20% 환급',
      '경기 시작 2시간 이내인 경기에 참여할 경우 참여 취소가 불가능하니 유의해주세요!',
    ];

    return Padding(
      padding:
          EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            '참여 취소 환불 수수료 정책',
            style: MITITextStyle.smSemiBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 12.h),
          ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (_, idx) {
                return Text(
                  contents[idx],
                  style: MITITextStyle.xxsmLight150.copyWith(
                    height: 1,
                    color: contents.length - 1 != idx
                        ? MITIColor.gray100
                        : MITIColor.error,
                  ),
                );
              },
              separatorBuilder: (_, idx) => SizedBox(
                    height: 8.h,
                  ),
              itemCount: contents.length),
        ],
      ),
    );
  }
}
