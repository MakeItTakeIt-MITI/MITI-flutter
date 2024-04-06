import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/provider/widget/datetime_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';

class GameCreateScreen extends StatelessWidget {
  static String get routeName => 'create';

  const GameCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '매치 생성',
            )
          ];
        },
        body: Padding(
          padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              getSpacer(height: 18),
              SliverToBoxAdapter(
                child: Text(
                  '경기 정보',
                  style: TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 16.sp,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                  ),
                ),
              ),
              getSpacer(),
              _TitleForm(),
              getSpacer(),
              _DateForm(),
              getSpacer(),
              _AddressForm(),
              getSpacer(),
              _ApplyForm(),
              getSpacer(),
              _AdditionalInfo(),
              getSpacer(height: 28),
              SliverToBoxAdapter(
                  child: TextButton(onPressed: () {}, child: Text('매치 생성하기'))),
              getSpacer(height: 29.5),
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
          textInputAction: TextInputAction.next,
          onChanged: (val) {
            ref.read(gameFormProvider.notifier).update(title: val);
          },
          onNext: () {},
        ));
      },
    );
  }
}

class _DateForm extends StatelessWidget {
  const _DateForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Column(
      children: [
        DateInputForm(
          hintText: '경기 시작 시간을 선택해주세요.',
          label: '경기 시작 시간',
          enabled: false,
          dateType: DateTimeType.start,
          timeType: DateTimeType.start,
        ),
        SizedBox(height: 12.h),
        DateInputForm(
          hintText: '경기 종료 시간을 선택해주세요.',
          label: '경기 종료 시간',
          enabled: false,
          dateType: DateTimeType.end,
          timeType: DateTimeType.end,
        ),
      ],
    ));
  }
}

class _AddressForm extends StatelessWidget {
  const _AddressForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          CustomTextFormField(
            hintText: '주소를 검색해주세요.',
            label: '경기 주소',
            textInputAction: TextInputAction.next,
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: SizedBox(
                height: 36.h,
                width: 70.w,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      backgroundColor: const Color(0xFF4065F6),
                    ),
                    child: Text(
                      '주소검색',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          CustomTextFormField(
            hintText: '상세 주소를 입력해주세요.',
            label: '경기 상세 주소',
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 12.h),
          CustomTextFormField(
            hintText: '경기장 이름을 입력해주세요.',
            label: '경기장 이름',
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }
}

class _ApplyForm extends StatelessWidget {
  const _ApplyForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 85.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: CustomTextFormField(
                hintText: '00',
                label: '총 모집 인원',
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
              ),
            ),
            SizedBox(width: 17.w),
            Flexible(
              child: CustomTextFormField(
                hintText: '00',
                label: '최소 모집 인원',
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdditionalInfo extends StatelessWidget {
  const _AdditionalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CustomTextFormField(
        hintText: '주차, 샤워 가능 여부, 경기 진행 방식, 필요한 유니폼 색상 등 참가들에게 공지할 정보들을 입력해주세요',
        label: '추가 정보',
        textInputAction: TextInputAction.send,
      ),
    );
  }
}
