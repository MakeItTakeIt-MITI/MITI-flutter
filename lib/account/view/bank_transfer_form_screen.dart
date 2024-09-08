import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/account/model/account_model.dart';
import 'package:miti/account/provider/account_provider.dart';
import 'package:miti/account/provider/widget/transfer_form_provider.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/view/user_info_screen.dart';

import '../../common/component/custom_drop_down_button.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/entity_enum.dart';
import '../../common/provider/form_util_provider.dart';
import '../../common/provider/router_provider.dart';
import '../../util/util.dart';

class BankTransferFormScreen extends StatefulWidget {
  static String get routeName => 'transferForm';

  const BankTransferFormScreen({
    super.key,
  });

  @override
  State<BankTransferFormScreen> createState() => _BankTransferFormScreenState();
}

class _BankTransferFormScreenState extends State<BankTransferFormScreen> {
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
    return Container(height: 8.h);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              title: '정산금 수령 신청',
              isSliver: true,
              backgroundColor: MITIColor.gray750,
              hasBorder: false,
            )
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _AccountForm(),
                  getDivider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountComponent extends ConsumerWidget {
  const _AccountComponent({
    super.key,
  });

  Row _getAccountInfo({required String title, required int value}) {
    final amount = NumberUtil.format(value.toString());
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
          '₩ $amount',
          style:
              MITITextStyle.feeSStyle.copyWith(color: const Color(0xFF333333)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(accountProvider);
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      AccountError.fromModel(model: result)
          .responseError(context, AccountApiType.getAccountInfo, ref);
      return Text('에러');
    }
    final model = (result as ResponseModel<AccountDetailModel>).data!;
    final requestTransferAmount =
        NumberUtil.format(model.requestableTransferAmount.toString());
    return Padding(
      padding:
          EdgeInsets.only(left: 12.r, right: 12.r, top: 12.r, bottom: 20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '보유 잔고',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 14.h),
          _getAccountInfo(title: '보유잔고', value: model.balance),
          SizedBox(height: 12.h),
          // _getAccountInfo(title: '보유 포인트', value: model.point),
          SizedBox(height: 12.h),
          _getAccountInfo(
              title: '대기 송금요청액', value: model.transferRequestedAmount),
          Divider(
            height: 25.h,
            color: const Color(0xFFE8E8E8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 송금 가능 금액',
                style: MITITextStyle.gameTitleMainStyle.copyWith(
                  color: const Color(0xff222222),
                ),
              ),
              Text(
                '₩ $requestTransferAmount',
                style: MITITextStyle.feeStyle
                    .copyWith(color: const Color(0xfff45858)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountForm extends ConsumerStatefulWidget {
  const _AccountForm({
    super.key,
  });

  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  final formKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  late final List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];

  final items = [
    '카카오뱅크',
    '농협은행',
    '국민은행',
    '신한은행',
    '우리은행',
    '기업은행',
    '하나은행',
    '새마을금고',
    '우체국',
    'SC제일은행',
    '대구은행',
    '부산은행',
    '경남은행',
    '광주은행',
    '신협',
    '수협은행',
    '산업은행',
    '전북은행',
    '제주은행',
    '씨티은행',
    '케이뱅크',
    '토스뱅크',
  ];

  @override
  void initState() {
    for (int i = 0; i < 3; i++) {
      focusNodes[i].addListener(() {
        focusScrollable(i);
      });
    }
  }

  void focusScrollable(int i) {
    Scrollable.ensureVisible(
      formKeys[i].currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    for (int i = 0; i < 3; i++) {
      focusNodes[i].removeListener(() {
        focusScrollable(i);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(accountProvider);
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      AccountError.fromModel(model: result)
          .responseError(context, AccountApiType.getAccountInfo, ref);

      return Text('에러');
    }
    final model = (result as ResponseModel<AccountDetailModel>).data!;
    final check1 = ref.watch(checkProvider(1));
    final check2 = ref.watch(checkProvider(2));
    final form = ref.watch(transferFormProvider);
    final valid = ref
            .watch(transferFormProvider.notifier)
            .valid(model.requestableTransferAmount) &&
        check1 &&
        check2;
    final interactionDesc =
        ref.watch(formDescProvider(InputFormType.passwordCode));
    return Padding(
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '이체하실 계좌 정보',
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '은행',
                      style: MITITextStyle.inputLabelIStyle,
                    ),
                    SizedBox(height: 10.h),
                    CustomDropDownButton(
                      items: items,
                      height: 50.h,
                      radius: 8.r,
                      padding: 16.r,
                      textStyle: MITITextStyle.inputValueMStyle
                          .copyWith(height: 1, color: Colors.black),
                      onChanged: (String? value) {
                        ref
                            .read(transferFormProvider.notifier)
                            .update(account_bank: value);
                        ref
                            .read(dropDownValueProvider.notifier)
                            .update((state) => value);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 60.w),
              Expanded(
                child: CustomTextFormField(
                  key: formKeys[0],
                  onChanged: (val) {
                    ref
                        .read(transferFormProvider.notifier)
                        .update(account_holder: val);
                  },
                  focusNode: focusNodes[0],
                  onNext: () {
                    FocusScope.of(context).requestFocus(focusNodes[1]);
                  },
                  hintText: '김미티',
                  label: '예금주',
                  textInputAction: TextInputAction.next,
                  labelTextStyle: MITITextStyle.inputLabelIStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '은행',
                style: MITITextStyle.sm.copyWith(color: MITIColor.gray300),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.r),
                        ),
                      ),
                      backgroundColor: MITIColor.gray800,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: MITIColor.gray100,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                width: 60.w,
                                height: 4.h,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(20.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '은행',
                                    style: MITITextStyle.mdBold.copyWith(
                                      color: MITIColor.gray100,
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            )
                          ],
                        );
                      });
                },
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: MITIColor.gray700,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '수령할 계좌번호의 은행사를 선택해주세요.',
                        style: MITITextStyle.sm.copyWith(
                          color: MITIColor.gray500,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: MITIColor.gray400,
                        size: 16.r,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            key: formKeys[1],
            hintText: '수령할 계좌번호를 입력해 주세요.',
            hintTextStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
            label: '계좌번호',
            focusNode: focusNodes[1],
            onNext: () {
              FocusScope.of(context).requestFocus(focusNodes[2]);
            },
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            onChanged: (val) {
              ref
                  .read(transferFormProvider.notifier)
                  .update(account_number: val);
            },
          ),
          SizedBox(height: 30.h),
          CustomTextFormField(
            key: formKeys[2],
            hintText: '0',
            hintTextStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
            focusNode: focusNodes[2],
            labelTextStyle: MITITextStyle.inputLabelIStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MoneyFormatter(),
            ],
            onChanged: (val) {
              if (val.isEmpty) {
                val = '0';
              }
              final value = val.replaceAll(',', '').replaceAll('₩ ', '');
              final amount = int.parse(value);
              ref.read(transferFormProvider.notifier).update(amount: amount);
              if (amount > model.requestableTransferAmount) {
                ref
                    .read(formDescProvider(InputFormType.passwordCode).notifier)
                    .update((state) => InteractionDesc(
                        isSuccess: false, desc: '송금 가능한 금액을 초과하였습니다.'));
              } else {
                ref
                    .read(formDescProvider(InputFormType.passwordCode).notifier)
                    .update((state) => null);
              }
            },
            interactionDesc: interactionDesc,
          ),
          SizedBox(height: 50.h),
          InkWell(
            onTap: () {
              ref.read(checkProvider(1).notifier).update((state) => !state);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MITI 송금 규정에 동의합니다.',
                  style: MITITextStyle.textCheckStyle.copyWith(
                    color: check1
                        ? const Color(0xFF4065F5)
                        : const Color(0xFF999999),
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/icon/system_success.svg',
                  colorFilter: ColorFilter.mode(
                      check1
                          ? const Color(0xFF4065F5)
                          : const Color(0xFF999999),
                      BlendMode.srcIn),
                )
              ],
            ),
          ),
          SizedBox(height: 15.h),
          InkWell(
            onTap: () {
              ref.read(checkProvider(2).notifier).update((state) => !state);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '송금은 신청일 이후 평일 17시 이후 순차적으로 처리됩니다.',
                  style: MITITextStyle.textCheckStyle.copyWith(
                    color: check2
                        ? const Color(0xFF4065F5)
                        : const Color(0xFF999999),
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/icon/system_success.svg',
                  colorFilter: ColorFilter.mode(
                      check2
                          ? const Color(0xFF4065F5)
                          : const Color(0xFF999999),
                      BlendMode.srcIn),
                )
              ],
            ),
          ),
          SizedBox(height: 30.h),
          TextButton(
            onPressed: valid
                ? () async {
                    await requestTransfer(ref, context);
                  }
                : () {},
            style: TextButton.styleFrom(
              backgroundColor:
                  valid ? const Color(0xFF4065F6) : const Color(0xFFE8E8E8),
            ),
            child: Text(
              '송금 신청하기',
              style: MITITextStyle.btnTextBStyle.copyWith(
                  color: valid ? Colors.white : const Color(0xff969696)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> requestTransfer(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(requestTransferProvider.future);
    if (context.mounted) {
      if (result is ErrorModel) {
        AccountError.fromModel(model: result)
            .responseError(context, AccountApiType.requestTransfer, ref);
      } else {
        final extra = CustomDialog(
          title: '송금 요청 생성 완료',
          content: '송금 요청이 정상적으로 생성되었습니다.\n송금 내역에서 송금 상태를 확인하세요.',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            context.goNamed(InfoBody.routeName);
          },
        );
        context.pushNamed(DialogPage.routeName, extra: extra);
      }
    }
  }
}
