import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/support/error/support_error.dart';
import 'package:miti/support/provider/support_provider.dart';
import 'package:miti/support/provider/widget/support_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/defalut_flashbar.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../game/view/review_form_screen.dart';

class SupportFormScreen extends ConsumerStatefulWidget {
  static String get routeName => 'supportForm';

  const SupportFormScreen({
    super.key,
  });

  @override
  ConsumerState<SupportFormScreen> createState() => _SupportFormScreenState();
}

class _SupportFormScreenState extends ConsumerState<SupportFormScreen> {
  late final ScrollController _scrollController;
  late Throttle<int> _throttler;

  bool isLoading = false;
  int throttleCnt = 0;

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
      await _onCreate(ref, context);
      setState(() {
        isLoading = false;
      });
    });
    _scrollController = ScrollController();
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
        bottomNavigationBar: BottomButton(
          hasBorder: false,
          button: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final form = ref.watch(supportFormProvider);
              final valid = form.title.isNotEmpty && form.content.isNotEmpty;
              return TextButton(
                onPressed: valid && !isLoading
                    ? () async {
                        _throttler.setValue(throttleCnt + 1);
                      }
                    : () {},
                style: TextButton.styleFrom(
                    backgroundColor: valid && !isLoading
                        ? MITIColor.primary
                        : MITIColor.gray500),
                child: Text(
                  '문의하기',
                  style: MITITextStyle.mdBold.copyWith(
                      color: valid && !isLoading
                          ? MITIColor.gray800
                          : MITIColor.gray50),
                ),
              );
            },
          ),
        ),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder:
              ((BuildContext context, bool innerBoxIsScrolled) {
            return [
              const DefaultAppBar(
                isSliver: true,
                title: '문의하기',
              ),
            ];
          }),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
                sliver: SliverFillRemaining(
                    child: Column(
                  children: [
                    const _TitleForm(),
                    SizedBox(height: 16.h),
                    const _ContentForm(),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCreate(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(supportCreateProvider.future);
    if (context.mounted) {
      if (result is ErrorModel) {
        SupportError.fromModel(model: result)
            .responseError(context, SupportApiType.create, ref);
      } else {
        context.pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          FlashUtil.showFlash(context, '문의 작성이 완료되었습니다.');
        });
      }
    }
  }
}

class _TitleForm extends ConsumerWidget {
  const _TitleForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '문의 제목',
          style: MITITextStyle.sm.copyWith(color: MITIColor.gray300),
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          hintText: '제목을 입력해주세요.',
          height: 44,
          hintTextStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray500),
          textStyle: MITITextStyle.sm.copyWith(color: MITIColor.gray100),
          onChanged: (val) {
            ref.read(supportFormProvider.notifier).update(title: val);
          },
        ),
      ],
    );
  }
}

class _ContentForm extends ConsumerWidget {
  const _ContentForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '문의 내용',
          style: MITITextStyle.sm.copyWith(color: MITIColor.gray300),
        ),
        SizedBox(height: 12.h),
        ConstrainedBox(
          constraints: BoxConstraints.tight(Size(double.infinity, 200.h)),
          child: MultiLineTextFormField(
            onChanged: (val) {
              ref.read(supportFormProvider.notifier).update(content: val);
            },
            hint: '내용을 작성해주세요.',
            context: context,
          ),
        ),
      ],
    );
  }
}
