import 'dart:developer';

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
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/kakaopay/error/pay_error.dart';
import 'package:miti/kakaopay/model/pay_model.dart';
import 'package:miti/kakaopay/provider/pay_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../auth/view/signup/signup_screen.dart';
import '../../kakaopay/view/payment_screen.dart';
import '../error/game_error.dart';
import 'game_create_screen.dart';
import 'game_detail_screen.dart';

class GamePaymentScreen extends StatelessWidget {
  static String get routeName => 'paymentInfo';
  final int gameId;

  const GamePaymentScreen({super.key, required this.gameId});

  Widget getDivider() {
    return Container(
      height: 4.h,
      color: MITIColor.gray800,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray750,
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final result = ref.watch(paymentProvider(gameId: gameId));
          GamePaymentModel? model;
          if (result is ResponseModel<GamePaymentModel>) {
            model = result.data!;
          }
          final fee = model?.payment_information.final_payment_amount;
          final PaymentMethodType type = fee != null && fee == 0
              ? PaymentMethodType.empty_pay
              : PaymentMethodType.kakao_pay;
          final valid = fee == null || fee != 0
              ? ref.watch(checkProvider(1)) && ref.watch(checkProvider(2))
              : ref.watch(checkProvider(2));
          return BottomButton(
            button: TextButton(
              onPressed: valid
                  ? () async {
                      await onPay(ref, context, type);
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
              title: '경기 상세 정보',
              backgroundColor: MITIColor.gray750,
            ),
          ];
        }),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result = ref.watch(paymentProvider(gameId: gameId));
                  if (result is LoadingModel) {
                    return CircularProgressIndicator();
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
                        const _PaymentAndRefundPolicyComponent(),
                        getDivider(),
                        const _PaymentCheckForm(),
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
    final result =
        await ref.read(readyPayProvider(gameId: gameId, type: type).future);
    if (context.mounted) {
      if (result is ErrorModel) {
        PayError.fromModel(model: result)
            .responseError(context, PayApiType.ready, ref);
      } else {
        switch (type) {
          case PaymentMethodType.kakao_pay:
            result as ResponseModel<PayReadyModel>;
            final pathParameters = {'gameId': gameId.toString()};
            final queryParameters = {
              'redirectUrl': result.data!.next_redirect_mobile_url
            };
            context.pushNamed(
              PaymentScreen.routeName,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
            );
            break;
          case PaymentMethodType.empty_pay:
            log("무료 경기 참여 완료");
            context.goNamed(CourtMapScreen.routeName);
            break;
        }
      }
    }
  }
}

class _PaymentCheckForm extends ConsumerStatefulWidget {
  const _PaymentCheckForm({super.key});

  @override
  ConsumerState<_PaymentCheckForm> createState() => _PaymentCheckFormState();
}

class _PaymentCheckFormState extends ConsumerState<_PaymentCheckForm> {
  bool check1 = false;
  bool check2 = false;

  CustomCheckBox checkBox(
    BuildContext context, {
    required String title,
    required bool check,
    required VoidCallback onTap,
    required VoidCallback showDetail,
  }) {
    return CustomCheckBox(
      title: title,
      textStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray200),
      check: check,
      hasDetail: true,
      showDetail: showDetail,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 28.h),
      child: CheckBoxFormV2(
        checkBoxes: [
          checkBox(context, title: '[필수] MITI 결제 및 환불정책 동의', check: check1,
              onTap: () {
            setState(() {
              check1 = !check1;
              ref
                  .read(checkProvider(2).notifier)
                  .update((state) => check1 && check2);
            });
          }, showDetail: () {
            showDialog(
                context: context,
                barrierColor: MITIColor.gray800,
                builder: (context) {
                  return OperationTermScreen(
                    title: '경기 운영 약관',
                    desc:
                        '본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.',
                    onPressed: () {
                      setState(() {
                        check1 = true;
                        ref
                            .read(checkProvider(2).notifier)
                            .update((state) => check1 && check2);
                      });

                      context.pop();
                    },
                  );
                });
          }),
          checkBox(context, title: '[필수] 경기 참여 및 이용 정책', check: check2,
              onTap: () {
            setState(() {
              check2 = !check2;
              ref
                  .read(checkProvider(2).notifier)
                  .update((state) => check1 && check2);
            });
          }, showDetail: () {
            showDialog(
                context: context,
                barrierColor: MITIColor.gray800,
                builder: (context) {
                  return OperationTermScreen(
                    title: '경기 운영 약관',
                    desc:
                        '본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.',
                    onPressed: () {
                      setState(() {
                        check2 = true;
                        ref
                            .read(checkProvider(2).notifier)
                            .update((state) => check1 && check2);
                      });

                      context.pop();
                    },
                  );
                });
          })
        ],
        allTap: () {
          ref.read(checkProvider(2).notifier).update((state) => !state);
          setState(() {
            check1 = check2 = ref.read(checkProvider(2));
          });
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
              fee: game_fee_amount == '0' ? '무료' : game_fee_amount),
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

class _PaymentAndRefundPolicyComponent extends StatelessWidget {
  const _PaymentAndRefundPolicyComponent({super.key});

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
            '결제 및 환불 정책',
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
