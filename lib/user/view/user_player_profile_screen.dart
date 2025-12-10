import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_bottom_sheet.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/component/picker/overlay_number_picker.dart';
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
                      valid ? V2MITIColor.primary5 : MITIColor.gray500,
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
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final result = ref.watch(playerProfileProvider);

              return const PlayerProfileFormComponent();
            },
          ),
        ),
      ),
    );
  }
}

class PlayerProfileFormComponent extends ConsumerWidget {
  const PlayerProfileFormComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const profileValues = PlayerProfileType.values;

    final form = ref.watch(userPlayerProfileFormProvider);
    return ListView.separated(
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
            return _PlayerProfileForm(type: profileValues[index], value: value);
          }
          bool enabled = true;
          if (PlayerProfileType.gender == profileValues[index]) {
            enabled = form.enableGender;
          }

          return _PlayerProfileForm(
            type: profileValues[index],
            enabled: enabled,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 0.h);
        },
        itemCount: PlayerProfileType.values.length);
  }
}

class _PlayerProfileForm extends ConsumerStatefulWidget {
  final PlayerProfileType type;
  final String? value;
  final bool enabled;

  const _PlayerProfileForm({
    super.key,
    required this.type,
    this.value,
    this.enabled = true,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.type.displayName,
              style: V2MITITextStyle.smallRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            GestureDetector(
              onTap: widget.enabled
                  ? () => showBottomSheetForm(context, items, ref)
                  : null,
              child: Container(
                width: 140.w,
                height: 40.h,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: V2MITIColor.gray6)),
                child: Center(
                  child: Text(
                    formValue ?? widget.type.displayName,
                    style: V2MITITextStyle.regularMediumNormal.copyWith(
                        color: !widget.enabled
                            ? V2MITIColor.gray6
                            : formValue == null
                                ? V2MITIColor.gray6
                                : V2MITIColor.white),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 24.h,
          child: Visibility(
            visible: formValid != null && !formValid,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                errorMessage,
                style: MITITextStyle.xxsm.copyWith(
                  color: V2MITIColor.red5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showBottomSheetForm(
      BuildContext context, List<String> items, WidgetRef ref) {
    String selectedItem = '';

    CustomBottomSheet.showWidgetContent(
        title: widget.type.displayName,
        context: context,
        content: StatefulBuilder(
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
              } else if (widget.type == PlayerProfileType.weight) {
                ref
                    .read(userPlayerProfileFormProvider.notifier)
                    .update(weight: int.parse(selectedItem));
              } else {
                ref
                    .read(userPlayerProfileFormProvider.notifier)
                    .update(height: int.parse(selectedItem));
              }
              context.pop();
              FocusScope.of(context).unfocus();
            },
            onClearItem: widget.type != PlayerProfileType.gender
                ? () {
                    ref
                        .read(userPlayerProfileFormProvider.notifier)
                        .clear(widget.type);

                    context.pop();
                    FocusScope.of(context).unfocus();
                  }
                : null,
          );
        }),
        buttonText: '설정하기');
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
        {
          final value =
              ref.watch(userPlayerProfileFormProvider.select((s) => s.height));
          return value == null ? null : "$value cm";
        }
      case PlayerProfileType.weight:
        {
          final value =
              ref.watch(userPlayerProfileFormProvider.select((s) => s.weight));
          return value == null ? null : "$value kg";
        }
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

class BottomSheetWrapComponent extends ConsumerStatefulWidget {
  final int crossAxisCount;
  final BottomSheetSelectItem onTapItem;
  final String title;
  final List<String> items;
  final String selectedItem;
  final VoidCallback onSubmitItem;
  final VoidCallback? onClearItem;

  const BottomSheetWrapComponent({
    super.key,
    required this.onTapItem,
    required this.items,
    required this.title,
    required this.selectedItem,
    required this.onSubmitItem,
    this.crossAxisCount = 3,
    this.onClearItem,
  });

  @override
  ConsumerState<BottomSheetWrapComponent> createState() =>
      _BottomSheetWrapComponentState();
}

class _BottomSheetWrapComponentState
    extends ConsumerState<BottomSheetWrapComponent> {
  late int? initialValue;

  @override
  void initState() {
    super.initState();
    initialValue = widget.title == '체중'
        ? ref.read(userPlayerProfileFormProvider).weight
        : ref.read(userPlayerProfileFormProvider).height;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            if (widget.title == '체중' || widget.title == '신장')
              SizedBox(
                height: 96.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 66.w,
                      child: OverlayNumberPicker(
                        initialValue: initialValue,
                        start: widget.title == '체중' ? 30 : 50,
                        end: widget.title == '체중' ? 150 : 230,
                        onSelect: (int index) {
                          widget.onTapItem(index.toString());
                        },
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 12.w,
                          ),
                          Text(
                            widget.title == '체중' ? "kg" : "cm",
                            style: MITITextStyle.sm,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 12.r,
                  crossAxisSpacing: 17.r,
                  crossAxisCount: widget.crossAxisCount,
                  mainAxisExtent: 48.h,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => widget.onTapItem(widget.items[index]),
                    child: BottomSheetItem(
                      isSelected: widget.items[index] == widget.selectedItem,
                      text: widget.items[index],
                    ),
                  );
                },
                itemCount: widget.items.length,
              ),
            SizedBox(height: 20.h),
            Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Row(
                  children: [
                    if (widget.onClearItem != null) ...[
                      Flexible(
                        child: TextButton(
                            onPressed: widget.onClearItem,
                            style: TextButton.styleFrom(
                              side: const BorderSide(color: MITIColor.gray600),
                              backgroundColor: V2MITIColor.gray9,
                            ),
                            child: Text(
                              '선택안함',
                              style: V2MITITextStyle.regularBold
                                  .copyWith(color: V2MITIColor.white),
                            )),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    Flexible(
                      flex: 2,
                      child: TextButton(
                          onPressed: widget.selectedItem.isNotEmpty
                              ? widget.onSubmitItem
                              : null,
                          style: TextButton.styleFrom(
                              backgroundColor: widget.selectedItem.isNotEmpty
                                  ? V2MITIColor.primary5
                                  : V2MITIColor.gray7),
                          child: Text(
                            '확인',
                            style: V2MITITextStyle.regularBold.copyWith(
                                color: widget.selectedItem.isNotEmpty
                                    ? V2MITIColor.black
                                    : V2MITIColor.white),
                          )),
                    ),
                  ],
                ))
          ],
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
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
            color: isSelected ? V2MITIColor.primary5 : V2MITIColor.gray8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: V2MITITextStyle.smallRegularTight.copyWith(
          color: V2MITIColor.gray1,
        ),
      ),
    );
  }
}
