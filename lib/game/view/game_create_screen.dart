import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kpostal/kpostal.dart';
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
            left: 21.w,
            right: 21.w,
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              getSpacer(height: 20),
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
              getSpacer(height: 19),
              SliverToBoxAdapter(child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final valid =
                      ref.watch(gameFormProvider.notifier).formValid();
                  return SizedBox(
                    height: 48.h,
                    child: TextButton(
                        onPressed: valid
                            ? () async {
                                final result =
                                    await ref.read(gameCreateProvider.future);
                                if (context.mounted) {
                                  if (result is ErrorModel) {
                                    GameError.fromModel(model: result)
                                        .responseError(context,
                                            GameApiType.createGame, ref);
                                  } else {
                                    final model = result
                                        as ResponseModel<GameDetailModel>;
                                    Map<String, String> pathParameters = {
                                      'gameId': model.data!.id.toString()
                                    };
                                    final Map<String, String> queryParameters =
                                        {
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
                  );
                },
              )),
              getSpacer(height: 8),
            ],
          ),
        ),
      ),
    );
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
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
            left: 16.w,
            right: 16.w,
            bottom: bottomPadding,
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              getSpacer(height: 18),
              SliverToBoxAdapter(
                child: Text(
                  '경기 정보',
                  style: TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 16.sp,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25.sp,
                  ),
                ),
              ),
              getSpacer(),
              const _TitleForm(),
              getSpacer(),
              const _DateForm(),
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
              getSpacer(height: 19),
              SliverToBoxAdapter(child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final valid =
                      ref.watch(gameFormProvider.notifier).formValid();
                  return SizedBox(
                    height: 48.h,
                    child: TextButton(
                        onPressed: valid
                            ? () async {
                                final result =
                                    await ref.read(gameCreateProvider.future);
                                if (context.mounted) {
                                  if (result is ErrorModel) {
                                    GameError.fromModel(model: result)
                                        .responseError(context,
                                            GameApiType.createGame, ref);
                                  } else {
                                    final model = result
                                        as ResponseModel<GameDetailModel>;
                                    Map<String, String> pathParameters = {
                                      'gameId': model.data!.id.toString()
                                    };
                                    final Map<String, String> queryParameters =
                                        {
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
                            backgroundColor: valid
                                ? const Color(0xFF4065F6)
                                : const Color(0xFFE8E8E8),
                            fixedSize: Size(double.infinity, 48.h)),
                        child: Text(
                          '경기 생성하기',
                          style: TextStyle(
                            color:
                                valid ? Colors.white : const Color(0xFF969696),
                          ),
                        )),
                  );
                },
              )),
              getSpacer(height: 8),
            ],
          ),
        ),
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

class V2DateForm extends StatefulWidget {
  const V2DateForm({super.key});

  @override
  State<V2DateForm> createState() => _V2DateFormState();
}

class DatePickerSpinner extends StatefulWidget {
  final double? height;
  final double? width;
  final int? interval;
  final DateTime date;
  final Function(String) onChanged;

  const DatePickerSpinner({
    super.key,
    this.height,
    this.width,
    this.interval,
    required this.date,
    required this.onChanged,
  });

  @override
  State<DatePickerSpinner> createState() => _DatePickerSpinnerState();
}

class _DatePickerSpinnerState extends State<DatePickerSpinner> {
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  List<String> _year = [];
  final List<String> _month = List.generate(
      12, (index) => index < 9 ? "0${index + 1}" : "${index + 1}");
  List<String> _day = [];
  late double _width;
  late double _height;
  late Size _itemSize;
  late ValueNotifier<String> currentDate;

  @override
  void initState() {
    currentDate = ValueNotifier(
        widget.date.toString().replaceAll("-", "").substring(0, 8));
    _width = 400;
    _height = 760;
    _itemSize = Size(_width / 3, _height);
    int _currentYear = DateTime.now().year;
    _year = List.generate(
        widget.interval == null || widget.interval == 0
            ? 100
            : widget.interval!,
        (index) => widget.interval == null || widget.interval! < 1
            ? "${index + (_currentYear - 50)}"
            : "${index + (_currentYear - (widget.interval == 1 ? 0 : widget.interval! ~/ 2))}");
    _daySetting(true);
    int _initialYear = _year.indexOf(currentDate.value.substring(0, 4));
    int _initialMonth = _month.indexOf(currentDate.value.substring(4, 6));
    int _initialDay = _day.indexOf(currentDate.value.substring(6, 8));
    _yearController = FixedExtentScrollController(initialItem: _initialYear);
    _monthController = FixedExtentScrollController(initialItem: _initialMonth);
    _dayController = FixedExtentScrollController(initialItem: _initialDay);
    super.initState();
  }

  void _changedDate(int dateType, int index) {
    String _currentYear = currentDate.value.substring(0, 4);
    String _currentMonth = currentDate.value.substring(4, 6);
    String _currentDay = currentDate.value.substring(6, 8);

    switch (dateType) {
      case 0:
        currentDate.value = _year[index] + _currentMonth + _currentDay;
        if (_currentMonth == "02") {
          _leapYearChecked();
        }
        break;
      case 1:
        currentDate.value = _currentYear + _month[index] + _currentDay;
        _daySetting(false);
        break;
      case 2:
        currentDate.value = _currentYear + _currentMonth + _day[index];
        break;
      default:
    }
  }

  void _daySetting(bool initial) {
    int _month = int.parse(currentDate.value.substring(4, 6));
    List _thiryFirst = [1, 3, 5, 7, 8, 10, 12];
    int _selectedDayItem = !initial ? _dayController.selectedItem : 0;
    if (_thiryFirst.contains(_month)) {
      _day = List.generate(
          31, (index) => index < 9 ? "0${index + 1}" : "${index + 1}");
    } else if (_month == 2) {
      _leapYearChecked();
      if (_day.length <= _selectedDayItem) {
        _dayController.jumpToItem(_day.length - 1);
      }
    } else {
      _day = List.generate(
          30, (index) => index < 9 ? "0${index + 1}" : "${index + 1}");
      if (_selectedDayItem == 30) {
        _dayController.jumpToItem(29);
      }
    }
  }

  void _leapYearChecked() {
    int _dayLength = 0;
    int _year = int.parse(currentDate.value.substring(0, 4));
    if (((_year % 4 == 0) && (_year % 100 != 0)) || (_year % 400 == 0)) {
      _dayLength = 29;
    } else {
      _dayLength = 28;
    }
    _day = List.generate(
        _dayLength, (index) => index < 9 ? "0${index + 1}" : "${index + 1}");
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: currentDate,
        builder: (context, value, child) {
          return Container(
            height: 96.h,
            width: _width,
            color: MITIColor.gray700,
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                _pickerForm(
                    controller: _yearController,
                    date: _year,
                    dateIndex: 0,
                    current: value.substring(0, 4)),
                _pickerForm(
                    controller: _monthController,
                    date: _month,
                    dateIndex: 1,
                    current: value.substring(4, 6)),
                _pickerForm(
                    controller: _dayController,
                    date: _day,
                    dateIndex: 2,
                    current: value.substring(6, 8)),
              ],
            ),
          );
        });
  }

  SizedBox _pickerForm({
    required List<String> date,
    required int dateIndex,
    required String current,
    required FixedExtentScrollController controller,
  }) {
    return SizedBox(
      height: 96.h,
      width: 100,
      child: Stack(
        children: [
          Positioned(
            top: 96.h / 3,
            child: Row(
              children: [
                Container(
                  width: 100.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: MITIColor.gray600,
                  ),
                ),
              ],
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            onSelectedItemChanged: (int i) {
              HapticFeedback.lightImpact();
              _changedDate(dateIndex, i);
              widget.onChanged(currentDate.value);
            },
            squeeze: 0.5,
            perspective: 0.01,
            physics: const FixedExtentScrollPhysics(),
            // magnification: 0.1,
            diameterRatio: 10,
            // useMagnifier:true,
            itemExtent: 20,
            childDelegate: ListWheelChildLoopingListDelegate(children: [
              ...List.generate(
                date.length,
                (index) => Text(
                  date[index],
                  style: MITITextStyle.md.copyWith(
                    fontSize: 16,
                    color: date[index] == current
                        ? MITIColor.primary
                        : MITIColor.gray300,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
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
                child: Text(
                  "경기 날짜와 시간을 선택해 주세요.",
                  style: MITITextStyle.md.copyWith(
                    color: MITIColor.gray500,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return DatePickerSpinner(
                            date: DateTime.now(), onChanged: (onChanged) {});
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
}

class _DateForm extends ConsumerStatefulWidget {
  const _DateForm({super.key});

  @override
  ConsumerState<_DateForm> createState() => _DateFormState();
}

class _DateFormState extends ConsumerState<_DateForm> {
  late final TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dateProvider(DateTimeType.start), (previous, next) {
      final endDate = ref.read(dateProvider(DateTimeType.end));
      if (next != null && endDate != null) {
        final formatStart = DateTimeUtil.getDateTime(dateTime: next);
        final formatEnd = DateTimeUtil.getDateTime(dateTime: endDate);
        dateController.text = '$formatStart ~ $formatEnd';
        ref
            .read(gameFormProvider.notifier)
            .update(startDateTime: next, endDateTime: endDate);
        ref.read(gameFormProvider.notifier).validDatetimeInteraction();
      }
    });
    ref.listen(dateProvider(DateTimeType.end), (previous, next) {
      final startDate = ref.read(dateProvider(DateTimeType.start));
      if (next != null && startDate != null) {
        final formatStart = DateTimeUtil.getDateTime(dateTime: startDate);
        final formatEnd = DateTimeUtil.getDateTime(dateTime: next);
        dateController.text = '$formatStart ~ $formatEnd';
        ref
            .read(gameFormProvider.notifier)
            .update(startDateTime: startDate, endDateTime: next);
        ref.read(gameFormProvider.notifier).validDatetimeInteraction();
      }
    });

    final interactionDesc =
        ref.watch(interactionDescProvider(InteractionType.date));
    return SliverToBoxAdapter(
        child: Column(
      children: [
        DateInputForm(
          textEditingController: dateController,
          hintText: '경기 시간을 선택해주세요.',
          label: '경기 시간',
          enabled: false,
          labelTextStyle: TextStyleUtil.getLabelTextStyle(),
          hintTextStyle: TextStyleUtil.getHintTextStyle(),
          textStyle: TextStyleUtil.getTextStyle(),
          isRangeCalendar: true,
          interactionDesc: interactionDesc,
        ),
      ],
    ));
  }
}

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
          addressDetailController.text = next.court.address_detail;
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

  const ApplyForm({
    super.key,
    this.initMaxValue,
    this.initMinValue,
    required this.formKeys,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final max_invitation =
        ref.watch(gameFormProvider.select((value) => value.max_invitation));
    final min_invitation =
        ref.watch(gameFormProvider.select((value) => value.min_invitation));

    return Column(
      children: [
        SizedBox(
          height: 85.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: CustomTextFormField(
                  focusNode: focusNodes[1],
                  key: formKeys[1],
                  initialValue: initMinValue,
                  hintText: '00',
                  label: '총 모집 인원',
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
                        .update(min_invitation: val);
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
              Flexible(
                child: CustomTextFormField(
                  focusNode: focusNodes[0],
                  key: formKeys[0],
                  initialValue: initMaxValue,
                  hintText: '00',
                  label: '',
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
                        .update(max_invitation: val);
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
        ),
        if (!ValidRegExp.validForm(min_invitation, max_invitation))
          Row(
            children: [
              SizedBox(
                height: 14.r,
                width: 14.r,
                child: SvgPicture.asset('assets/images/icon/system_alert.svg'),
              ),
              SizedBox(width: 4.w),
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
            '추가 정보',
            style: MITITextStyle.inputLabelIStyle
                .copyWith(color: const Color(0xFF999999)),
          ),
          SizedBox(height: 10.h),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 68.h,
              maxHeight: 300.h,
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: TextField(
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: MITITextStyle.inputValueMStyle.copyWith(
                    color: Colors.black,
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
                      minHeight: 68.h,
                      maxHeight: 300.h,
                    ),
                    hintText:
                        '주차, 샤워 가능 여부, 경기 진행 방식, 필요한 유니폼 색상 등 참가들에게 공지할 정보들을 입력해주세요',
                    hintStyle: MITITextStyle.placeHolderMStyle
                        .copyWith(color: const Color(0xFF969696)),
                    hintMaxLines: 10,
                    fillColor: const Color(0xFFF7F7F7),
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
