import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/defalut_flashbar.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/util/util.dart';

import '../error/user_error.dart';

class NicknameUpdateScreen extends ConsumerStatefulWidget {
  final String profileImageUrl;

  static String get routeName => 'nicknameUpdate';

  const NicknameUpdateScreen({
    super.key,
    required this.profileImageUrl,
  });

  @override
  ConsumerState<NicknameUpdateScreen> createState() =>
      _NicknameUpdateScreenState();
}

class _NicknameUpdateScreenState extends ConsumerState<NicknameUpdateScreen> {
  bool isLoading = false;
  late Throttle<int> _throttler;
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
      await _updateNickname(ref, context);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MITIColor.gray750,
        appBar: const DefaultAppBar(
          backgroundColor: MITIColor.gray750,
          hasBorder: false,
          title: '프로필 수정',
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),
              // Text(
              //   '변경하고 싶은 닉네임을 입력해 주세요.',
              //   style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
              // ),
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                },
                child: Image.network(
                  widget.profileImageUrl,
                  height: 120.r,
                  width: 120.r,
                ),
              ),
              SizedBox(height: 40.h),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return CustomTextFormField(
                    hintText: '닉네임을 입력해 주세요.',
                    label: '닉네임',
                    onChanged: (v) {
                      ref
                          .read(userNicknameFormProvider.notifier)
                          .update(nickname: v);
                    },
                  );
                },
              ),
              const Spacer(),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final nickname = ref.watch(userNicknameFormProvider).nickname;
                  final valid = ValidRegExp.userNickname(nickname);
                  return TextButton(
                      onPressed: valid && !isLoading
                          ? () async {
                              _throttler.setValue(throttleCnt + 1);
                            }
                          : () {},
                      style: TextButton.styleFrom(
                        backgroundColor: valid && !isLoading
                            ? MITIColor.primary
                            : MITIColor.gray500,
                      ),
                      child: Text(
                        '저장하기',
                        style: MITITextStyle.mdBold.copyWith(
                          color: valid && !isLoading
                              ? MITIColor.gray800
                              : MITIColor.gray50,
                        ),
                      ));
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateNickname(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(updateNicknameProvider.future);
    if (result is ErrorModel) {
      UserError.fromModel(model: result)
          .responseError(context, UserApiType.updateNickname, ref);
    } else {
      context.pop();
      Future.delayed(const Duration(milliseconds: 100), () {
        FlashUtil.showFlash(context, '프로필이 수정되었습니다.');
      });
    }
  }
}
