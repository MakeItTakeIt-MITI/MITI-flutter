import 'dart:developer';
import 'dart:math' hide log;

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:kpostal/kpostal.dart';
import 'package:marquee/marquee.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:miti/common/component/custom_bottom_sheet.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/component/form/prefix_input_form.dart';
import 'package:miti/common/model/cursor_model.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/game/view/review_form_screen.dart';
import 'package:miti/report/model/agreement_policy_model.dart';
import 'package:miti/report/provider/report_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/picker/custom_time_picker.dart';
import '../../common/provider/widget/form_provider.dart';
import '../../common/view/operation_term_screen.dart';
import '../../court/component/court_list_component.dart';
import '../../court/model/v2/court_map_response.dart';
import '../../court/model/v2/court_operations_response.dart';
import '../../court/param/court_pagination_param.dart';
import '../../court/provider/court_pagination_provider.dart';
import '../../util/util.dart';
import '../component/game_recent_component.dart';
import '../model/v2/game/game_detail_response.dart';
import '../model/v2/game/game_with_court_response.dart';
import '../param/game_param.dart';
import 'game_create_complete_screen.dart';

class GameCreateScreen extends ConsumerStatefulWidget {
  final CourtOperationsResponse? court;

  static String get routeName => 'create';

  const GameCreateScreen({
    this.court,
    super.key,
  });

  @override
  ConsumerState<GameCreateScreen> createState() => _GameCreateScreenState();
}

class _GameCreateScreenState extends ConsumerState<GameCreateScreen> {
  late Throttle<int> _throttler;
  int throttleCnt = 0;
  late final ScrollController _scrollController;
  late final List<TextEditingController> textEditingControllers;
  bool isLoading = false;
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
    textEditingControllers = List.generate(8, (_) => TextEditingController());

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
      await _onCreate(ref, context);
      setState(() {
        isLoading = false;
      });
    });
    _scrollController = ScrollController();
    for (int i = 0; i < formKeys.length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          focusScrollable(i, formKeys);
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final result = ref.watch(
          agreementPolicyProvider(type: AgreementRequestType.game_hosting));
      if (result is ResponseListModel<AgreementPolicyModel>) {
        final List<bool> checkBoxes =
            List.generate(result.data!.length + 1, (e) => false);
        ref.read(gameFormProvider.notifier).update(checkBoxes: checkBoxes);
      }

      if (widget.court == null) {
        final result = await ref.read(gameRecentHostingProvider.future);

        if (result is ErrorModel) {
        } else {
          final model =
              (result as ResponseListModel<GameWithCourtResponse>).data!;
          if (model.isNotEmpty) {
            CustomBottomSheet.showWidgetContent(
              title: '최근 경기 목록',
              hasPop: true,
              context: context,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        "최근 게스트를 모집한 경기 목록입니다.\n같은 정보로 경기를 생성하시겠습니까?",
                        style: V2MITITextStyle.tinyRegularNormal.copyWith(
                          color: V2MITIColor.gray3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (_, idx) {
                        return GameBottomSheetCard.fromRecentModel(
                          model: model[idx],
                        );
                      },
                      separatorBuilder: (_, idx) => SizedBox(
                        height: 12.h,
                      ),
                      itemCount: model.length),
                  SizedBox(height: 20.h),
                  Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      final selected = ref.watch(selectedProvider);
                      return TextButton(
                          onPressed: selected != null
                              ? () {
                            selectRecentGame(model, selected, ref, context);
                          }
                              : () {},
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(selected != null
                                  ? V2MITIColor.primary5
                                  : V2MITIColor.gray7)),
                          child: Text(
                            "정보 불러오기",
                            style: V2MITITextStyle.regularBold.copyWith(
                                color: selected != null
                                    ? V2MITIColor.black
                                    : V2MITIColor.white),
                          ));
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
              buttonText: '정보 불라오기',
            );
          }
        }
      } else {
        final name = widget.court?.name ?? '';
        final address = widget.court?.address ?? '';
        final addressDetail = widget.court?.addressDetail ?? '';
        ref.read(gameFormProvider.notifier).update(
              court: GameCourtParam(
                name: name,
                address: address,
                address_detail: addressDetail,
              ),
            );
        textEditingControllers[1].text = address;
        textEditingControllers[2].text = addressDetail;
        textEditingControllers[3].text = name;
      }
    });
  }

  void selectRecentGame(List<GameWithCourtResponse> models, int selected,
      WidgetRef ref, BuildContext context) {
    final model = models.firstWhere((m) => m.id == selected);
    ref.read(gameFormProvider.notifier).selectGameHistory(
        model: model, textEditingControllers: textEditingControllers);
    context.pop();
  }

  @override
  void dispose() {
    _throttler.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '경기 생성하기',
        ),
        body: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            // bottom: bottomPadding,
          ),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            controller: _scrollController,
            slivers: <Widget>[
              // const SliverToBoxAdapter(child: GameQuillComponent()),
              getSpacer(height: 12),
              _TitleForm(
                focusNode: focusNodes[0],
                globalKey: formKeys[0],
                titleController: textEditingControllers[0],
              ),
              getSpacer(),
              const V2DateForm(),
              getSpacer(),
              _AddressForm(
                focusNodes: focusNodes,
                globalKeys: formKeys,
                textEditingControllers: textEditingControllers.sublist(1, 4),
              ),
              getSpacer(),
              SliverToBoxAdapter(
                  child: ApplyForm(
                formKeys: formKeys.sublist(3),
                focusNodes: focusNodes.sublist(3),
                textEditingControllers: textEditingControllers.sublist(4, 6),
              )),
              getSpacer(),
              _FeeForm(
                formKeys: formKeys,
                focusNodes: focusNodes,
                textEditingController: textEditingControllers[6],
              ),
              getSpacer(),
              _AdditionalInfoForm(
                formKeys: formKeys,
                focusNodes: focusNodes,
                textEditingController: textEditingControllers[7],
              ),
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
                  onPressed: valid && !isLoading
                      ? () async {
                          _throttler.setValue(throttleCnt + 1);
                        }
                      : () {},
                  style: TextButton.styleFrom(
                      backgroundColor: valid && !isLoading
                          ? V2MITIColor.primary5
                          : MITIColor.gray500,
                      fixedSize: Size(double.infinity, 48.h)),
                  child: Text(
                    '경기 생성하기',
                    style: TextStyle(
                      color: valid && !isLoading
                          ? MITIColor.gray800
                          : MITIColor.gray50,
                    ),
                  )),
            ));
          },
        ),
      ),
    );
  }

  Future<void> _onCreate(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(gameCreateProvider.future);
    if (context.mounted) {
      if (result is ErrorModel) {
        GameError.fromModel(model: result)
            .responseError(context, GameApiType.createGame, ref);
      } else {
        final model = result as ResponseModel<GameDetailResponse>;
        Map<String, String> pathParameters = {
          'gameId': model.data!.id.toString()
        };
        const GameCompleteType extra = GameCompleteType.create;
        context.pushNamed(
          GameCompleteScreen.routeName,
          pathParameters: pathParameters,
          extra: extra,
        );
      }
    }
  }

  SliverToBoxAdapter getSpacer({double height = 20}) => SliverToBoxAdapter(
        child: SizedBox(height: height.h),
      );
}

class _TitleForm extends StatefulWidget {
  final FocusNode focusNode;
  final GlobalKey globalKey;
  final TextEditingController titleController;

  const _TitleForm(
      {super.key,
      required this.focusNode,
      required this.globalKey,
      required this.titleController});

  @override
  State<_TitleForm> createState() => _TitleFormState();
}

class _TitleFormState extends State<_TitleForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return SliverToBoxAdapter(
            child: CustomTextFormField(
          required: true,
          textEditingController: widget.titleController,
          hintText: '경기 제목을 입력해주세요.',
          label: '경기 제목',
          borderColor: V2MITIColor.gray6,
          key: widget.globalKey,
          focusNode: widget.focusNode,
          onTap: () => FocusScope.of(context).requestFocus(widget.focusNode),
          onNext: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          onChanged: (val) {
            log('title value = $val');
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "경기 시간",
                style: V2MITITextStyle.smallRegularNormal.copyWith(
                  color: V2MITIColor.white,
                ),
              ),
              Container(
                height: 4.r,
                width: 4.r,
                alignment: Alignment.center,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: V2MITIColor.primary5,
                  ),
                  width: 2.r,
                  height: 2.r,
                ),
              )
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.r,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        4.r,
                      ),
                      border: Border.all(color: V2MITIColor.gray6)),
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
                              style: V2MITITextStyle.regularMediumNormal
                                  .copyWith(color: V2MITIColor.white)));
                      painter.layout(maxWidth: 233.w);

                      log("painter.didExceedMaxLines = ${painter.didExceedMaxLines}");
                      if (painter.didExceedMaxLines) {
                        return Marquee(
                          text: date ?? "경기 날짜와 시간을 선택해 주세요.",
                          textScaleFactor: 1,
                          velocity: 20,
                          blankSpace: 20.w,
                          style: V2MITITextStyle.regularMediumNormal.copyWith(
                            color: date == null
                                ? V2MITIColor.gray6
                                : V2MITIColor.white,
                          ),
                        );
                      }

                      return Text(
                        date ?? "경기 날짜와 시간을 선택해 주세요.",
                        style: V2MITITextStyle.regularMediumNormal.copyWith(
                          color: date == null
                              ? V2MITIColor.gray6
                              : V2MITIColor.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  showCustomModalBottomSheet(
                      context,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          MaterialTapTargetSize.shrinkWrap),
                                  constraints:
                                      BoxConstraints.tight(Size(24.r, 24.r)),
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
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              final hasTime = ref
                                      .watch(datePickerProvider(true))
                                      .isNotEmpty &&
                                  ref
                                      .watch(datePickerProvider(false))
                                      .isNotEmpty;
                              return Visibility(
                                  visible: hasTime && !validDateTime(ref),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: 20.h),
                                      Text(
                                        "경기 종료 시간이 시작 시간의 이후가 되도록 설정해 주세요.",
                                        style: MITITextStyle.xxsm
                                            .copyWith(color: V2MITIColor.red5),
                                      ),
                                    ],
                                  ));
                            },
                          ),
                          SizedBox(height: 40.h),
                          Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              final valid = validDateTime(ref);

                              return TextButton(
                                onPressed: valid
                                    ? () {
                                        selectDay(ref);
                                      }
                                    : null,
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        valid
                                            ? V2MITIColor.primary5
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
                      ));
                },
                child: Container(
                  height: 44.r,
                  width: 44.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: V2MITIColor.primary5,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    height: 24.r,
                    width: 24.r,
                    colorFilter: const ColorFilter.mode(
                        V2MITIColor.black, BlendMode.srcIn),
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

    final parsingStart = parseDate(startDate);
    final parsingEnd = parseDate(endDate);

    log('parsingStart = $parsingStart');
    log('parsingEnd = $parsingEnd');

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
    final inputFormat = DateFormat("yyyy / MM / dd (E) HH:mm", "ko_KR");
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
                          color: V2MITIColor.primary5,
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
        background: V2MITIColor.white.withOpacity(0.1),
      ),
      children: List.generate(
          12,
          (index) => Align(
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: MITITextStyle.md.copyWith(
                    color:
                        v == index ? V2MITIColor.primary5 : MITIColor.gray300,
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

class AddressComponent extends StatefulWidget {
  final GameCourtParam court;
  final LoadCourtInfoCallback loadCallback;

  const AddressComponent(
      {super.key, required this.court, required this.loadCallback});

  @override
  State<AddressComponent> createState() => _AddressComponentState();
}

class _AddressComponentState extends State<AddressComponent> {
  @override
  Widget build(BuildContext context) {
    final address = widget.court.address;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '경기 주소',
              style: V2MITITextStyle.smallRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            Container(
              height: 4.r,
              width: 4.r,
              alignment: Alignment.center,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: V2MITIColor.primary5,
                ),
                width: 2.r,
                height: 2.r,
              ),
            )
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44.h,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    side: const BorderSide(color: V2MITIColor.gray6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12.w),
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          address.isEmpty ? '주소를 검색해주세요.' : address,
                          style: V2MITITextStyle.regularMediumNormal.copyWith(
                              color: address.isEmpty
                                  ? V2MITIColor.gray6
                                  : V2MITIColor.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              height: 44.h,
              width: 96.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    _AddressComponentState? parent = context
                        .findAncestorStateOfType<_AddressComponentState>();

                    return TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KpostalView(
                              callback: (Kpostal kpostal) async {
                                log('result  =${kpostal.roadAddress}');
                                final newCourt = widget.court
                                    .copyWith(address: kpostal.roadAddress);
                                ref
                                    .read(gameFormProvider.notifier)
                                    .update(court: newCourt);
                                Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () async {
                                  if (mounted) {
                                    final search = ref
                                        .read(gameFormProvider)
                                        .court
                                        .address;
                                    final param =
                                        CourtPaginationParam(search: search);
                                    final result = await ref.read(
                                        courtSinglePageProvider(param: param)
                                            .future);
                                    if (result is ResponseModel<
                                        CursorPaginationModel<
                                            CourtMapResponse>>) {
                                      final model = (result).data!.items;

                                      if (model.isNotEmpty) {
                                        await showCustomModalBottomSheet(
                                            parent!.context,
                                            CourtListComponent(
                                              loadCallback: widget.loadCallback,
                                              models: model,
                                            ));
                                      }
                                    }
                                  }

                                  log("show!! modal");
                                });
                              },
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: V2MITIColor.primary5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r))),
                      child: Text(
                        '주소검색',
                        style: V2MITITextStyle.regularBold.copyWith(
                          color: V2MITIColor.black,
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
  final List<FocusNode> focusNodes;
  final List<GlobalKey> globalKeys;
  final List<TextEditingController> textEditingControllers;

  const _AddressForm({
    super.key,
    required this.focusNodes,
    required this.globalKeys,
    required this.textEditingControllers,
  });

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
    addressController = widget.textEditingControllers[0];
    addressDetailController = widget.textEditingControllers[1];
    nameController = widget.textEditingControllers[2];
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
    return SliverToBoxAdapter(
      child: Column(
        children: [
          AddressComponent(
            court: court,
            loadCallback: (GameCourtParam court) {
              addressController.text = court.address;
              addressDetailController.text = court.address_detail ?? '';
              nameController.text = court.name;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            key: widget.globalKeys[1],
            focusNode: widget.focusNodes[1],
            textInputAction: TextInputAction.next,
            onTap: () =>
                FocusScope.of(context).requestFocus(widget.focusNodes[1]),
            onNext: () {
              log("focus Node");
              FocusScope.of(context).requestFocus(widget.focusNodes[2]);
            },
            hintText: '(선택) 상세 주소를 입력해주세요.',
            label: '경기 상세 주소',
            textEditingController: addressDetailController,
            borderColor: V2MITIColor.gray6,
            onChanged: (val) {
              final newCourt = court.copyWith(address_detail: val);
              ref.read(gameFormProvider.notifier).update(court: newCourt);
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            required: true,
            key: widget.globalKeys[2],
            focusNode: widget.focusNodes[2],
            textInputAction: TextInputAction.next,
            onTap: () =>
                FocusScope.of(context).requestFocus(widget.focusNodes[2]),
            onNext: () =>
                FocusScope.of(context).requestFocus(widget.focusNodes[3]),
            textEditingController: nameController,
            hintText: '경기장 이름을 입력해주세요.',
            label: '경기장 이름',
            borderColor: V2MITIColor.gray6,
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
  final List<TextEditingController>? textEditingControllers;

  const ApplyForm({
    super.key,
    this.initMaxValue,
    this.initMinValue,
    required this.formKeys,
    required this.focusNodes,
    this.isUpdateForm = false,
    this.textEditingControllers,
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
    maxController = widget.textEditingControllers != null
        ? widget.textEditingControllers![0]
        : TextEditingController(text: widget.initMaxValue);
    if (widget.initMaxValue != null) {
      maxController.text = widget.initMaxValue.toString();
    }
    minController = widget.textEditingControllers != null
        ? widget.textEditingControllers![1]
        : TextEditingController(text: widget.initMinValue);
    if (widget.initMinValue != null) {
      minController.text = widget.initMinValue.toString();
    }
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
      if (previous?.max_invitation != next.max_invitation &&
          next.max_invitation.isNotEmpty) {
        /// 중간에 입력할 경우 offset이 맨 뒤로 가는 문제를 방지
        // 새로 입력된 값을 포멧
        log('previous max invitation = ${previous?.max_invitation}');
        log('next max invitation = ${next.max_invitation}');
        final int parsedValue = int.parse(next
            .max_invitation); // NumberFormat은 숫자 값만 받을 수 있기 때문에 문자를 숫자로 먼저 변환
        final formatter = NumberFormat
            .decimalPattern(); // 천단위로 콤마를 표시하고 숫자 앞에 화폐 기호 표시하는 패턴 설정
        String newText = formatter.format(parsedValue); // 입력된 값을 지정한 패턴으로 포멧
        maxController.text = newText;

        maxController.selection = maxController.selection.copyWith(
          baseOffset: newText.length,
          extentOffset: newText.length,
        );
      }
      if (previous?.min_invitation != next.min_invitation &&
          next.min_invitation.isNotEmpty) {
        /// 중간에 입력할 경우 offset이 맨 뒤로 가는 문제를 방지
        // 새로 입력된 값을 포멧
        final int parsedValue = int.parse(next
            .min_invitation); // NumberFormat은 숫자 값만 받을 수 있기 때문에 문자를 숫자로 먼저 변환
        final formatter = NumberFormat
            .decimalPattern(); // 천단위로 콤마를 표시하고 숫자 앞에 화폐 기호 표시하는 패턴 설정
        String newText = formatter.format(parsedValue); // 입력된 값을 지정한 패턴으로 포멧
        minController.text = newText;

        minController.selection = minController.selection.copyWith(
          baseOffset: newText.length,
          extentOffset: newText.length,
        );
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
      spacing: 4.h,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '모집인원',
              style: V2MITITextStyle.smallRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            Container(
              height: 4.r,
              width: 4.r,
              alignment: Alignment.center,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: V2MITIColor.primary5,
                ),
                width: 2.r,
                height: 2.r,
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: PrefixInputForm(
                textEditingController: minController,
                focusNode: widget.focusNodes[0],
                key: widget.formKeys[0],
                onTap: () =>
                    FocusScope.of(context).requestFocus(widget.focusNodes[0]),
                onNext: () =>
                    FocusScope.of(context).requestFocus(widget.focusNodes[1]),
                hintText: '00',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (val) {
                  ref
                      .read(gameFormProvider.notifier)
                      .update(min_invitation: val.replaceAll(',', ''));
                },
                prefix: Text(
                  '최대',
                  style: V2MITITextStyle.regularMediumNormal
                      .copyWith(color: V2MITIColor.white),
                ),
                suffixIcon: Text(
                  '명',
                  style: V2MITITextStyle.regularMediumNormal
                      .copyWith(color: V2MITIColor.white),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PrefixInputForm(
                textEditingController: maxController,
                focusNode: widget.focusNodes[1],
                key: widget.formKeys[1],
                onTap: () =>
                    FocusScope.of(context).requestFocus(widget.focusNodes[1]),
                onNext: () =>
                    FocusScope.of(context).requestFocus(widget.focusNodes[2]),
                hintText: '00',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
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
                '총 모집 인원은 최소 모집 이상이어야 해요.',
                style: MITITextStyle.xxsm.copyWith(color: V2MITIColor.red5),
              ),
            ],
          ),
      ],
    );
  }
}

class _FeeForm extends ConsumerStatefulWidget {
  final List<GlobalKey> formKeys;
  final List<FocusNode> focusNodes;
  final TextEditingController textEditingController;

  const _FeeForm({
    super.key,
    required this.formKeys,
    required this.focusNodes,
    required this.textEditingController,
  });

  @override
  ConsumerState<_FeeForm> createState() => _FeeFormState();
}

class _FeeFormState extends ConsumerState<_FeeForm> {
  late final TextEditingController feeController;

  @override
  void initState() {
    super.initState();
    feeController = widget.textEditingController;
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
        /// 중간에 입력할 경우 offset이 맨 뒤로 가는 문제를 방지
        // 새로 입력된 값을 포멧
        final int parsedValue = int.parse(
            next.fee); // NumberFormat은 숫자 값만 받을 수 있기 때문에 문자를 숫자로 먼저 변환
        final formatter = NumberFormat
            .decimalPattern(); // 천단위로 콤마를 표시하고 숫자 앞에 화폐 기호 표시하는 패턴 설정
        String newText = formatter.format(parsedValue); // 입력된 값을 지정한 패턴으로 포멧
        feeController.text = newText;

        feeController.selection = feeController.selection.copyWith(
          baseOffset: newText.length,
          extentOffset: newText.length,
        );
      }
    });
    final fee = ref.watch(gameFormProvider.select((value) => value.fee));
    final formInfo = ref.watch(formInfoProvider(InputFormType.fee));
    return SliverToBoxAdapter(
        child: CustomTextFormField(
      required: true,
      textEditingController: feeController,
      hintText: '경기 참가비를 입력해주세요.',
      label: '경기 참가비',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      focusNode: widget.focusNodes[5],
      key: widget.formKeys[5],
      borderColor: formInfo.borderColor,
      onTap: () => FocusScope.of(context).requestFocus(widget.focusNodes[5]),
      onNext: () => FocusScope.of(context).requestFocus(widget.focusNodes[6]),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      interactionDesc: formInfo.interactionDesc,
      onChanged: (val) {
        ref.read(gameFormProvider.notifier).update(fee: val);
        if (ref.read(gameFormProvider.notifier).validFee()) {
          ref.read(formInfoProvider(InputFormType.fee).notifier).reset();
        } else {
          ref.read(formInfoProvider(InputFormType.fee).notifier).update(
                borderColor: V2MITIColor.red5,
                interactionDesc: InteractionDesc(
                  isSuccess: false,
                  desc: "참가비는 0원 혹은 500원 이상이어야합니다.",
                ),
              );
        }
      },
      suffixIcon: Text(
        '원',
        textAlign: TextAlign.center,
        style: V2MITITextStyle.regularMediumNormal.copyWith(
          color: V2MITIColor.white,
        ),
      ),
    ));
  }
}

class _AdditionalInfoForm extends ConsumerStatefulWidget {
  final List<GlobalKey> formKeys;
  final List<FocusNode> focusNodes;
  final TextEditingController textEditingController;

  const _AdditionalInfoForm({
    super.key,
    required this.formKeys,
    required this.focusNodes,
    required this.textEditingController,
  });

  @override
  ConsumerState<_AdditionalInfoForm> createState() =>
      _AdditionalInfoFormState();
}

class _AdditionalInfoFormState extends ConsumerState<_AdditionalInfoForm> {
  late final TextEditingController infoController;

  @override
  void initState() {
    super.initState();
    infoController = widget.textEditingController;
  }

  @override
  void dispose() {
    infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(gameFormProvider.select((value) => value.info));
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '경기 운영 정보',
                style: V2MITITextStyle.smallRegularNormal
                    .copyWith(color: V2MITIColor.white),
              ),
              Container(
                height: 4.r,
                width: 4.r,
                alignment: Alignment.center,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: V2MITIColor.primary5,
                  ),
                  width: 2.r,
                  height: 2.r,
                ),
              )
            ],
          ),
          SizedBox(height: 4.h),
          IntrinsicHeight(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: 200.h,
                  minHeight: 74.h,
                  maxWidth: double.infinity,
                  minWidth: double.infinity),
              child: MultiLineTextFormField(
                editTextController: infoController,
                focusNode: widget.focusNodes[6],
                key: widget.formKeys[6],
                onTap: () =>
                    FocusScope.of(context).requestFocus(widget.focusNodes[6]),
                onChanged: (val) {
                  ref.read(gameFormProvider.notifier).update(info: val);
                },
                hint:
                    '주차, 샤워 가능 여부, 경기 진행 방식, 필요한 유니폼 색상 등 참가들에게 공지할 정보들을 입력해주세요',
                context: context,
              ),
            ),
          ),
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
