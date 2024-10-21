import 'dart:developer';
import 'package:kpostal/kpostal.dart';
import 'package:marquee/marquee.dart';
import 'dart:math' hide log;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/provider/widget/datetime_provider.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:miti/court/provider/court_provider.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/game/view/review_form_screen.dart';
import 'package:miti/report/model/agreement_policy_model.dart';
import 'package:miti/report/provider/report_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/custom_time_picker.dart';
import '../../common/provider/router_provider.dart';
import '../../common/view/operation_term_screen.dart';
import '../../court/component/court_list_component.dart';
import '../../util/util.dart';
import '../component/game_recent_component.dart';
import '../model/game_model.dart';
import '../model/game_recent_host_model.dart';
import '../param/game_param.dart';
import 'game_create_complete_screen.dart';

class GameCreateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'create';

  const GameCreateScreen({
    super.key,
  });

  @override
  ConsumerState<GameCreateScreen> createState() => _GameCreateScreenState();
}

class _GameCreateScreenState extends ConsumerState<GameCreateScreen> {
  late final ScrollController _scrollController;
  final formKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  late final List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final result = await ref.read(gameRecentHostingProvider.future);

      if (result is ErrorModel) {
      } else {
        final model = (result as ResponseListModel<GameRecentHostModel>).data!;
        log("model ${model.length}");
        if (model.isNotEmpty) {
          final extra = GameRecentComponent(
            models: model,
          );
          if (mounted) {
            // showDialog(context: context, builder: (_){
            //   return extra;
            // });
            context.pushNamed(DialogPage.routeName, extra: extra);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (v) => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '경기 생성하기',
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: 20.h,
            left: 21.w,
            right: 21.w,
            // bottom: bottomPadding,
          ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              const _TitleForm(),
              getSpacer(),
              const V2DateForm(),
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
              const AgreeTermComponent(),
              getSpacer(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            ref.watch(gameFormProvider);
            final result = ref.watch(agreementPolicyProvider(
                type: AgreementRequestType.game_hosting));
            bool validNext = true;

            if (result is ResponseListModel<AgreementPolicyModel>) {
              final model = (result).data!;
              final checkBoxes = ref.read(gameFormProvider).checkBoxes;
              for (int i = 0; i < model.length; i++) {
                if (model[i].is_required && !checkBoxes[i + 1]) {
                  validNext = false;
                  break;
                }
              }
            }

            final valid =
                ref.read(gameFormProvider.notifier).formValid() && validNext;
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
                              const GameCompleteType extra =
                                  GameCompleteType.create;
                              context.pushNamed(
                                GameCompleteScreen.routeName,
                                pathParameters: pathParameters,
                                extra: extra,
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
      ),
    );
  }

  SliverToBoxAdapter getSpacer({double height = 32}) => SliverToBoxAdapter(
        child: SizedBox(height: height.h),
      );
}

class _TitleForm extends StatefulWidget {
  const _TitleForm({super.key});

  @override
  State<_TitleForm> createState() => _TitleFormState();
}

class _TitleFormState extends State<_TitleForm> {
  late final TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.listen(gameFormProvider, (previous, next) {
          if (previous?.title != next.title) {
            titleController.text = next.title;
          }
        });
        final title =
            ref.watch(gameFormProvider.select((value) => value.title));
        return SliverToBoxAdapter(
            child: CustomTextFormField(
          textEditingController: titleController,
          hintText: '경기 제목을 입력해주세요.',
          label: '경기 제목',
          onTap: () {},
          onNext: () {},
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
                    final painter = TextPainter(
                        maxLines: 1,
                        textScaler: const TextScaler.linear(1.0),
                        textDirection: TextDirection.ltr,
                        text: TextSpan(
                            text: date ?? "경기 날짜와 시간을 선택해 주세요.",
                            style: MITITextStyle.md
                                .copyWith(color: MITIColor.white)));
                    painter.layout(maxWidth: 233.w);

                    log("painter.didExceedMaxLines = ${painter.didExceedMaxLines}");
                    if (painter.didExceedMaxLines) {
                      return Marquee(
                        text: date ?? "경기 날짜와 시간을 선택해 주세요.",
                        textScaleFactor: 1,
                        velocity: 20,
                        blankSpace: 20.w,
                        style: MITITextStyle.md.copyWith(
                          color: date == null
                              ? MITIColor.gray500
                              : MITIColor.gray100,
                        ),
                      );
                    }

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
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  Consumer(
                                    builder: (BuildContext context,
                                        WidgetRef ref, Widget? child) {
                                      final hasTime = ref
                                              .watch(datePickerProvider(true))
                                              .isNotEmpty &&
                                          ref
                                              .watch(datePickerProvider(false))
                                              .isNotEmpty;
                                      return Visibility(
                                          visible:
                                              hasTime && !validDateTime(ref),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              SizedBox(height: 20.h),
                                              Text(
                                                "경기 종료 시간이 시작 시간의 이후가 되도록 설정해 주세요.",
                                                style: MITITextStyle.xxsm
                                                    .copyWith(
                                                        color: MITIColor.error),
                                              ),
                                            ],
                                          ));
                                    },
                                  ),
                                  SizedBox(height: 40.h),
                                  Consumer(
                                    builder: (BuildContext context,
                                        WidgetRef ref, Widget? child) {
                                      final valid = validDateTime(ref);

                                      return TextButton(
                                        onPressed: valid
                                            ? () {
                                                selectDay(ref);
                                              }
                                            : null,
                                        style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(valid
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

  bool validDateTime(WidgetRef ref) {
    final start = ref.watch(datePickerProvider(true));
    final end = ref.watch(datePickerProvider(false));

    final format = DateFormat("yyyy / MM / dd (EEE) HH:mm", 'ko');
    if (start.isNotEmpty && end.isNotEmpty) {
      final startParse = format.parse(start);
      final endParse = format.parse(end);

      final validNum = startParse.compareTo(endParse);
      if (validNum < 0) {
        return true;
      } else {
        return false;
      }
    }
    return false;
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
                  Transform.rotate(
                    angle: isOpen ? 0 : 180 * pi / 180,
                    child: SvgPicture.asset(
                      AssetUtil.getAssetPath(
                          type: AssetType.icon, name: "top_arrow"),
                    ),
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
              : const SizedBox.shrink(),
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
                                const extra = CourtListComponent();
                                context.pushNamed(DialogPage.routeName,
                                    extra: extra);
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
  void dispose() {
    addressController.dispose();
    addressDetailController.dispose();
    nameController.dispose();
    super.dispose();
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

class ApplyForm extends ConsumerStatefulWidget {
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
  ConsumerState<ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends ConsumerState<ApplyForm> {
  late final TextEditingController maxController;
  late final TextEditingController minController;

  @override
  void initState() {
    super.initState();
    maxController = TextEditingController(text: widget.initMaxValue);
    minController = TextEditingController(text: widget.initMinValue);
  }

  @override
  void dispose() {
    maxController.dispose();
    minController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    ref.listen(gameFormProvider, (previous, next) {
      if (previous?.max_invitation != next.max_invitation) {
        maxController.text = next.max_invitation;
      }
      if (previous?.min_invitation != next.min_invitation) {
        minController.text = next.min_invitation;
      }
    });

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
                textEditingController: minController,
                focusNode: widget.focusNodes[1],
                key: widget.formKeys[1],
                // initialValue: widget.initMinValue,
                hintText: '00',
                label: widget.isUpdateForm ? null : '총 모집 인원',
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
                textEditingController: maxController,
                focusNode: widget.focusNodes[0],
                key: widget.formKeys[0],
                // initialValue: widget.initMaxValue,
                hintText: '00',
                label: widget.isUpdateForm ? null : '',
                textAlign: TextAlign.right,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                borderColor:
                    !ValidRegExp.validForm(min_invitation, max_invitation)
                        ? MITIColor.error
                        : null,
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
                int.parse(max_invitation) < 1
                    ? '총 모집 인원은 1명 이상이어야해요.'
                    : '총 모집 인원은 최소 모집 인원보다 많아야해요.',
                style: MITITextStyle.xxsm.copyWith(color: MITIColor.error),
              ),
            ],
          ),
      ],
    );
  }
}

class _FeeForm extends ConsumerStatefulWidget {
  const _FeeForm({super.key});

  @override
  ConsumerState<_FeeForm> createState() => _FeeFormState();
}

class _FeeFormState extends ConsumerState<_FeeForm> {
  late final TextEditingController feeController;

  @override
  void initState() {
    super.initState();
    feeController = TextEditingController();
  }

  @override
  void dispose() {
    feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameFormProvider, (previous, next) {
      if (previous?.fee != next.fee) {
        feeController.text = next.fee;
      }
    });
    final fee = ref.watch(gameFormProvider.select((value) => value.fee));
    return SliverToBoxAdapter(
        child: CustomTextFormField(
      textEditingController: feeController,
      hintText: '경기 참가비를 입력해주세요.',
      label: '경기 참가비',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      // textAlign: fee.isNotEmpty ? TextAlign.right : TextAlign.left,
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

class _AdditionalInfoForm extends ConsumerStatefulWidget {
  const _AdditionalInfoForm({super.key});

  @override
  ConsumerState<_AdditionalInfoForm> createState() =>
      _AdditionalInfoFormState();
}

class _AdditionalInfoFormState extends ConsumerState<_AdditionalInfoForm> {
  late final TextEditingController infoController;

  @override
  void initState() {
    super.initState();
    infoController = TextEditingController();
  }

  @override
  void dispose() {
    infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameFormProvider, (previous, next) {
      if (previous?.info != next.info) {
        infoController.text = next.info;
      }
    });
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
          IntrinsicHeight(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: 200.h,
                  minHeight: 74.h,
                  maxWidth: double.infinity,
                  minWidth: double.infinity),
              child: MultiLineTextFormField(
                editTextController: infoController,
                onChanged: (val) {
                  ref.read(gameFormProvider.notifier).update(info: val);
                },
                hint:
                    '주차, 샤워 가능 여부, 경기 진행 방식, 필요한 유니폼 색상 등 참가들에게 공지할 정보들을 입력해주세요',
                context: context,
              ),
            ),
          ),
          // ConstrainedBox(
          //   constraints: BoxConstraints(
          //     minHeight: 74.h,
          //     maxHeight: 300.h,
          //   ),
          //   child: Scrollbar(
          //     child: SingleChildScrollView(
          //       scrollDirection: Axis.vertical,
          //       reverse: true,
          //       child: TextField(
          //         maxLines: null,
          //         controller: infoController,
          //         textAlignVertical: TextAlignVertical.top,
          //         style: MITITextStyle.sm150.copyWith(
          //           color: MITIColor.gray100,
          //         ),
          //         onChanged: (val) {
          //           ref.read(gameFormProvider.notifier).update(info: val);
          //         },
          //         decoration: InputDecoration(
          //           border: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(8.r),
          //             borderSide: BorderSide.none,
          //           ),
          //           constraints: BoxConstraints(
          //             minHeight: 74.h,
          //             maxHeight: 300.h,
          //           ),
          //           hintText:
          //               '주차, 샤워 가능 여부, 경기 진행 방식, 필요한 유니폼 색상 등 참가들에게 공지할 정보들을 입력해주세요',
          //           hintStyle:
          //               MITITextStyle.sm150.copyWith(color: MITIColor.gray500),
          //           hintMaxLines: 10,
          //           fillColor: MITIColor.gray700,
          //           filled: true,
          //           contentPadding:
          //               EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          //           // isDense: true,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class AgreeTermComponent extends ConsumerWidget {
  const AgreeTermComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(
        agreementPolicyProvider(type: AgreementRequestType.game_hosting));
    if (result is LoadingModel) {
      return SliverToBoxAdapter(child: CircularProgressIndicator());
    } else if (result is ErrorModel) {
      return const SliverToBoxAdapter(child: Text('error'));
    }
    final model = (result as ResponseListModel<AgreementPolicyModel>).data!;

    List<bool> checkBoxes =
        ref.watch(gameFormProvider.select((value) => value.checkBoxes));
    final title = model.map((e) {
      log('e.policy.name = ${e.policy.name}');
      return '${e.is_required ? '[필수] ' : '[선택] '} ${e.policy.name}';
    }).toList();

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
                        barrierColor: MITIColor.gray800,
                        builder: (context) {
                          return OperationTermScreen(
                            title: model[idx].policy.name,
                            desc: model[idx].policy.content,
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
              itemCount: title.length),
        ],
      ),
    );
  }
}
