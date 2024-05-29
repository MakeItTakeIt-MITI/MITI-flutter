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
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/provider/router_provider.dart';
import '../../common/provider/scroll_provider.dart';
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
          ),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              const SliverToBoxAdapter(child: ApplyForm()),
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

  SliverToBoxAdapter getSpacer({double height = 25}) => SliverToBoxAdapter(
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
          labelTextStyle: TextStyleUtil.getLabelTextStyle(),
          hintTextStyle: TextStyleUtil.getHintTextStyle(),
          textStyle: TextStyleUtil.getTextStyle(),
          onChanged: (val) {
            ref.read(gameFormProvider.notifier).update(title: val);
          },
        ));
      },
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
          style: MITITextStyle.inputLabelIStyle
              .copyWith(color: const Color(0xFF999999)),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 51.h,
          decoration: ShapeDecoration(
            color: const Color(0xFFF7F7F7),
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
                        ? TextStyleUtil.getHintTextStyle()
                        : TextStyleUtil.getTextStyle(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: SizedBox(
                  height: 36.h,
                  width: 81.w,
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
                                    final newCourt = court.copyWith(
                                        address: kpostal.address);
                                    ref
                                        .read(gameFormProvider.notifier)
                                        .update(court: newCourt);
                                    final result = await ref
                                        .read(courtListProvider.future);

                                    if (result is ErrorModel) {
                                    } else {
                                      result as ResponseModel<
                                          PaginationModel<CourtSearchModel>>;
                                      if (context.mounted) {
                                        if (result
                                            .data!.page_content.isNotEmpty) {
                                          final extra = CourtListComponent(
                                            model: result,
                                          );
                                          context.pushNamed(
                                              DialogPage.routeName,
                                              extra: extra);
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                            // context.pushNamed(AddressScreen.routeName);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            backgroundColor: const Color(0xFF4065F6),
                          ),
                          child: Text(
                            '주소검색',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.25.sp,
                                fontSize: 12.sp,
                                color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          SizedBox(height: 12.h),
          CustomTextFormField(
            hintText: '상세 주소를 입력해주세요.',
            label: '경기 상세 주소',
            labelTextStyle: TextStyleUtil.getLabelTextStyle(),
            hintTextStyle: TextStyleUtil.getHintTextStyle(),
            textStyle: TextStyleUtil.getTextStyle(),
            textEditingController: addressDetailController,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              final newCourt = court.copyWith(address_detail: val);
              ref.read(gameFormProvider.notifier).update(court: newCourt);
            },
          ),
          SizedBox(height: 12.h),
          CustomTextFormField(
            textEditingController: nameController,
            hintText: '경기장 이름을 입력해주세요.',
            label: '경기장 이름',
            labelTextStyle: TextStyleUtil.getLabelTextStyle(),
            hintTextStyle: TextStyleUtil.getHintTextStyle(),
            textStyle: TextStyleUtil.getTextStyle(),
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

  const ApplyForm({
    super.key,
    this.initMaxValue,
    this.initMinValue,
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
                  initialValue: initMaxValue,
                  hintText: '0',
                  label: '총 모집 인원',
                  labelTextStyle: TextStyleUtil.getLabelTextStyle(),
                  hintTextStyle: TextStyleUtil.getHintTextStyle(),
                  textStyle: TextStyleUtil.getTextStyle(),
                  textAlign: TextAlign.center,
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
                ),
              ),
              SizedBox(width: 17.w),
              Flexible(
                child: CustomTextFormField(
                  initialValue: initMinValue,
                  hintText: '0',
                  label: '최소 모집 인원',
                  labelTextStyle: TextStyleUtil.getLabelTextStyle(),
                  hintTextStyle: TextStyleUtil.getHintTextStyle(),
                  textStyle: TextStyleUtil.getTextStyle(),
                  textAlign: TextAlign.center,
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
      labelTextStyle: TextStyleUtil.getLabelTextStyle(),
      hintTextStyle: TextStyleUtil.getHintTextStyle(),
      textStyle: TextStyleUtil.getTextStyle(),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumberFormatter(),
      ],
      onChanged: (val) {
        ref.read(gameFormProvider.notifier).update(fee: val);
      },
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Text(
          '₩',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF969696),
            fontSize: 14.sp,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            letterSpacing: -0.25.sp,
          ),
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
