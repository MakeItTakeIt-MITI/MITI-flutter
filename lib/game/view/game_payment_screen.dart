import 'dart:convert';
import 'dart:developer';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/payload.dart';
import 'package:collection/collection.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
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
import '../../env/environment.dart';
import '../../kakaopay/param/boot_pay_approve_param.dart';
import '../component/skeleton/game_payment_skeleton.dart';
import '../error/game_error.dart';
import '../model/v2/game/game_participation_payment_detail_response.dart';
import '../model/v2/game/game_participation_payment_response.dart';
import '../model/v2/payment/base_payment_request_response.dart';
import '../model/v2/payment/payment_completed_response.dart';
import 'game_create_complete_screen.dart';
import 'game_detail_screen.dart';

class GamePaymentScreen extends ConsumerStatefulWidget {
  static String get routeName => 'paymentInfo';
  final int gameId;

  const GamePaymentScreen({super.key, required this.gameId});

  @override
  ConsumerState<GamePaymentScreen> createState() => _GamePaymentScreenState();
}

class _GamePaymentScreenState extends ConsumerState<GamePaymentScreen> {
  Payload payload = Payload();
  String webApplicationId = EnvUtil.instance.isProduction
      ? Environment.bootPayJavaScriptKey
      : Environment.bootPayDevJavaScriptKey;
  String androidApplicationId = EnvUtil.instance.isProduction
      ? Environment.bootPayAndroidKey
      : Environment.bootPayDevAndroidKey;
  String iosApplicationId = EnvUtil.instance.isProduction
      ? Environment.bootPayIosKey
      : Environment.bootPayDevIosKey;

  String get applicationId {
    debugPrint('Environment webApplicationId: $webApplicationId');
    debugPrint('Environment androidApplicationId: $androidApplicationId');
    debugPrint('Environment iosApplicationId: $iosApplicationId');
    return Bootpay().applicationId(
        webApplicationId, androidApplicationId, iosApplicationId);
  }

  bool isLoading = false;
  late Throttle<int> _throttler;
  late PaymentMethodType type;

  int throttleCnt = 0;

  @override
  void initState() {
    applicationId;

    super.initState();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) async {
      setState(() {
        isLoading = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
      await onBootPay(ref, context, type);
      setState(() {
        isLoading = false;
      });
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
    GameParticipationPaymentDetailResponse? model;

    if (result is ResponseModel<GameParticipationPaymentDetailResponse>) {
      model = result.data!;
    }

    log('result type = ${result.runtimeType}');
    final fee = model?.paymentInformation.finalPaymentAmount;
    type = model?.isFreeGame == null || model!.isFreeGame
        ? PaymentMethodType.empty_pay
        : PaymentMethodType.kakao;

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

          final valid = validCheckBox;
          return BottomButton(
            button: TextButton(
              onPressed: valid && !isLoading
                  ? () async {
                      _throttler.setValue(throttleCnt + 1);
                    }
                  : () {},
              style: TextButton.styleFrom(
                fixedSize: Size(double.infinity, 48.h),
                backgroundColor:
                    valid && !isLoading ? MITIColor.primary : MITIColor.gray700,
              ),
              child: Text(
                fee != null && fee == 0 ? '참여하기' : '결제하기',
                style: MITITextStyle.btnTextBStyle.copyWith(
                  color: valid && !isLoading
                      ? MITIColor.gray800
                      : MITIColor.gray50,
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

                  final model = (result as ResponseModel<
                          GameParticipationPaymentDetailResponse>)
                      .data!;
                  final visiblePay =
                      model.paymentInformation.paymentAmount.gameFeeAmount != 0;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SummaryComponent.fromPaymentModel(model: model),
                        getDivider(),
                        PaymentComponent.fromModel(
                            model: model.paymentInformation),
                        // Visibility(
                        //     visible: visiblePay,
                        //     child: Column(
                        //       children: [
                        //         getDivider(),
                        //         const PayWayButton(),
                        //       ],
                        //     )),
                        getDivider(),
                        const PaymentAndRefundPolicyComponent(
                          title: '결제 및 환불 정책',
                          isPayment: true,
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

  Future<void> onBootPay(
      WidgetRef ref, BuildContext context, PaymentMethodType type) async {
    final result = await ref
        .read(readyPayProvider(gameId: widget.gameId, type: type).future);
    if (context.mounted) {
      if (result is ErrorModel) {
        PayError.fromModel(model: result)
            .responseError(context, PayApiType.ready, ref);
      } else {
        final payBaseModel = (result as ResponseModel<PayBaseModel>).data!;

        switch (type) {
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
          default:
            final model = payBaseModel as BasePaymentRequestResponse;
            bootpayReqeustDataInit(model);
            goBootpayTest(context);
            break;
        }

        // payload.pg = '나이스페이';
        // payload.method = model.method.name;
        // payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao'];
      }
    }
  }

  bootpayReqeustDataInit(BasePaymentRequestResponse model) {
    // Item item1 = Item();
    // item1.name = "미키 '마우스"; // 주문정보에 담길 상품명
    // item1.qty = 1; // 해당 상품의 주문 수량
    // item1.id = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    // item1.price = 1000; // 상품의 가격
    //
    // List<Item>? itemList = [item1];
    // payload.items = itemList; // 상품정보 배열

    payload.orderName = model.itemName; //결제할 상품명
    payload.price = model.totalAmount.toDouble(); //정기결제시 0 혹은 주석
    payload.taxFree = model.taxFreeAmount.toDouble();
    payload.orderId = model.orderId; //주문번호, 개발사에서 고유값으로 지정해야함

    // User user = User(); // 구매자 정보
    // user.username = model.user.username;
    // user.phone = model.user.phone;

    payload.webApplicationId = webApplicationId; // web application id
    payload.androidApplicationId =
        androidApplicationId; // android application id
    payload.iosApplicationId = iosApplicationId; // ios application id

    // payload.extra?.directCardQuota =1;

    // User user = User(); // 구매자 정보
    // user.username = "사용자 이름";
    // user.email = "user1234@gmail.com";
    // user.area = "서울";
    // user.phone = "010-4033-4678";
    // user.addr = '서울시 동작구 상도로 222';

    Extra extra = Extra(); // 결제 옵션
    // extra.appScheme = 'miti';
    // extra.cardQuota = '3';
    // extra.openType = 'popup';

    // extra.carrier = "SKT,KT,LGT"; //본인인증 시 고정할 통신사명
    // extra.ageLimit = 20; // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능

    // payload.user = user;
    payload.extra = extra;
    payload.extra?.openType = "iframe";
  }

  //버튼클릭시 부트페이 결제요청 실행
  void goBootpayTest(BuildContext context) {
    Bootpay().requestPayment(
      context: context,
      payload: payload,
      // showCloseButton: true,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel: $data');
      },
      onError: (String data) {
        print('------- onError 3: $data');
        if (!kIsWeb) {
          Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        }
      },
      onClose: () {
        print('------- onClose');
        if (!kIsWeb) {
          Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        }

        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirmAsync: (String data) async {
        await approvePay(data, context);
        return false;
      },
      // onConfirm: (String data) {
      //   // Bootpay().transactionConfirm();
      //   /**
      //       1. 바로 승인하고자 할 때
      //       return true;
      //    **/
      //   /***
      //       2. 비동기 승인 하고자 할 때
      //       checkQtyFromServer(data);
      //       return false;
      //    ***/
      //   /***
      //       3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
      //       return false; 후에 서버에서 결제승인 수행
      //    */
      //   print(data);
      //
      //   approvePay(data, context);
      //   return false;
      // },
      onDone: (String data) {
        print('------- onDone: $data');
        ref
            .read(gameDetailProvider(gameId: widget.gameId).notifier)
            .get(gameId: widget.gameId);
        Map<String, String> pathParameters = {
          'gameId': widget.gameId.toString()
        };
        const GameCompleteType extra = GameCompleteType.payment;
        context.goNamed(
          GameCompleteScreen.routeName,
          pathParameters: pathParameters,
          extra: extra,
        );
      },
    );
  }

  Future<void> approvePay(String data, BuildContext context) async {
    Map<String, dynamic> json = jsonDecode(data);
    final param = BootPayApproveParam.fromJson(json);
    final result = await ref.read(approveBootPayProvider(param: param).future);
    if (context.mounted) {
      if (result is ErrorModel) {
        PayError.fromModel(model: result, object: widget.gameId)
            .responseError(context, PayApiType.bootPayApproval, ref);
      } else {
        final model = (result as ResponseModel<PaymentCompletedResponse>).data!;
        switch (model.status) {
          case PaymentResultStatusType.approved:
            {
              Bootpay().transactionConfirm();
              // Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
              break;
            }
          case PaymentResultStatusType.canceled:
            {
              break;
            }
          case PaymentResultStatusType.requested:
            {
              break;
            }
          case PaymentResultStatusType.created:
            {
              break;
            }
          case PaymentResultStatusType.failed:
            {
              break;
            }
          case PaymentResultStatusType.cancel_pending:
            {
              break;
            }
        }
      }
    }
  }

// Future<void> onPay(
//     WidgetRef ref, BuildContext context, PaymentMethodType type) async {
//   final result = await ref
//       .read(readyPayProvider(gameId: widget.gameId, type: type).future);
//   if (context.mounted) {
//     if (result is ErrorModel) {
//       PayError.fromModel(model: result)
//           .responseError(context, PayApiType.ready, ref);
//     } else {
//       switch (type) {
//         case PaymentMethodType.kakao:
//           final model = (result as ResponseModel<PayBaseModel>).data!;
//           model as PayReadyModel;
//           // log('model = ${model.runtimeType}');
//
//           final pathParameters = {'gameId': widget.gameId.toString()};
//           final queryParameters = {
//             'redirectUrl': model.next_redirect_mobile_url
//           };
//           context.goNamed(
//             BootPayScreen.routeName,
//             pathParameters: pathParameters,
//             queryParameters: queryParameters,
//           );
//           break;
//         case PaymentMethodType.empty_pay:
//           log("무료 경기 참여 완료");
//           Map<String, String> pathParameters = {
//             'gameId': widget.gameId.toString()
//           };
//           const GameCompleteType extra = GameCompleteType.payment;
//
//           context.goNamed(
//             GameCompleteScreen.routeName,
//             pathParameters: pathParameters,
//             extra: extra,
//           );
//           break;
//         default:
//           break;
//       }
//     }
//   }
// }
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

  factory PaymentComponent.fromModel(
      {required GameParticipationPaymentResponse model}) {
    final payment = model.paymentAmount;
    final game_fee_amount =
        NumberFormat.decimalPattern().format(payment.gameFeeAmount);
    final miti_commission_amount =
        NumberFormat.decimalPattern().format(payment.commissionAmount);
    final vat_amount = NumberFormat.decimalPattern().format(payment.vatAmount);
    final totalAmount =
        NumberFormat.decimalPattern().format(payment.totalAmount);
    final promotion_amount = NumberFormat.decimalPattern()
        .format(model.discountAmount.promotionAmount);
    final final_payment_amount =
        NumberFormat.decimalPattern().format(model.finalPaymentAmount);
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

// class PayWayButton extends ConsumerWidget {
//   const PayWayButton({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final selected = ref.watch(checkProvider(1));
//     final paymentWay = ref.watch(paymentWayProvider);
//     return Padding(
//       padding:
//           EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 28.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             '결제 수단',
//             style: MITITextStyle.mdBold.copyWith(
//               color: MITIColor.gray100,
//             ),
//           ),
//           SizedBox(height: 20.h),
//           SizedBox(
//             height: 44.h,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () {
//                       ref
//                           .read(paymentWayProvider.notifier)
//                           .update((state) => PaymentMethodType.kakao);
//                     },
//                     style: TextButton.styleFrom(
//                       backgroundColor: paymentWay == PaymentMethodType.kakao
//                           ? const Color(0xFFFFF100)
//                           : MITIColor.gray800,
//                       fixedSize: Size(double.infinity, 44.h),
//                       shape: RoundedRectangleBorder(
//                         side: BorderSide(
//                           color: paymentWay == PaymentMethodType.kakao
//                               ? const Color(0xFFFFF100)
//                               : MITIColor.gray700,
//                         ),
//                         borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                       ),
//                     ),
//                     child: SvgPicture.asset(
//                       AssetUtil.getAssetPath(
//                           type: AssetType.icon, name: 'kakaopay'),
//                       colorFilter: ColorFilter.mode(
//                           paymentWay == PaymentMethodType.kakao
//                               ? const Color(0xFF040000)
//                               : const Color(0xFFFFF100),
//                           BlendMode.srcIn),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () {
//                       ref
//                           .read(paymentWayProvider.notifier)
//                           .update((state) => PaymentMethodType.card);
//                     },
//                     style: TextButton.styleFrom(
//                       backgroundColor: paymentWay == PaymentMethodType.card
//                           ? MITIColor.primary
//                           : MITIColor.gray800,
//                       fixedSize: Size(double.infinity, 44.h),
//                       shape: RoundedRectangleBorder(
//                         side: BorderSide(
//                           color: paymentWay == PaymentMethodType.card
//                               ? MITIColor.primary
//                               : MITIColor.gray700,
//                         ),
//                         borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SvgPicture.asset(
//                           AssetUtil.getAssetPath(
//                               type: AssetType.icon, name: 'card'),
//                           colorFilter: ColorFilter.mode(
//                               paymentWay == PaymentMethodType.card
//                                   ? MITIColor.black
//                                   : MITIColor.gray400,
//                               BlendMode.srcIn),
//                         ),
//                         SizedBox(width: 2.w),
//                         Text(
//                           '신용카드',
//                           style: MITITextStyle.xxsmSemiBold.copyWith(
//                             color: paymentWay == PaymentMethodType.card
//                                 ? MITIColor.black
//                                 : MITIColor.gray400,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 // Expanded(
//                 //   child: TextButton(
//                 //     onPressed: () {
//                 //       ref
//                 //           .read(paymentWayProvider.notifier)
//                 //           .update((state) => PaymentMethodType.bank);
//                 //     },
//                 //     style: TextButton.styleFrom(
//                 //       backgroundColor: paymentWay == PaymentMethodType.bank
//                 //           ? MITIColor.primary
//                 //           : MITIColor.gray800,
//                 //       fixedSize: Size(double.infinity, 44.h),
//                 //       shape: RoundedRectangleBorder(
//                 //         side: BorderSide(
//                 //           color: paymentWay == PaymentMethodType.bank
//                 //               ? MITIColor.primary
//                 //               : MITIColor.gray700,
//                 //         ),
//                 //         borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                 //       ),
//                 //     ),
//                 //     child: Row(
//                 //       mainAxisAlignment: MainAxisAlignment.center,
//                 //       children: [
//                 //         SvgPicture.asset(
//                 //           AssetUtil.getAssetPath(
//                 //               type: AssetType.icon, name: 'account_transfer'),
//                 //           colorFilter: ColorFilter.mode(
//                 //               paymentWay == PaymentMethodType.bank
//                 //                   ? MITIColor.black
//                 //                   : MITIColor.gray400,
//                 //               BlendMode.srcIn),
//                 //         ),
//                 //         SizedBox(width: 2.w),
//                 //         Text(
//                 //           '계좌이체',
//                 //           style: MITITextStyle.xxsmSemiBold.copyWith(
//                 //             color: paymentWay == PaymentMethodType.bank
//                 //                 ? MITIColor.black
//                 //                 : MITIColor.gray400,
//                 //           ),
//                 //         )
//                 //       ],
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class PaymentAndRefundPolicyComponent extends StatelessWidget {
  final bool isPayment;
  final String title;

  const PaymentAndRefundPolicyComponent(
      {super.key, required this.title, required this.isPayment});

  @override
  Widget build(BuildContext context) {
    List<String> contents = [
      '• 경기 시작 48시간 전 : 전액 환불',
      '• 경기 시작 24시간 전 : 80% 환불',
      '• 경기 시작 12시간 전 : 60% 환불',
      '• 경기 시작 6시간 전 : 40% 환불',
      '• 경기 시작 2시간 전 : 20% 환불',
      '• 경기 시작 2이내 : 참여 취소 불가',
      '• 위의 환불 수수료 정책에 따른 환불 수수료가 300원 미만인 경우, 최소 환불 수수료인 300원이 적용됩니다.'
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
            '경기 참가비 결제의 모든 관리와 책임의 주체는 MITI 이며, MITI는 서비스 이용 과정에서 발생하는 불만이나 분쟁을 해결하기 위하여 원이 및 피해 파악 등 필요한 조치를 시행할 것입니다.',
            style: MITITextStyle.xxsmLight150.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '환불은 참여자가 지불한 참가비가 취소되는 방식으로 진행되며, 결제 취소 금액은 환불 정책에 따라 책정됩니다.',
            style: MITITextStyle.xxsmLight150.copyWith(
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
                  style: MITITextStyle.xxsmLight150
                      .copyWith(color: MITIColor.gray100),
                );
              },
              separatorBuilder: (_, idx) => SizedBox(
                    height: 8.h,
                  ),
              itemCount: contents.length),
          Visibility(
            visible: isPayment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Text(
                  '유의 사항',
                  style: MITITextStyle.smSemiBold.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                SizedBox(height: 12.h),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '• 경기 시작까지 2시간 미만 남은 경기는 참여 완료시 ',
                      style: MITITextStyle.xxsmLight.copyWith(
                        color: MITIColor.gray100,
                      ),
                    ),
                    TextSpan(
                      text: '참여 취소가 불가능',
                      style: MITITextStyle.xxsmLight.copyWith(
                        color: MITIColor.error,
                      ),
                    ),
                    TextSpan(
                      text: '합니다.',
                      style: MITITextStyle.xxsmLight.copyWith(
                        color: MITIColor.gray100,
                      ),
                    ),
                  ]),
                ),
                SizedBox(height: 8.h),
                Text(
                  '• 참여가 어려운 경우, [게스트 경기 목록]에서 참여를 취소해주세요.',
                  style: MITITextStyle.xxsmLight.copyWith(
                    color: MITIColor.gray100,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
