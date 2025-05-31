import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/chat/provider/chat_form_provider.dart';
import 'package:miti/chat/provider/chat_notice_provider.dart';
import 'package:miti/chat/view/chat_notification_list_screen.dart';
import 'package:miti/chat/view/chat_notification_screen.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';

import '../../common/component/defalut_flashbar.dart';
import '../../theme/text_theme.dart';

class ChatNotificationFormScreen extends ConsumerStatefulWidget {
  final int gameId;
  final int? notificationId;

  static String get createRouteName => 'createChatNotificationForm';

  static String get editRouteName => 'editChatNotificationForm';

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

  bool get isEdit => widget.notificationId != null;

  String get buttonText => isEdit ? "삭제" : "작성";

  @override
  void initState() {
    super.initState();
    titleTextController = TextEditingController();
    bodyTextController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!isEdit) {
        final result = ref.read(userChatNoticeProvider(gameId: widget.gameId));
      }

      // if (widget.court == null) {
      //   final result = await ref.read(gameRecentHostingProvider.future);
      //
      //   if (result is ErrorModel) {
      //   } else {
      //     final model =
      //     (result as ResponseListModel<GameWithCourtResponse>).data!;
      //     if (model.isNotEmpty) {
      //       showCustomModalBottomSheet(
      //           context,
      //           GameRecentComponent(
      //             models: model,
      //             textEditingControllers: textEditingControllers,
      //           ));
      //     }
      //   }
      // } else {
      //   final name = widget.court?.name ?? '';
      //   final address = widget.court?.address ?? '';
      //   final addressDetail = widget.court?.addressDetail ?? '';
      //   ref.read(gameFormProvider.notifier).update(
      //     court: GameCourtParam(
      //       name: name,
      //       address: address,
      //       address_detail: addressDetail,
      //     ),
      //   );
      //   textEditingControllers[1].text = address;
      //   textEditingControllers[2].text = addressDetail;
      //   textEditingControllers[3].text = name;
      // }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isEdit) {
      final form = ref.read(chatFormProvider(
          gameId: widget.gameId, notificationId: widget.notificationId));
      titleTextController.text = form.title;
      bodyTextController.text = form.body;
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

    Widget? bottomButton;
    if (isEdit) {
      bottomButton = Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final valid = validButton(ref);

          return BottomButton(
              button: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor:
                          valid ? MITIColor.primary : MITIColor.gray500),
                  onPressed: valid
                      ? () async {
                          final result = await ref.read(
                              chatNoticeUpdateProvider(
                                      gameId: widget.gameId,
                                      notificationId: widget.notificationId!)
                                  .future);

                          if (result is ErrorModel) {
                            FlashUtil.showFlash(
                                context, '요청이 정상적으로 처리되지 않았습니다.',
                                textColor: MITIColor.error);
                          } else {
                            Map<String, String> pathParameters = {
                              'gameId': widget.gameId.toString(),
                              'notificationId': widget.notificationId.toString()
                            };

                            context.goNamed(ChatNotificationScreen.routeName,
                                pathParameters: pathParameters);
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              FlashUtil.showFlash(
                                context,
                                "공지사항이 수정되었습니다.",
                              );
                            });
                          }
                        }
                      : null,
                  child: Text(
                    "수정하기",
                    style: MITITextStyle.mdBold.copyWith(
                        color: valid ? MITIColor.gray800 : MITIColor.gray50),
                  )));
        },
      );
    }

    return Scaffold(
      backgroundColor: MITIColor.gray800,
      bottomNavigationBar: bottomButton,
      appBar: DefaultAppBar(
        backgroundColor: MITIColor.gray800,
        hasBorder: false,
        title: "공지 작성하기",
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final valid = validButton(ref) || isEdit;

              return Container(
                margin: EdgeInsets.only(right: 13.w),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100.r),
                  onTap: valid
                      ? () async {
                          final result = isEdit
                              ? await ref.read(chatNoticeDeleteProvider(
                                      gameId: widget.gameId,
                                      notificationId: widget.notificationId!)
                                  .future)
                              : await ref.read(chatNoticeCreateProvider(
                                      gameId: widget.gameId)
                                  .future);

                          if (result is ErrorModel) {
                            FlashUtil.showFlash(
                                context, '요청이 정상적으로 처리되지 않았습니다.',
                                textColor: MITIColor.error);
                          } else {
                            Map<String, String> pathParameters = {
                              'gameId': widget.gameId.toString()
                            };
                            context.goNamed(
                              ChatNotificationListScreen.routeName,
                              pathParameters: pathParameters,
                              extra: true,
                            );
                            String flashText = "";
                            if (isEdit) {
                              // 삭제
                              flashText = "공지사항이 삭제되었습니다.";
                            } else {
                              // 생성
                              flashText = "공지사항이 작성되었습니다.";
                            }
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              FlashUtil.showFlash(
                                context,
                                flashText,
                              );
                            });
                          }
                        }
                      : null,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    child: Text(
                      buttonText,
                      style: MITITextStyle.mdLight.copyWith(
                          color: valid
                              ? isEdit
                                  ? MITIColor.error
                                  : MITIColor.primary
                              : MITIColor.gray600),
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
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final title = ref.watch(chatFormProvider(
                        gameId: widget.gameId,
                        notificationId: widget.notificationId)
                    .select((s) => s.title));

                return TextField(
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
                      counterText: "",
                      filled: false,
                      suffixText: "(${title.length}/32)",
                      suffixStyle: MITITextStyle.sm.copyWith(
                        color: MITIColor.gray600,
                      )),
                  maxLength: 32,
                  maxLengthEnforcement:
                      MaxLengthEnforcement.truncateAfterCompositionEnds,
                  style: MITITextStyle.sm.copyWith(
                    color: MITIColor.gray100,
                  ),
                  onChanged: (v) {
                    if (v.length > 32) {
                      return;
                    }

                    ref
                        .read(chatFormProvider(
                                gameId: widget.gameId,
                                notificationId: widget.notificationId)
                            .notifier)
                        .update(title: v);
                  },
                );
              },
            ),
            SizedBox(height: 35.h),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final body = ref.watch(chatFormProvider(
                        gameId: widget.gameId,
                        notificationId: widget.notificationId)
                    .select((s) => s.body));

                return child!;
              },
              child: Expanded(
                child: Scrollbar(
                  child: _MultiLineTextField(
                    textController: bodyTextController,
                    inputBorder: inputBorder,
                    onChanged: (v) {
                      if (v.length > 3000) {
                        return;
                      }

                      ref
                          .read(chatFormProvider(
                                  gameId: widget.gameId,
                                  notificationId: widget.notificationId)
                              .notifier)
                          .update(body: v);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool validButton(WidgetRef ref) {
    final form = ref.watch(chatFormProvider(
      gameId: widget.gameId,
      notificationId: widget.notificationId,
    ));
    return form.title.isNotEmpty &&
        form.title.length <= 32 &&
        form.body.isNotEmpty &&
        form.body.length <= 3000;
  }
}

class _MultiLineTextField extends StatelessWidget {
  final TextEditingController textController;
  final InputBorder inputBorder;
  final ValueChanged<String> onChanged;

  const _MultiLineTextField(
      {super.key,
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
