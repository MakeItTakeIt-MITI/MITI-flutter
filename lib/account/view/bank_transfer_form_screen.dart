import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/account/model/account_model.dart';
import 'package:miti/account/provider/account_provider.dart';
import 'package:miti/account/provider/widget/transfer_form_provider.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/custom_time_picker.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/provider/widget/form_provider.dart';
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/report/model/agreement_policy_model.dart';
import 'package:miti/report/provider/report_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/view/profile_menu_screen.dart';

import '../../auth/view/signup/signup_screen.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/entity_enum.dart';
import '../../common/view/operation_term_screen.dart';
import '../../game/model/v2/account/base_account_response.dart';
import '../../util/util.dart';
import '../component/bank_card.dart';
import 'package:collection/collection.dart';

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

  final formKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  late final List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];

  void focusScrollable(int i) {
    log("scrollalble ${i}");
    Scrollable.ensureVisible(
      formKeys[i].currentContext!,
      duration: const Duration(milliseconds: 600),
      alignment: 0.5,
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (int i = 0; i < 3; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          focusScrollable(i);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (int i = 0; i < 3; i++) {
      focusNodes[i].removeListener(() {
        focusScrollable(i);
      });
    }
    super.dispose();
  }

  Widget getDivider() {
    return Container(height: 8.h);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '정산금 수령 신청',
          backgroundColor: MITIColor.gray750,
          hasBorder: false,
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _AccountForm(
                    globalKeys: formKeys,
                    focusNodes: focusNodes,
                  ),
                  getDivider(),
                  _TransferAmountForm(
                    focusNode: focusNodes[2],
                    globalKey: formKeys[2],
                  ),
                  getDivider(),
                  const _AgreementTermForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountForm extends ConsumerStatefulWidget {
  final List<GlobalKey> globalKeys;
  final List<FocusNode> focusNodes;

  const _AccountForm({
    super.key,
    required this.globalKeys,
    required this.focusNodes,
  });

  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: MITIColor.gray750,
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '이체하실 계좌 정보',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            key: widget.globalKeys[0],
            hintText: '이체할 계좌번호의 예금주를 입력해 주세요.',
            hintTextStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
            label: '예금주',
            textStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray100),
            focusNode: widget.focusNodes[0],
            onTap: () {
              FocusScope.of(context).requestFocus(widget.focusNodes[0]);
            },
            onNext: () {
              FocusScope.of(context).requestFocus(widget.focusNodes[1]);
            },
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              ref
                  .read(transferFormProvider.notifier)
                  .update(account_holder: val);
            },
          ),
          SizedBox(height: 20.h),
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
                  String selectBank = '';
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
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '은행',
                                      style: MITITextStyle.mdBold.copyWith(
                                        color: MITIColor.gray100,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Wrap(
                                      spacing: 10.r,
                                      runSpacing: 10.r,
                                      children: BankType.values
                                          .map((b) => GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (selectBank ==
                                                        b.displayName) {
                                                      selectBank = '';
                                                    } else {
                                                      selectBank =
                                                          b.displayName;
                                                    }
                                                  });
                                                },
                                                child: BankCard(
                                                  bank: b,
                                                  isSelected: selectBank ==
                                                      b.displayName,
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                    SizedBox(height: 20.h),
                                    TextButton(
                                        onPressed: selectBank.isNotEmpty
                                            ? () {
                                                final selectBankType =
                                                    BankType.stringToEnum(
                                                        value: selectBank);
                                                ref
                                                    .read(transferFormProvider
                                                        .notifier)
                                                    .update(
                                                        account_bank:
                                                            selectBankType);
                                                context.pop();
                                                FocusScope.of(context)
                                                    .unfocus();
                                              }
                                            : null,
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                selectBank.isNotEmpty
                                                    ? MITIColor.primary
                                                    : MITIColor.gray500),
                                        child: Text(
                                          '확인',
                                          style: MITITextStyle.mdBold.copyWith(
                                              color: selectBank.isNotEmpty
                                                  ? MITIColor.gray800
                                                  : MITIColor.gray50),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          );
                        });
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
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          final accountBank = ref.watch(transferFormProvider
                              .select((t) => t.account_bank));

                          final bank = accountBank?.displayName ??
                              '이체할 계좌번호의 은행사를 선택해주세요.';

                          return Text(
                            bank,
                            style: MITITextStyle.sm.copyWith(
                              color: accountBank == null
                                  ? MITIColor.gray500
                                  : MITIColor.gray100,
                            ),
                          );
                        },
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: MITIColor.gray400,
                        size: 16.r,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            key: widget.globalKeys[1],
            hintText: '이체할 계좌번호를 입력해 주세요.',
            hintTextStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
            onTap: () {
              FocusScope.of(context).requestFocus(widget.focusNodes[1]);
            },
            label: '계좌번호',
            textStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray100),
            focusNode: widget.focusNodes[1],
            onNext: () {
              FocusScope.of(context).requestFocus(widget.focusNodes[2]);
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
        ],
      ),
    );
  }
}

class _TransferAmountForm extends ConsumerWidget {
  final GlobalKey globalKey;
  final FocusNode focusNode;

  const _TransferAmountForm(
      {super.key, required this.focusNode, required this.globalKey});

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

    final model = (result as ResponseModel<BaseAccountResponse>).data!;

    final interaction = ref.watch(formInfoProvider(InputFormType.amount));
    final amount =
        NumberUtil.format(model.transferRequestableAmount.toString());
    return Container(
      color: MITIColor.gray750,
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '이체하실 금액',
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Text(
                '현재 이체 가능한 금액',
                style: MITITextStyle.sm.copyWith(color: MITIColor.gray100),
              ),
              SizedBox(width: 20.w),
              Text(
                '$amount 원',
                style: MITITextStyle.smBold.copyWith(color: MITIColor.primary),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            key: globalKey,
            hintText: '0',
            hintTextStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
            focusNode: focusNode,
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
            },
            textStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray100),
            labelTextStyle: MITITextStyle.inputLabelIStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              NumberFormatter(),
            ],
            onChanged: (val) {
              if (val.isEmpty) {
                val = '0';
              }
              final value = val.replaceAll(',', '').replaceAll('₩ ', '');
              final amount = int.parse(value);
              ref.read(transferFormProvider.notifier).update(amount: amount);
              if (amount > model.transferRequestableAmount) {
                ref
                    .read(formInfoProvider(InputFormType.amount).notifier)
                    .update(
                        interactionDesc: InteractionDesc(
                            isSuccess: false, desc: '이체 가능한 금액을 초과하였습니다.'),
                        borderColor: MITIColor.error);
              } else {
                ref
                    .read(formInfoProvider(InputFormType.amount).notifier)
                    .reset();
              }
            },
            borderColor: interaction.borderColor,
            suffixIcon: Text(
              '원',
              style: MITITextStyle.sm.copyWith(color: MITIColor.gray100),
            ),
            interactionDesc: interaction.interactionDesc,
          ),
        ],
      ),
    );
  }
}

class _AgreementTermForm extends ConsumerStatefulWidget {
  const _AgreementTermForm({super.key});

  @override
  ConsumerState<_AgreementTermForm> createState() => _AgreementTermFormState();
}

class _AgreementTermFormState extends ConsumerState<_AgreementTermForm> {
  late Throttle<int> _throttler;
  int throttleCnt = 0;
  bool isLoading = false;

  @override
  void initState() {
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
      await requestTransfer(ref, context);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _throttler.cancel();
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
    final model = (result as ResponseModel<BaseAccountResponse>).data!;

    List<bool> isCheckBoxes =
        ref.watch(transferFormProvider.select((value) => value.checkBoxes));

    final checkResult = ref.watch(
        agreementPolicyProvider(type: AgreementRequestType.transfer_request));
    bool validCheckBox = true;
    if (checkResult is ResponseListModel<AgreementPolicyModel>) {
      final checkModel = checkResult.data!;
      for (int i = 0; i < isCheckBoxes.length; i++) {
        if (checkModel[i].is_required && !isCheckBoxes[i]) {
          validCheckBox = false;
        }
      }
    }

    final form = ref.watch(transferFormProvider);
    final valid = ref
            .watch(transferFormProvider.notifier)
            .valid(model.transferRequestableAmount) &&
        validCheckBox;
    return Container(
      color: MITIColor.gray750,
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 28.h),
      child: Column(
        children: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final checkResult = ref.watch(agreementPolicyProvider(
                  type: AgreementRequestType.transfer_request));
              if (checkResult is LoadingModel) {
                return Container();
              } else if (checkResult is ErrorModel) {
                return Container();
              }
              final model =
                  (checkResult as ResponseListModel<AgreementPolicyModel>)
                      .data!;

              final checkBoxes = model.mapIndexed((idx, e) {
                return CustomCheckBox(
                    title:
                        '${e.is_required ? '[필수] ' : '[선택] '} ${e.policy.name}',
                    textStyle:
                        MITITextStyle.sm.copyWith(color: MITIColor.gray200),
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
                      // Navigator.of(context).push(TutorialOverlay());
                    },
                    onTap: () {
                      onCheck(ref, idx);
                    });
              }).toList();
              return CheckBoxFormV2(
                checkBoxes: [...checkBoxes],
                allTap: () {
                  ref.read(checkProvider(2).notifier).update((state) => !state);
                  isCheckBoxes.fillRange(
                      0, isCheckBoxes.length, ref.read(checkProvider(2)));
                  ref
                      .read(transferFormProvider.notifier)
                      .update(checkBoxes: isCheckBoxes.toList());
                },
              );
            },
          ),
          SizedBox(height: 30.h),
          TextButton(
            onPressed: valid && !isLoading
                ? () async {
                    _throttler.setValue(throttleCnt + 1);
                  }
                : () {},
            style: TextButton.styleFrom(
              backgroundColor:
                  valid && !isLoading ? MITIColor.primary : MITIColor.gray500,
            ),
            child: Text(
              '이체 신청하기',
              style: MITITextStyle.mdBold.copyWith(
                color:
                    valid && !isLoading ? MITIColor.gray800 : MITIColor.gray50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onCheck(WidgetRef ref, int idx) {
    final allChecked =
        !ref.read(transferFormProvider.notifier).onCheck(idx).contains(false);
    ref.read(checkProvider(2).notifier).update((state) => allChecked);
  }

  Future<void> requestTransfer(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(requestTransferProvider.future);
    if (context.mounted) {
      if (result is ErrorModel) {
        AccountError.fromModel(model: result)
            .responseError(context, AccountApiType.requestTransfer, ref);
      } else {
        showModalBottomSheet(
            context: context,
            isDismissible: false,
            builder: (_) {
              return BottomDialog(
                title: '정산금 이체 신청 완료',
                content:
                    '정산금 이체 신청이 완료되었습니다.\n정산 관리 > 정산금 이체 내역에서 정산 현황을 확인해 보세요!',
                btn: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return TextButton(
                      onPressed: () async {
                        context.goNamed(ProfileBody.routeName);
                      },
                      style: TextButton.styleFrom(
                        fixedSize: Size(double.infinity, 48.h),
                      ),
                      child: const Text(
                        "확인",
                      ),
                    );
                  },
                ),
              );
            });
      }
    }
  }
}
