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
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../account/provider/widget/transfer_form_provider.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../model/user_model.dart';

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
        body: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final result = ref.watch(playerProfileProvider);
            final form = ref.watch(userPlayerProfileFormProvider);
            // if (result is LoadingModel) {
            //   return const CircularProgressIndicator();
            // } else if (result is ErrorModel) {
            //   return Text("error");
            // }
            // final model = (result as ResponseModel<UserPlayerProfileModel>)
            //     .data!
            //     .playerProfile;
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
                    return SizedBox(height: 16.h);
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
    List<String> items = getItems();

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
          SizedBox(
              width: 120.w,
              child: CustomTextFormField(
                textEditingController: _editingController,
                height: 40.h,
                hintText: widget.type.displayName,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  NumberFormatter(
                      minRange:
                          widget.type == PlayerProfileType.height ? 50 : 30,
                      maxRange:
                          widget.type == PlayerProfileType.height ? 230 : 150),
                ],
                suffixIcon: Text(
                  widget.type == PlayerProfileType.height ? "cm" : "kg",
                  style: MITITextStyle.sm.copyWith(color: MITIColor.gray400),
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
              ))
        else
          GestureDetector(
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
}

class BottomSheetWrapComponent extends StatelessWidget {
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
              Wrap(
                spacing: 10.r,
                runSpacing: 10.r,
                children: items
                    .map((item) => GestureDetector(
                          onTap: () => onTapItem(item),
                          child: BottomSheetItem(
                            isSelected: item == selectedItem,
                            text: item,
                          ),
                        ))
                    .toList(),
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
      width: 103.w,
      height: 48.h,
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
