import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/provider/router_provider.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../auth/provider/delete_provider.dart';
import '../../common/component/custom_dialog.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../error/user_error.dart';

class UserDeleteScreen extends ConsumerStatefulWidget {
  static String get routeName => 'deleteUser';

  const UserDeleteScreen({
    super.key,
  });

  @override
  ConsumerState<UserDeleteScreen> createState() => _UserDeleteScreenState();
}

class _UserDeleteScreenState extends ConsumerState<UserDeleteScreen> {
  late final ScrollController _scrollController;
  bool valid = false;

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
    return Scaffold(
      appBar: const DefaultAppBar(
        title: '회원 탈퇴',
        hasBorder: false,
      ),
      bottomNavigationBar: BottomButton(
        hasBorder: false,
        button: TextButton(
          onPressed: () async {
            final result = await ref.read(deleteUserProvider.future);
            if (context.mounted) {
              if (result is ErrorModel) {
                UserError.fromModel(model: result)
                    .responseError(context, UserApiType.delete, ref);
              }
            } else {
              showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return BottomDialog(
                      title: '탈퇴 완료',
                      content:
                          '회원 탈퇴가 완료되었습니다.\n농구 하고싶을 땐 미티! 다시 볼 날을 고대하고 있을게요!',
                      btn: Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          return TextButton(
                            onPressed: () => context.pop(),
                            child: const Text(
                              "확인",
                            ),
                          );
                        },
                      ),
                    );
                  });
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: valid ? MITIColor.primary : MITIColor.gray500,
          ),
          child: Text(
            '회원 탈퇴하기',
            style: MITITextStyle.mdBold.copyWith(
              color: valid ? MITIColor.gray800 : MITIColor.gray50,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Padding(
              padding: EdgeInsets.only(
                  left: 21.w, right: 21.w, top: 20.h, bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final nickname = ref.watch(authProvider)?.nickname;
                      return Text(
                        '$nickname님,\n정말 탈퇴하시겠어요?',
                        style:
                            MITITextStyle.xl150.copyWith(color: Colors.white),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  CustomCheckBox(
                      title:
                          '탈퇴하시는 경우, 해당 계정 정보는 즉시 삭제되며\n입금되지 않은 송금요쳥과 보유금 전부 삭제됩니다.',
                      textStyle: MITITextStyle.sm150
                          .copyWith(color: MITIColor.gray200),
                      check: true,
                      onTap: () {}),
                  SizedBox(height: 12.h),
                  CustomCheckBox(
                      title:
                          '탈퇴하시는 경우, 해당 계정 정보는 즉시 삭제되며\n입금되지 않은 송금요쳥과 보유금 전부 삭제됩니다.',
                      textStyle: MITITextStyle.sm150
                          .copyWith(color: MITIColor.gray200),
                      check: true,
                      onTap: () {}),
                  const Spacer(),
                  CustomCheckBox(
                      title: '회원 탈퇴 유의 사항을 확인하였으며, 이에 동의합니다.',
                      textStyle:
                          MITITextStyle.sm.copyWith(color: MITIColor.gray200),
                      check: valid,
                      isCheckBox: true,
                      onTap: () {
                        setState(() {
                          valid = !valid;
                        });
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
