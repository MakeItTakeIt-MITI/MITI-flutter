import 'dart:developer';
import 'dart:io';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/defalut_flashbar.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/dio/provider/dio_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/image_crop_screen.dart';
import 'package:miti/util/util.dart';

import '../../common/model/entity_enum.dart';
import '../../common/provider/widget/form_provider.dart';
import '../error/user_error.dart';
import '../model/v2/base_user_profile_response.dart';

class ProfileUpdateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'profileUpdate';

  const ProfileUpdateScreen({
    super.key,
  });

  @override
  ConsumerState<ProfileUpdateScreen> createState() =>
      _NicknameUpdateScreenState();
}

class _NicknameUpdateScreenState extends ConsumerState<ProfileUpdateScreen> {
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
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final result = ref.watch(userProfileProvider);
              if (result is LoadingModel) {
                return const Center(child: CircularProgressIndicator());
              } else if (result is ErrorModel) {
                UserError.fromModel(model: result)
                    .responseError(context, UserApiType.getPlayerProfile, ref);
                return Text("error");
              }
              final model =
                  (result as ResponseModel<BaseUserProfileResponse>).data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () async {
                        showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 20.h),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image =
                                            await picker.pickImage(
                                                source: ImageSource.gallery);

                                        if (image != null) {
                                          context.pop();
                                          Map<String, String> queryParameters =
                                              {
                                            'profileImageUpdateUrl':
                                                model.profileImageUpdateUrl,
                                            'pickedFilePath': image.path,
                                          };
                                          context.pushNamed(
                                            ImageCropScreen.routeName,
                                            queryParameters: queryParameters,
                                          );
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: MITIColor.gray800,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Colors.transparent),
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(8.r),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '앨범에서 택하기',
                                        style: MITITextStyle.md.copyWith(
                                          color: MITIColor.primary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    TextButton(
                                      onPressed: () async {
                                        final result = await ref.read(
                                            resetProfileImageProvider.future);
                                        if (result is ErrorModel) {
                                          UserError.fromModel(model: result)
                                              .responseError(
                                                  context,
                                                  UserApiType.resetProfileImage,
                                                  ref);
                                        } else {
                                          imageCache.clear();
                                          ref
                                              .read(
                                                  userProfileProvider.notifier)
                                              .getInfo();
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                            FlashUtil.showFlash(
                                                context, '프로필 이미지가 초기화 되었습니다.');
                                          });
                                          context.pop();
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: MITIColor.gray800,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Colors.transparent),
                                          borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(8.r),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '기본 프로필로 변경하기',
                                        style: MITITextStyle.md.copyWith(
                                          color: MITIColor.primary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      style: TextButton.styleFrom(
                                          backgroundColor: MITIColor.gray800),
                                      child: Text(
                                        "닫기",
                                        style: MITITextStyle.md
                                            .copyWith(color: MITIColor.gray400),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                      child: Stack(
                        children: [
                          if (model.profileImageUrl != null)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60.r,
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(
                                    model.profileImageUrl,
                                    scale: 120.r),
                              ),
                            )
                          else
                            SvgPicture.asset(
                              AssetUtil.getAssetPath(
                                  type: AssetType.icon, name: 'user_thum'),
                              width: 120.r,
                              height: 120.r,
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: SvgPicture.asset(
                              height: 40.r,
                              width: 40.r,
                              AssetUtil.getAssetPath(
                                type: AssetType.icon,
                                name: 'camera',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final nicknameInteraction =
                          ref.watch(formInfoProvider(InputFormType.nickname));
                      return CustomTextFormField(
                        hintText: '닉네임을 입력해 주세요.',
                        label: '닉네임',
                        interactionDesc: nicknameInteraction.interactionDesc,
                        borderColor: nicknameInteraction.borderColor,
                        onChanged: (v) {
                          ref
                              .read(userNicknameFormProvider.notifier)
                              .update(nickname: v);
                          final valid = ref
                              .read(userNicknameFormProvider.notifier)
                              .validNickname();

                          if (valid) {
                            ref
                                .read(formInfoProvider(InputFormType.nickname)
                                    .notifier)
                                .reset();
                          } else {
                            ref
                                .read(formInfoProvider(InputFormType.nickname)
                                    .notifier)
                                .update(
                                    borderColor: V2MITIColor.red5,
                                    interactionDesc: InteractionDesc(
                                        isSuccess: false,
                                        desc: '2-15자의 한글,영어,숫자로만 설정이 가능합니다.'));
                          }
                        },
                      );
                    },
                  ),
                  const Spacer(),
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final nickname =
                          ref.watch(userNicknameFormProvider).nickname;
                      final valid =
                          ValidRegExp.userNickname(nickname) && !isLoading;
                      return TextButton(
                          onPressed: valid
                              ? () async {
                                  _throttler.setValue(throttleCnt + 1);
                                }
                              : () {},
                          style: TextButton.styleFrom(
                            backgroundColor:
                                valid ? MITIColor.primary : MITIColor.gray500,
                          ),
                          child: Text(
                            '저장하기',
                            style: MITITextStyle.mdBold.copyWith(
                              color:
                                  valid ? MITIColor.gray800 : MITIColor.gray50,
                            ),
                          ));
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _updateNickname(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(updateProfileInfoProvider.future);
    if (result is ErrorModel) {
      UserError.fromModel(model: result)
          .responseError(context, UserApiType.updateProfileInfo, ref);
    } else {
      context.pop();
      Future.delayed(const Duration(milliseconds: 100), () {
        FlashUtil.showFlash(context, '프로필이 수정되었습니다.');
      });
    }
  }
}
