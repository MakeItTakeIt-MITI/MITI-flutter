import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kpostal/kpostal.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/provider/widget/datetime_provider.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:miti/court/provider/court_provider.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/custom_time_picker.dart';
import '../../common/provider/router_provider.dart';
import '../../court/component/court_list_component.dart';
import '../../util/util.dart';
import '../model/game_model.dart';
import '../param/game_param.dart';
import 'game_create_complete_screen.dart';

class GameCreateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'create';
  final int bottomIdx;

  const GameCreateScreen({
    super.key,
    required this.bottomIdx,
  });

  @override
  ConsumerState<GameCreateScreen> createState() => _GameCreateScreenState();
}

class _GameCreateScreenState extends ConsumerState<GameCreateScreen> {
  late final ScrollController _scrollController;
  final formKeys = [GlobalKey(), GlobalKey()];

  late final List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
  ];

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

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '경기 생성하기',
            )
          ];
        },
        body: Padding(
          padding: EdgeInsets.only(
            // vertical: 20.h,
            left: 21.w,
            right: 21.w,
            // bottom: bottomPadding,
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              const _TitleForm(),
              getSpacer(),
              V2DateForm(),
              // const _DateForm(),
              getSpacer(),
              const _AddressForm(),
              getSpacer(),
              SliverToBoxAdapter(
                  child: ApplyForm(
                formKeys: formKeys,
                focusNodes: focusNodes,
              )),
              getSpacer(),
              const _FeeForm(),
              getSpacer(),
              const _AdditionalInfoForm(),
              getSpacer(height: 32),
              _AgreeTermComponent(),
              getSpacer(height: 20),

              // getSpacer(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          ref.watch(gameFormProvider);
          final valid = ref.read(gameFormProvider.notifier).formValid();
          return BottomButton(
              button: SizedBox(
            height: 48.h,
            child: TextButton(
                onPressed: valid
                    ? () async {
                        final result =
                            await ref.read(gameCreateProvider.future);
                        if (context.mounted) {
                          if (result is ErrorModel) {
                            GameError.fromModel(model: result).responseError(
                                context, GameApiType.createGame, ref);
                          } else {
                            final model =
                                result as ResponseModel<GameDetailModel>;
                            Map<String, String> pathParameters = {
                              'gameId': model.data!.id.toString()
                            };
                            final Map<String, String> queryParameters = {
                              'bottomIdx': widget.bottomIdx.toString()
                            };
                            context.pushNamed(
                              GameCreateCompleteScreen.routeName,
                              pathParameters: pathParameters,
                              queryParameters: queryParameters,
                            );
                          }
                        }
                      }
                    : () {},
                style: TextButton.styleFrom(
                    backgroundColor:
                        valid ? MITIColor.primary : MITIColor.gray500,
                    fixedSize: Size(double.infinity, 48.h)),
                child: Text(
                  '경기 생성하기',
                  style: TextStyle(
                    color: valid ? MITIColor.gray800 : MITIColor.gray50,
                  ),
                )),
          ));
        },
      ),
    );
  }

  SliverToBoxAdapter getSpacer({double height = 32}) => SliverToBoxAdapter(
        child: SizedBox(height: height.h),
      );
}

class _TitleForm extends StatelessWidget {
  const _TitleForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final title =
            ref.watch(gameFormProvider.select((value) => value.title));
        return SliverToBoxAdapter(
            child: CustomTextFormField(
          hintText: '경기 제목을 입력해주세요.',
          label: '경기 제목',
          onChanged: (val) {
            ref.read(gameFormProvider.notifier).update(title: val);
          },
        ));
      },
    );
  }
}

final dateFormProvider = StateProvider.autoDispose<String?>((ref) => null);

class V2DateForm extends StatefulWidget {
  const V2DateForm({super.key});

  @override
  State<V2DateForm> createState() => _V2DateFormState();
}

class _V2DateFormState extends State<V2DateForm> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "경기 시간",
            style: MITITextStyle.sm.copyWith(
              color: MITIColor.gray300,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                height: 48.r,
                width: 273.w,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  color: MITIColor.gray700,
                ),
                child: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final date = ref.watch(dateFormProvider);
                    return Text(
                      date ?? "경기 날짜와 시간을 선택해 주세요.",
                      style: MITITextStyle.md.copyWith(
                        color: date == null
                            ? MITIColor.gray500
                            : MITIColor.gray100,
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return Align(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 21.w),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: MITIColor.gray700,
                                  borderRadius: BorderRadius.circular(20.r)),
                              padding: EdgeInsets.all(20.r),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "경기 시간 설정",
                                        style: MITITextStyle.mdBold
                                            .copyWith(color: MITIColor.gray100),
                                      ),
                                      IconButton(
                                          onPressed: () => context.pop(),
                                          style: const ButtonStyle(
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap),
                                          constraints: BoxConstraints.tight(
                                              Size(24.r, 24.r)),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.close,
                                            color: MITIColor.gray100,
                                          ))
                                    ],
                                  ),
                                  SizedBox(height: 40.h),
                                  const _GameTimePicker(
                                    isStart: true,
                                  ),
                                  Divider(
                                    height: 41.h,
                                    color: MITIColor.gray600,
                                  ),
                                  const _GameTimePicker(
                                    isStart: false,
                                  ),
                                  SizedBox(height: 40.h),
                                  Consumer(
                                    builder: (BuildContext context,
                                        WidgetRef ref, Widget? child) {
                                      final valid = ref
                                              .watch(datePickerProvider(true))
                                              .isNotEmpty &&
                                          ref
                                              .watch(datePickerProvider(false))
                                              .isNotEmpty;

                                      return TextButton(
                                        onPressed: valid
                                            ? () {
                                                selectDay(ref);
                                              }
                                            : null,
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(valid
                                                    ? MITIColor.primary
                                                    : MITIColor.gray500)),
                                        child: Text(
                                          "선택 완료",
                                          style: MITITextStyle.mdBold.copyWith(
                                              color: valid
                                                  ? MITIColor.gray800
                                                  : MITIColor.gray50),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
                child: Container(
                  height: 48.r,
                  width: 48.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: MITIColor.primary,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    height: 24.r,
                    width: 24.r,
                    colorFilter: const ColorFilter.mode(
                        MITIColor.gray900, BlendMode.srcIn),
                    AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: "clock",
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void selectDay(WidgetRef ref) {
    final startDate = ref.watch(datePickerProvider(true));
    final endDate = ref.watch(datePickerProvider(false));

    log("start = $startDate");
    final parsingStart = parseDate(startDate);
    final parsingEnd = parseDate(endDate);

    ref.read(gameFormProvider.notifier).update(
          startdate: parsingStart.date,
          starttime: parsingStart.time,
          enddate: parsingEnd.date,
          endtime: parsingEnd.time,
        );
    FocusScope.of(context).requestFocus(FocusNode());

    ref.read(dateFormProvider.notifier).update(
        (state) => "${startDate.substring(7)} ~ ${endDate.substring(7)}");
    context.pop();
  }

  GameDate parseDate(String dateTime) {
    final inputFormat = DateFormat("yyyy / MM / dd (E) hh:mm", "ko_KR");
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateFormat timeFormat = DateFormat("HH:mm");
    DateTime parsedDate = inputFormat.parse(dateTime);
    String formattedDate = dateFormat.format(parsedDate);
    String formattedTime = timeFormat.format(parsedDate);
    log("formattedDate $formattedDate, formattedTime $formattedTime");
    return GameDate(date: formattedDate, time: formattedTime);
  }
}

class GameDate {
  final String date;
  final String time;

  GameDate({required this.date, required this.time});
}

final datePickerProvider =
    StateProvider.family.autoDispose<String, bool>((ref, isStart) => "");

class _GameTimePicker extends StatefulWidget {
  final bool isStart;

  const _GameTimePicker({super.key, required this.isStart});

  @override
  State<_GameTimePicker> createState() => _GameTimePickerState();
}

class _GameTimePickerState extends State<_GameTimePicker> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.isStart ? "경기 시작 시간" : "경기 종료 시간",
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final dateTime =
                          ref.watch(datePickerProvider(widget.isStart));
                      final text = dateTime.isNotEmpty
                          ? dateTime.substring(7)
                          : dateTime;
                      return Text(
                        text,
                        style: MITITextStyle.smSemiBold.copyWith(
                          color: MITIColor.primary,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16.w),
                  SvgPicture.asset(
                    AssetUtil.getAssetPath(
                        type: AssetType.icon, name: "top_arrow"),
                  )
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedContainer(
          height: isOpen ? 96.h : 0,
          duration: const Duration(milliseconds: 300),
          child: isOpen
              ? CustomDateTimePicker(
                  isStart: widget.isStart,
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TimePicker extends StatefulWidget {
  const _TimePicker({super.key});

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> {
  int v = 0;

  @override
  Widget build(BuildContext context) {
    final widget = CupertinoPicker(
      itemExtent: 32.h,
      diameterRatio: 10,
      squeeze: 1.0,
      onSelectedItemChanged: (int value) {
        setState(() {
          v = value;
        });
      },

      // backgroundColor: MITIColor.gray700,
      looping: true,
      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        background: MITIColor.white.withOpacity(0.1),
      ),
      children: List.generate(
          12,
          (index) => Align(
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: MITITextStyle.md.copyWith(
                    color: v == index ? MITIColor.primary : MITIColor.gray300,
                  ),
                ),
              )),
    );
    return SizedBox(
      height: 96.h,
      child: widget,
    );
  }
}

// class _DateForm extends ConsumerStatefulWidget {
//   const _DateForm({super.key});
//
//   @override
//   ConsumerState<_DateForm> createState() => _DateFormState();
// }
//
// class _DateFormState extends ConsumerState<_DateForm> {
//   late final TextEditingController dateController;
//
//   @override
//   void initState() {
//     super.initState();
//     dateController = TextEditingController();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen(dateProvider(DateTimeType.start), (previous, next) {
//       final endDate = ref.read(dateProvider(DateTimeType.end));
//       if (next != null && endDate != null) {
//         final formatStart = DateTimeUtil.getDateTime(dateTime: next);
//         final formatEnd = DateTimeUtil.getDateTime(dateTime: endDate);
//         dateController.text = '$formatStart ~ $formatEnd';
//         ref
//             .read(gameFormProvider.notifier)
//             .update(startDateTime: next, endDateTime: endDate);
//         ref.read(gameFormProvider.notifier).validDatetimeInteraction();
//       }
//     });
//     ref.listen(dateProvider(DateTimeType.end), (previous, next) {
//       final startDate = ref.read(dateProvider(DateTimeType.start));
//       if (next != null && startDate != null) {
//         final formatStart = DateTimeUtil.getDateTime(dateTime: startDate);
//         final formatEnd = DateTimeUtil.getDateTime(dateTime: next);
//         dateController.text = '$formatStart ~ $formatEnd';
//         ref
//             .read(gameFormProvider.notifier)
//             .update(startDateTime: startDate, endDateTime: next);
//         ref.read(gameFormProvider.notifier).validDatetimeInteraction();
//       }
//     });
//
//     final interactionDesc =
//         ref.watch(interactionDescProvider(InteractionType.date));
//     return SliverToBoxAdapter(
//         child: Column(
//       children: [
//         DateInputForm(
//           textEditingController: dateController,
//           hintText: '경기 시간을 선택해주세요.',
//           label: '경기 시간',
//           enabled: false,
//           labelTextStyle: TextStyleUtil.getLabelTextStyle(),
//           hintTextStyle: TextStyleUtil.getHintTextStyle(),
//           textStyle: TextStyleUtil.getTextStyle(),
//           isRangeCalendar: true,
//           interactionDesc: interactionDesc,
//         ),
//       ],
//     ));
//   }
// }

class AddressComponent extends StatelessWidget {
  final GameCourtParam court;

  const AddressComponent({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    final address = court.address;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '경기 주소',
          style: MITITextStyle.sm.copyWith(
            color: MITIColor.gray300,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Container(
              height: 48.h,
              width: 222.w,
              decoration: ShapeDecoration(
                color: MITIColor.gray700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        address.isEmpty ? '주소를 검색해주세요.' : address,
                        style: address.isEmpty
                            ? MITITextStyle.md
                                .copyWith(color: MITIColor.gray500)
                            : MITITextStyle.md
                                .copyWith(color: MITIColor.gray100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 48.h,
              width: 98.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KpostalView(
                              callback: (Kpostal kpostal) async {
                                log('result  =${kpostal}');
                                final newCourt =
                                    court.copyWith(address: kpostal.address);
                                ref
                                    .read(gameFormProvider.notifier)
                                    .update(court: newCourt);
                                final result =
                                    await ref.read(courtListProvider.future);

                                if (result is ErrorModel) {
                                } else {
                                  result as ResponseModel<
                                      PaginationModel<CourtSearchModel>>;
                                  if (context.mounted) {
                                    if (result.data!.page_content.isNotEmpty) {
                                      final extra = CourtListComponent(
                                        model: result,
                                      );
                                      context.pushNamed(DialogPage.routeName,
                                          extra: extra);
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '주소검색',
                        style: MITITextStyle.md.copyWith(
                          color: MITIColor.gray800,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({super.key});

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  late final TextEditingController addressController;
  late final TextEditingController addressDetailController;
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController();
    addressDetailController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final court = ref.watch(gameFormProvider.select((value) => value.court));
    ref.listen(gameFormProvider, (previous, next) {
      if (previous?.court != next.court) {
        if (previous?.court.name != next.court.name) {
          nameController.text = next.court.name;
        }
        if (previous?.court.address_detail != next.court.address_detail) {
          addressDetailController.text = next.court.address_detail ?? '';
        }
      }
    });

    return SliverToBoxAdapter(
      child: Column(
        children: [
          AddressComponent(
            court: court,
          ),
          SizedBox(height: 32.h),
          CustomTextFormField(
            hintText: '상세 주소를 입력해주세요.',
            label: '경기 상세 주소',
            textEditingController: addressDetailController,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              final newCourt = court.copyWith(address_detail: val);
              ref.read(gameFormProvider.notifier).update(court: newCourt);
            },
          ),
          SizedBox(height: 32.h),
          CustomTextFormField(
            textEditingController: nameController,
            hintText: '경기장 이름을 입력해주세요.',
            label: '경기장 이름',
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              final newCourt = court.copyWith(name: val);
              ref.read(gameFormProvider.notifier).update(court: newCourt);
            },
          ),
        ],
      ),
    );
  }
}

class ApplyForm extends ConsumerWidget {
  final String? initMaxValue;
  final String? initMinValue;
  final List<GlobalKey> formKeys;
  final List<FocusNode> focusNodes;
  final bool isUpdateForm;

  const ApplyForm({
    super.key,
    this.initMaxValue,
    this.initMinValue,
    required this.formKeys,
    required this.focusNodes,
    this.isUpdateForm = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final max_invitation =
        ref.watch(gameFormProvider.select((value) => value.max_invitation));
    final min_invitation =
        ref.watch(gameFormProvider.select((value) => value.min_invitation));

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                focusNode: focusNodes[1],
                key: formKeys[1],
                initialValue: initMinValue,
                hintText: '00',
                label: isUpdateForm ? null : '총 모집 인원',
                textAlign: TextAlign.right,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  NumberFormatter(),
                ],
                onChanged: (val) {
                  ref
                      .read(gameFormProvider.notifier)
                      .update(min_invitation: val.replaceAll(',', ''));
                },
                prefix: Text(
                  "최소",
                  style: MITITextStyle.sm.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Text(
                    "명",
                    style: MITITextStyle.sm.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomTextFormField(
                focusNode: focusNodes[0],
                key: formKeys[0],
                initialValue: initMaxValue,
                hintText: '00',
                label: isUpdateForm ? null : '',
                textAlign: TextAlign.right,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  NumberFormatter(),
                ],
                onChanged: (val) {
                  ref
                      .read(gameFormProvider.notifier)
                      .update(max_invitation: val.replaceAll(',', ''));
                },
                prefix: Text(
                  "최대",
                  style: MITITextStyle.sm.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Text(
                    "명",
                    style: MITITextStyle.sm.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!ValidRegExp.validForm(min_invitation, max_invitation))
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.h),
              Text(
                int.parse(max_invitation) <= 0
                    ? '총 모집 인원은 0명 이상이어야해요.'
                    : '총 모집 인원은 최소 모집 인원보다 많아야해요.',
                style: TextStyle(
                  color: const Color(0xFFE92C2C),
                  fontSize: 13.sp,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.25.sp,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _FeeForm extends ConsumerWidget {
  const _FeeForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
        child: CustomTextFormField(
      hintText: '경기 참가비를 입력해주세요.',
      label: '경기 참가비',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumberFormatter(),
      ],
      onChanged: (val) {
        ref.read(gameFormProvider.notifier).update(fee: val);
      },
      suffixIcon: Text(
        '원',
        textAlign: TextAlign.center,
        style: MITITextStyle.sm.copyWith(
          color: MITIColor.gray100,
        ),
      ),
    ));
  }
}

class _AdditionalInfoForm extends ConsumerWidget {
  const _AdditionalInfoForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(gameFormProvider.select((value) => value.info));
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '참고사항',
            style: MITITextStyle.sm.copyWith(color: MITIColor.gray300),
          ),
          SizedBox(height: 10.h),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 74.h,
              maxHeight: 300.h,
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: TextField(
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: MITITextStyle.sm150.copyWith(
                    color: MITIColor.gray100,
                  ),
                  onChanged: (val) {
                    ref.read(gameFormProvider.notifier).update(info: val);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    constraints: BoxConstraints(
                      minHeight: 74.h,
                      maxHeight: 300.h,
                    ),
                    hintText:
                        '주차, 샤워 가능 여부, 경기 진행 방식, 필요한 유니폼 색상 등 참가들에게 공지할 정보들을 입력해주세요',
                    hintStyle:
                        MITITextStyle.sm150.copyWith(color: MITIColor.gray500),
                    hintMaxLines: 10,
                    fillColor: MITIColor.gray700,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    // isDense: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreeTermComponent extends ConsumerWidget {
  const _AgreeTermComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<bool> checkBoxes =
        ref.watch(gameFormProvider.select((value) => value.checkBoxes));
    final title = ['[필수] 경기 관리 및 환불 처리 약관 동의', '[선택] 경기 정보 저장 및 활용 약관'];

    return SliverToBoxAdapter(
      child: Column(
        children: [
          CustomCheckBox(
            title: '약관 전체 동의하기',
            textStyle: MITITextStyle.md.copyWith(color: MITIColor.gray100),
            isCheckBox: true,
            check: checkBoxes[0],
            onTap: () {
              ref.read(gameFormProvider.notifier).updateCheckBox(0);
            },
          ),
          Divider(
            thickness: 1.h,
            color: MITIColor.gray600,
            height: 40.h,
          ),
          ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, idx) {
                return CustomCheckBox(
                  title: title[idx],
                  textStyle:
                      MITITextStyle.sm.copyWith(color: MITIColor.gray200),
                  hasDetail: true,
                  check: checkBoxes[idx + 1],
                  onTap: () {
                    ref.read(gameFormProvider.notifier).updateCheckBox(idx + 1);
                  },
                  showDetail: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return OperationTermScreen(
                            title: '경기 운영 약관',
                            desc:
                                '본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.본 약관은 (주)핀업 (이하 회사 라 한다)에서 운영하는 핀업(https://www.finup.co.kr) 및 핀업 스탁(https://stock.finup.co.kr), 핀업 레이더(https://radar.finup.co.kr)의 사이트 (이하 합쳐서 사이트이라 한다)에서 제공하는 인터넷 관련 서비스(이하 서비스라 한다)를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.',
                            onPressed: () {
                              if (!checkBoxes[idx + 1]) {
                                ref
                                    .read(gameFormProvider.notifier)
                                    .updateCheckBox(idx + 1);
                              }
                              context.pop();
                            },
                          );
                        });
                    // Navigator.of(context).push(TutorialOverlay());
                  },
                );
              },
              separatorBuilder: (context, idx) => SizedBox(height: 16.h),
              itemCount: 2),
        ],
      ),
    );
  }
}

class OperationTermScreen extends StatelessWidget {
  final String title;
  final String desc;
  final VoidCallback onPressed;

  const OperationTermScreen(
      {super.key,
      required this.title,
      required this.desc,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: MITIColor.gray800,
        appBar: DefaultAppBar(),
        body: Padding(
          padding:
              EdgeInsets.only(top: 20.h, left: 21.w, right: 21.w, bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: MITITextStyle.xxl140.copyWith(
                  color: MITIColor.white,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        desc,
                        style: MITITextStyle.xxsmLight150.copyWith(
                          color: MITIColor.gray200,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 39.h),
              TextButton(onPressed: onPressed, child: const Text("확인")),
              SizedBox(height: 21.h),
            ],
          ),
        ),
      ),
    );
  }
}
