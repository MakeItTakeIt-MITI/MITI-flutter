import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/provider/user_provider.dart';
import '../../common/component/defalut_flashbar.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

typedef BottomSheetSelectItem = void Function(String item);

class UserPlayerProfileScreen extends StatelessWidget {
  static String get routeName => 'playerProfile';

  const UserPlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    const profileValues = PlayerProfileType.values;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '선수 프로필',
          hasBorder: false,
        ),
        bottomNavigationBar: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final valid =
                ref.watch(userPlayerProfileFormProvider.notifier).validForm();
            return BottomButton(
              hasBorder: false,
              button: TextButton(
                onPressed: valid
                    ? () async {
                        final result =
                            await ref.read(updatePlayerProfileProvider.future);
                        if (result is ErrorModel) {
                        } else {
                          FlashUtil.showFlash(context, '선수 프로필이 수정되었습니다.');
                        }
                      }
                    : null,
                style: TextButton.styleFrom(
                  backgroundColor:
                      valid ? MITIColor.primary : MITIColor.gray500,
                ),
                child: Text(
                  "수정하기",
                  style: MITITextStyle.mdBold.copyWith(
                    color: valid ? MITIColor.gray800 : MITIColor.gray50,
                  ),
                ),
              ),
            );
          },
        ),
        body: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final result = ref.watch(playerProfileProvider);
            final form = ref.watch(userPlayerProfileFormProvider);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (PlayerProfileType.height == profileValues[index] ||
                        PlayerProfileType.weight == profileValues[index]) {
                      String value = '';
                      if (PlayerProfileType.height == profileValues[index]) {
                        if (form.height != null) {
                          value = form.height.toString();
                        }
                      } else {
                        if (form.weight != null) {
                          value = form.weight.toString();
                        }
                      }
                      return _PlayerProfileForm(
                          type: profileValues[index], value: value);
                    }

                    return _PlayerProfileForm(
                      type: profileValues[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 0.h);
                  },
                  itemCount: PlayerProfileType.values.length),
            );
          },
        ),
      ),
    );
  }
}

class _PlayerProfileForm extends ConsumerStatefulWidget {
  final PlayerProfileType type;
  final String? value;

  const _PlayerProfileForm({
    super.key,
    required this.type,
    this.value,
  });

  @override
  ConsumerState<_PlayerProfileForm> createState() => _PlayerProfileFormState();
}

class _PlayerProfileFormState extends ConsumerState<_PlayerProfileForm> {
  late final TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    if (widget.type == PlayerProfileType.height ||
        widget.type == PlayerProfileType.weight) {
      _editingController = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(covariant _PlayerProfileForm oldWidget) {
    if (widget.type == PlayerProfileType.height ||
        widget.type == PlayerProfileType.weight) {
      _editingController.text = widget.value ?? '';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    String? formValue = getFormValue(ref);
    bool? formValid = getFormValid(ref);
    List<String> items = getItems();
    String errorMessage = widget.type == PlayerProfileType.weight
        ? '최소 입력 체중은 30kg 입니다.'
        : '최소 입력 신장은 50cm 입니다.';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.type.displayName,
          style: MITITextStyle.mdLight.copyWith(
            color: MITIColor.gray300,
          ),
        ),
        if (widget.type == PlayerProfileType.height ||
            widget.type == PlayerProfileType.weight)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                  width: 120.w,
                  child: CustomTextFormField(
                    textEditingController: _editingController,
                    height: 40.h,
                    hintText: widget.type.displayName,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    borderColor: formValid != null && !formValid
                        ? MITIColor.error
                        : null,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      NumberFormatter(
                          minRange:
                              widget.type == PlayerProfileType.height ? 50 : 30,
                          maxRange: widget.type == PlayerProfileType.height
                              ? 230
                              : 150),
                    ],
                    suffixIcon: Text(
                      widget.type == PlayerProfileType.height ? "cm" : "kg",
                      style:
                          MITITextStyle.sm.copyWith(color: MITIColor.gray400),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty) {
                        if (widget.type == PlayerProfileType.height) {
                          ref
                              .read(userPlayerProfileFormProvider.notifier)
                              .update(height: int.parse(v));
                        } else {
                          ref
                              .read(userPlayerProfileFormProvider.notifier)
                              .update(weight: int.parse(v));
                        }
                      }
                    },
                  )),
              SizedBox(
                height: 24.h,
                child: Visibility(
                  visible: formValid != null && !formValid,
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      errorMessage,
                      style: MITITextStyle.xxsm.copyWith(
                        color: MITIColor.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: GestureDetector(
              onTap: () {
                showBottomSheetForm(context, items, ref);
              },
              child: Container(
                width: 120.w,
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: MITIColor.gray700,
                ),
                child: Center(
                  child: Text(
                    formValue ?? widget.type.displayName,
                    style: MITITextStyle.md.copyWith(
                        color: formValue == null
                            ? MITIColor.gray500
                            : MITIColor.gray100),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  void showBottomSheetForm(
      BuildContext context, List<String> items, WidgetRef ref) {
    String selectedItem = '';
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        backgroundColor: MITIColor.gray800,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return BottomSheetWrapComponent(
              crossAxisCount: widget.type == PlayerProfileType.gender ? 2 : 3,
              onTapItem: (v) {
                setState(() {
                  if (selectedItem == v) {
                    selectedItem = '';
                  } else {
                    selectedItem = v;
                  }
                });
              },
              items: items,
              title: widget.type.displayName,
              selectedItem: selectedItem,
              onSubmitItem: () {
                if (widget.type == PlayerProfileType.gender) {
                  final gender = GenderType.stringToEnum(value: selectedItem);
                  ref
                      .read(userPlayerProfileFormProvider.notifier)
                      .update(gender: gender);
                } else if (widget.type == PlayerProfileType.position) {
                  final position =
                      PlayerPositionType.stringToEnum(value: selectedItem);
                  ref
                      .read(userPlayerProfileFormProvider.notifier)
                      .update(position: position);
                } else if (widget.type == PlayerProfileType.role) {
                  final role = PlayerRoleType.stringToEnum(value: selectedItem);
                  ref
                      .read(userPlayerProfileFormProvider.notifier)
                      .update(role: role);
                }
                context.pop();
                FocusScope.of(context).unfocus();
              },
            );
          });
        });
  }

  List<String> getItems() {
    if (PlayerProfileType.gender == widget.type) {
      return GenderType.values.map((e) => e.displayName).toList();
    } else if (PlayerProfileType.position == widget.type) {
      return PlayerPositionType.values.map((e) => e.displayName).toList();
    } else {
      return PlayerRoleType.values.map((e) => e.displayName).toList();
    }
  }

  String? getFormValue(WidgetRef ref) {
    switch (widget.type) {
      case PlayerProfileType.height:
        return ref
            .watch(userPlayerProfileFormProvider.select((s) => s.height))
            .toString();
      case PlayerProfileType.weight:
        return ref
            .watch(userPlayerProfileFormProvider.select((s) => s.weight))
            .toString();
      case PlayerProfileType.gender:
        return ref
            .watch(userPlayerProfileFormProvider.select((s) => s.gender))
            ?.displayName;
      case PlayerProfileType.position:
        return ref
            .watch(userPlayerProfileFormProvider.select((s) => s.position))
            ?.displayName;
      case PlayerProfileType.role:
        return ref
            .watch(userPlayerProfileFormProvider.select((s) => s.role))
            ?.displayName;
    }
  }

  bool? getFormValid(WidgetRef ref) {
    switch (widget.type) {
      case PlayerProfileType.height:
        return ref.watch(userPlayerProfileFormProvider.notifier).validHeight();
      case PlayerProfileType.weight:
        return ref.watch(userPlayerProfileFormProvider.notifier).validWeight();
      default:
        return null;
    }
  }
}

class BottomSheetWrapComponent extends StatelessWidget {
  final int crossAxisCount;
  final BottomSheetSelectItem onTapItem;
  final String title;
  final List<String> items;
  final String selectedItem;
  final VoidCallback onSubmitItem;

  const BottomSheetWrapComponent({
    super.key,
    required this.onTapItem,
    required this.items,
    required this.title,
    required this.selectedItem,
    required this.onSubmitItem,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Container(
            decoration: BoxDecoration(
              color: MITIColor.gray100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            width: 60.w,
            height: 4.h,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              SizedBox(height: 20.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 12.r,
                  crossAxisSpacing: 12.r,
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 48.h,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => onTapItem(items[index]),
                    child: BottomSheetItem(
                      isSelected: items[index] == selectedItem,
                      text: items[index],
                    ),
                  );
                },
                itemCount: items.length,
              ),
              SizedBox(height: 20.h),
              TextButton(
                  onPressed: selectedItem.isNotEmpty ? onSubmitItem : null,
                  style: TextButton.styleFrom(
                      backgroundColor: selectedItem.isNotEmpty
                          ? MITIColor.primary
                          : MITIColor.gray500),
                  child: Text(
                    '확인',
                    style: MITITextStyle.mdBold.copyWith(
                        color: selectedItem.isNotEmpty
                            ? MITIColor.gray800
                            : MITIColor.gray50),
                  ))
            ],
          ),
        )
      ],
    );
  }
}

class BottomSheetItem extends StatelessWidget {
  final bool isSelected;
  final String text;

  const BottomSheetItem(
      {super.key, required this.isSelected, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
            color: isSelected ? MITIColor.primary : MITIColor.gray800),
        color: MITIColor.gray750,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: MITITextStyle.sm.copyWith(
          color: MITIColor.gray100,
        ),
      ),
    );
  }
}
