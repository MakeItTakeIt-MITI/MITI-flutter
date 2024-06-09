import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/provider/router_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/error/user_error.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_info_screen.dart';
import 'package:miti/util/util.dart';

import '../../common/component/default_appbar.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/form_util_provider.dart';
import '../model/user_model.dart';

class UserProfileFormScreen extends ConsumerStatefulWidget {
  static String get routeName => 'userProfile';
  final int bottomIdx;

  const UserProfileFormScreen({
    super.key,
    required this.bottomIdx,
  });

  @override
  ConsumerState<UserProfileFormScreen> createState() =>
      _UserProfileFormScreenState();
}

class _UserProfileFormScreenState extends ConsumerState<UserProfileFormScreen> {
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
              title: '내 정보',
              isSliver: true,
            )
          ];
        },
        body: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: SvgPicture.asset(
                  'assets/images/icon/user_thum.svg',
                  width: 75.r,
                  height: 75.r,
                ),
              ),
              // CustomTextFormField(hintText: 'hintText', label: 'label')
              const Expanded(child: _ProfileFormComponent()),
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
              title: '내 정보',
              isSliver: true,
            )
          ];
        },
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: SvgPicture.asset(
                      'assets/images/icon/user_thum.svg',
                      width: 75.r,
                      height: 75.r,
                    ),
                  ),
                  const Expanded(child: _ProfileFormComponent()),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class _ProfileFormComponent extends ConsumerStatefulWidget {
  const _ProfileFormComponent({super.key});

  @override
  ConsumerState<_ProfileFormComponent> createState() =>
      _ProfileFormComponentState();
}

class _ProfileFormComponentState extends ConsumerState<_ProfileFormComponent> {
  final formKeys = [GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey()];

  late final List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      focusNodes[i].addListener(() {
        focusScrollable(i);
      });
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < 4; i++) {
      focusNodes[i].removeListener(() {
        focusScrollable(i);
      });
    }
    super.dispose();
  }

  void focusScrollable(int i) {
    Scrollable.ensureVisible(
      formKeys[i].currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      return Text('에러');
    }
    final model = (result as ResponseModel<UserModel>).data!;
    final form = ref.watch(userNicknameFormProvider);
    final passwordForm = ref.watch(userPasswordFormProvider);
    final validNickname =
        ref.watch(userNicknameFormProvider.notifier).validNickname();
    final valid = ref.watch(userPasswordFormProvider.notifier).validForm();

    final nicknameInteraction =
        ref.watch(interactionDescProvider(InteractionType.nickname));
    final passwordInteraction =
        ref.watch(interactionDescProvider(InteractionType.password));
    final newPasswordInteraction =
        ref.watch(interactionDescProvider(InteractionType.newPassword));
    final newPasswordCheckInteraction =
        ref.watch(interactionDescProvider(InteractionType.newPasswordCheck));
    final passwordVisible =
        ref.watch(passwordVisibleProvider(PasswordFormType.password));
    final newPasswordVisible =
        ref.watch(passwordVisibleProvider(PasswordFormType.newPassword));
    final newPasswordCheckVisible =
        ref.watch(passwordVisibleProvider(PasswordFormType.newPasswordCheck));

    return Column(
      children: [
        CustomTextFormField(
          key: formKeys[0],
          focusNode: focusNodes[0],
          hintText: '${model.nickname}(기존 닉네임)',
          label: '닉네임',
          interactionDesc: nicknameInteraction,
          onChanged: (val) {
            ref.read(userNicknameFormProvider.notifier).update(nickname: val);
          },
          suffixIcon: Container(
            width: 81.w,
            margin: EdgeInsets.only(right: 8.w),
            child: TextButton(
              onPressed: validNickname
                  ? () async {
                      await updateNickname(context);
                    }
                  : () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: validNickname
                    ? const Color(0xff4065F5)
                    : const Color(0xffE8E8E8),
              ),
              child: Text(
                '변경하기',
                style: MITITextStyle.btnRStyle.copyWith(
                  color: validNickname ? Colors.white : const Color(0xff969696),
                ),
              ),
            ),
          ),
        ),
        if (model.oauth == null)
          Column(
            children: [
              SizedBox(height: 30.h),
              CustomTextFormField(
                key: formKeys[1],
                hintText: '기존 비밀번호를 입력해주세요',
                label: '기존 비밀번호',
                obscureText: !passwordVisible,
                textInputAction: TextInputAction.next,
                interactionDesc: passwordInteraction,
                focusNode: focusNodes[1],
                onNext: () {
                  FocusScope.of(context).requestFocus(focusNodes[2]);
                },
                suffixIcon: focusNodes[1].hasFocus
                    ? IconButton(
                        onPressed: () {
                          ref
                              .read(passwordVisibleProvider(
                                      PasswordFormType.password)
                                  .notifier)
                              .update((state) => !state);
                        },
                        icon: Icon(passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      )
                    : null,
                onChanged: (val) {
                  ref
                      .read(userPasswordFormProvider.notifier)
                      .update(password: val);
                },
              ),
              SizedBox(height: 30.h),
              CustomTextFormField(
                key: formKeys[2],
                hintText: '변경할 비밀번호를 입력해주세요.',
                label: '새로운 비밀번호',
                obscureText: !newPasswordVisible,
                textInputAction: TextInputAction.next,
                interactionDesc: newPasswordInteraction,
                focusNode: focusNodes[2],
                onNext: () {
                  FocusScope.of(context).requestFocus(focusNodes[3]);
                },
                suffixIcon: focusNodes[2].hasFocus
                    ? IconButton(
                        onPressed: () {
                          ref
                              .read(passwordVisibleProvider(
                                      PasswordFormType.newPassword)
                                  .notifier)
                              .update((state) => !state);
                        },
                        icon: Icon(newPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      )
                    : null,
                onChanged: (val) {
                  ref
                      .read(userPasswordFormProvider.notifier)
                      .update(new_password: val);
                  if (ValidRegExp.userPassword(val)) {
                    ref
                        .read(
                            interactionDescProvider(InteractionType.newPassword)
                                .notifier)
                        .update((state) => InteractionDesc(
                            isSuccess: true, desc: '안전한 비밀번호에요!'));
                  } else {
                    ref
                        .read(
                            interactionDescProvider(InteractionType.newPassword)
                                .notifier)
                        .update((state) => InteractionDesc(
                            isSuccess: false, desc: '올바른 비밀번호 양식이 아니에요.'));
                  }
                },
              ),
              SizedBox(height: 25.h),
              CustomTextFormField(
                key: formKeys[3],
                hintText: '변경할 비밀번호를 입력해주세요.',
                label: '새로운 비밀번호 확인',
                obscureText: !newPasswordCheckVisible,
                textInputAction: TextInputAction.send,
                focusNode: focusNodes[3],
                interactionDesc: newPasswordCheckInteraction,
                suffixIcon: focusNodes[3].hasFocus
                    ? IconButton(
                        onPressed: () {
                          ref
                              .read(passwordVisibleProvider(
                                      PasswordFormType.newPasswordCheck)
                                  .notifier)
                              .update((state) => !state);
                        },
                        icon: Icon(newPasswordCheckVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      )
                    : null,
                onChanged: (val) {
                  ref
                      .read(userPasswordFormProvider.notifier)
                      .update(new_password_check: val);
                  if (ValidRegExp.userPassword(val)) {
                    if (passwordForm.new_password == val) {
                      ref
                          .read(interactionDescProvider(
                                  InteractionType.newPasswordCheck)
                              .notifier)
                          .update((state) => InteractionDesc(
                              isSuccess: true, desc: '안전한 비밀번호에요!'));
                    } else {
                      ref
                          .read(interactionDescProvider(
                                  InteractionType.newPasswordCheck)
                              .notifier)
                          .update((state) => InteractionDesc(
                              isSuccess: false, desc: '비밀번호가 일치하지 않아요.'));
                    }
                  } else {
                    ref
                        .read(interactionDescProvider(
                                InteractionType.newPasswordCheck)
                            .notifier)
                        .update((state) => InteractionDesc(
                            isSuccess: false, desc: '올바른 비밀번호 양식이 아니에요.'));
                  }
                },
              ),
            ],
          ),
        const Spacer(),
        if (model.oauth == null)
          TextButton(
              onPressed: valid
                  ? () async {
                      await updatePassword(context);
                    }
                  : () {},
              style: TextButton.styleFrom(
                backgroundColor:
                    valid ? const Color(0xFF4065F5) : const Color(0xFFE8E8E8),
              ),
              child: Text(
                '저장하기',
                style: MITITextStyle.btnTextBStyle.copyWith(
                  color: valid ? Colors.white : const Color(0xFF969696),
                ),
              )),
        SizedBox(height: 8.h),
      ],
    );
  }

  Future<void> updateNickname(BuildContext context) async {
    final result = await ref.read(updateNicknameProvider.future);

    if (result is ErrorModel) {
      if (context.mounted) {
        UserError.fromModel(model: result)
            .responseError(context, UserApiType.updateNickname, ref);
      }
    } else {
      if (context.mounted) {
        final extra = CustomDialog(
            title: '프로필 수정 완료',
            content: '회원 정보가 정상적으로 저장되었습니다.',
            onPressed: () {
              ref
                  .read(interactionDescProvider(InteractionType.nickname)
                      .notifier)
                  .update((state) => InteractionDesc(
                        isSuccess: true,
                        desc: "변경사항이 적용되었습니다.",
                      ));
              context.pop();
              // context.goNamed(InfoBody.routeName);
            });
        context.pushNamed(DialogPage.routeName, extra: extra);
      }
    }
  }

  Future<void> updatePassword(BuildContext context) async {
    final result = await ref.read(updatePasswordProvider.future);
    if (context.mounted) {
      if (result is ErrorModel) {
        UserError.fromModel(model: result)
            .responseError(context, UserApiType.updatePassword, ref);
      } else {
        final extra = CustomDialog(
            title: '프로필 수정 완료',
            content: '회원 정보가 정상적으로 저장되었습니다.',
            onPressed: () {
              context.pop();
              // context.goNamed(InfoBody.routeName);
            });
        context.pushNamed(DialogPage.routeName, extra: extra);
      }
    }
  }
}
