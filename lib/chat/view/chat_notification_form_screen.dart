import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/chat/provider/chat_form_provider.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/theme/color_theme.dart';

import '../../theme/text_theme.dart';
import 'chat_room_screen.dart';

class ChatNotificationFormScreen extends ConsumerStatefulWidget {
  final int gameId;
  final int? notificationId;

  static String get routeName => 'chatNotificationForm';

  const ChatNotificationFormScreen(
      {super.key, required this.gameId, this.notificationId});

  @override
  ConsumerState<ChatNotificationFormScreen> createState() =>
      _ChatNotificationFormScreenState();
}

class _ChatNotificationFormScreenState
    extends ConsumerState<ChatNotificationFormScreen> {
  late final TextEditingController bodyTextController;
  late final TextEditingController titleTextController;

  @override
  void initState() {
    titleTextController = TextEditingController();
    bodyTextController = TextEditingController();

    bodyTextController.addListener(_updateLength);

    super.initState();
  }

  void _updateLength() {
    if (mounted) {
      // todo form update
      // ref.read(chatFormProvider.notifier).update(body)


    }
  }

  @override
  void dispose() {
    titleTextController.dispose();
    bodyTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const inputBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: MITIColor.gray600, width: .5));

    return Scaffold(
      backgroundColor: MITIColor.gray800,
      appBar: DefaultAppBar(
        backgroundColor: MITIColor.gray800,
        hasBorder: false,
        title: "공지 작성하기",
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final valid = ref.watch(chatFormProvider.notifier).valid();
              return Container(
                margin: EdgeInsets.only(right: 13.w),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100.r),
                  onTap: valid ? () {} : null,
                  child: Container(
                    // Adding padding around the text to increase the tappable area
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    child: Text(
                      "작성",
                      style: MITITextStyle.mdLight.copyWith(
                          color: valid ? MITIColor.primary : MITIColor.gray600),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "제목",
              style: MITITextStyle.mdBold.copyWith(color: Colors.white),
            ),
            SizedBox(height: 12.h),
            TextField(
              textInputAction: TextInputAction.next,
              controller: titleTextController,
              decoration: InputDecoration(
                  hintText: "제목을 입력해주세요",
                  hintStyle: MITITextStyle.sm.copyWith(
                    color: MITIColor.gray600,
                  ),
                  enabledBorder: inputBorder,
                  border: inputBorder,
                  focusedBorder: inputBorder,
                  contentPadding: EdgeInsets.all(0.r),
                  filled: false,
                  suffixText: "(32)",
                  suffixStyle: MITITextStyle.sm.copyWith(
                    color: MITIColor.gray600,
                  )),
              style: MITITextStyle.sm.copyWith(
                color: MITIColor.gray100,
              ),
            ),
            SizedBox(height: 35.h),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final body = ref.watch(chatFormProvider.select((s) => s.body));

                return child!;
              },
              child: Expanded(
                child: Scrollbar(
                  child: _MultiLineTextField(
                    textController: bodyTextController,
                    inputBorder: inputBorder,
                    onChanged: (v) {
                      if (v.length > 3000)
                        return;

                      ref.read(chatFormProvider.notifier).update(body: v);
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MultiLineTextField extends StatelessWidget {
  final TextEditingController textController;
  final InputBorder inputBorder;
  final ValueChanged<String> onChanged;

  const _MultiLineTextField({super.key,
    required this.textController,
    required this.inputBorder,
    required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      maxLines: null,
      expands: true,
      maxLength: 3000,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        counterText: "",
        hintText: "경기 참가자들에게 공유할 내용을 작성해주세요.",
        hintStyle: MITITextStyle.sm.copyWith(
          color: MITIColor.gray600,
        ),
        enabledBorder: inputBorder.copyWith(borderSide: BorderSide.none),
        border: inputBorder.copyWith(borderSide: BorderSide.none),
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide.none),
        contentPadding: EdgeInsets.all(0.r),
        filled: false,
      ),
      onChanged: onChanged,
      style: MITITextStyle.sm.copyWith(
        color: MITIColor.gray100,
      ),
    );
  }
}
