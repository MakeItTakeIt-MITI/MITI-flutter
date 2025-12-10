import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/chat/provider/chat_form_provider.dart';
import 'package:miti/chat/provider/chat_notice_provider.dart';
import 'package:miti/chat/view/chat_notification_list_screen.dart';
import 'package:miti/chat/view/chat_notification_screen.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';

import '../../common/component/custom_bottom_sheet.dart';
import '../../common/component/defalut_flashbar.dart';
import '../../common/component/form/multi_line_text_field.dart';
import '../../common/component/form/under_line_text_field.dart';
import '../../common/model/cursor_model.dart';
import '../../court/component/court_list_component.dart';
import '../../game/component/game_recent_component.dart';
import '../../notification/model/game_chat_notification_response.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class ChatNotificationFormScreen extends ConsumerStatefulWidget {
  final int gameId;
  final int? notificationId;

  static String get createRouteName => 'createChatNotificationForm';

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
  List<FocusNode> focusNodes = [FocusNode(), FocusNode()];

  bool get isEdit => widget.notificationId != null;

  String get buttonText => isEdit ? "삭제" : "작성";
  late Throttle<int> _updateThrottler;
  int updateThrottleCnt = 0;
  bool isBottomLoading = false;
  final inputBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: MITIColor.gray600, width: .5));

  // 추가, 삭제
  late Throttle<int> _throttler;
  int throttleCnt = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleTextController = TextEditingController();
    bodyTextController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!isEdit) {
        final result = await ref.read(userChatNoticeProvider().future);

        if (result is ErrorModel) {
        } else {
          final model = (result as ResponseModel<
                  CursorPaginationModel<GameChatNotificationResponse>>)
              .data!;
          if (model.items.isNotEmpty) {
            showCustomModalBottomSheet(
                context,
                UserChatNoticeComponent(
                  models: model.items,
                  onSelect: () {
                    final selected = ref.read(selectedProvider);
                    final select =
                        model.items.firstWhere((m) => m.id == selected);
                    ref
                        .read(chatFormProvider(gameId: widget.gameId).notifier)
                        .update(title: select.title, body: select.body);
                    titleTextController.text = select.title;
                    bodyTextController.text = select.body;
                    context.pop();
                  },
                ));
          }
        }
      }
    });

    _updateThrottler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _updateThrottler.values.listen((int s) async {
      setState(() {
        isBottomLoading = true;
      });
      log("message");
      Future.delayed(const Duration(seconds: 1), () {
        updateThrottleCnt++;
      });
      // await updateNotification(ref, context);
      setState(() {
        isBottomLoading = false;
      });
    });

    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) async {
      setState(() {
        isLoading = true;
      });
      await onClickAction(ref, context);
      throttleCnt++;
      setState(() {
        isLoading = false;
      });
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
    _throttler.cancel();
    _updateThrottler.cancel();
    titleTextController.dispose();
    bodyTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? bottomButton;
    if (isEdit) {
      bottomButton = Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          log("isBottomLoading = $isBottomLoading");
          final valid = validButton(ref) && !isBottomLoading;

          return BottomButton(
              button: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor:
                          valid ? V2MITIColor.primary5 : MITIColor.gray500),
                  onPressed: valid
                      ? () async {
                          _updateThrottler.setValue(updateThrottleCnt + 1);
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
      bottomNavigationBar: bottomButton,
      appBar: DefaultAppBar(
        hasBorder: false,
        title: "공지 작성하기",
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final valid = (validButton(ref) || isEdit) && !isLoading;

              return Container(
                margin: EdgeInsets.only(right: 13.w),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100.r),
                  onTap: valid
                      ? () async {
                          _throttler.setValue(throttleCnt + 1);
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
                                  ? V2MITIColor.red5
                                  : V2MITIColor.primary5
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
                return UnderLineTextField(
                  textStyle: MITITextStyle.sm,
                  title: title,
                  textEditingController: titleTextController,
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
                  hintText: "제목을 입력해주세요",
                  focusNode: focusNodes[0],
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
                  child: MultiLineTextField(
                    textStyle: MITITextStyle.sm,
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
                    hintText: "경기 참가자들에게 공유할 내용을 작성해주세요.",
                    focusNode: focusNodes[1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onClickAction(WidgetRef ref, BuildContext context) async {
    final result = isEdit
        ? await ref.read(chatNoticeDeleteProvider(
                gameId: widget.gameId, notificationId: widget.notificationId!)
            .future)
        : await ref
            .read(chatNoticeCreateProvider(gameId: widget.gameId).future);

    if (result is ErrorModel) {
      FlashUtil.showFlash(context, '요청이 정상적으로 처리되지 않았습니다.',
          textColor: V2MITIColor.red5);
    } else {
      Map<String, String> pathParameters = {'gameId': widget.gameId.toString()};
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
      Future.delayed(const Duration(milliseconds: 200), () {
        FlashUtil.showFlash(
          context,
          flashText,
        );
      });
    }
  }

  Future<void> updateNotification(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(chatNoticeUpdateProvider(
            gameId: widget.gameId, notificationId: widget.notificationId!)
        .future);

    if (result is ErrorModel) {
      FlashUtil.showFlash(context, '요청이 정상적으로 처리되지 않았습니다.',
          textColor: V2MITIColor.red5);
    } else {
      Map<String, String> pathParameters = {
        'gameId': widget.gameId.toString(),
        'notificationId': widget.notificationId.toString()
      };

      context.goNamed(ChatNotificationScreen.routeName,
          pathParameters: pathParameters);
      Future.delayed(const Duration(milliseconds: 200), () {
        FlashUtil.showFlash(
          context,
          "공지사항이 수정되었습니다.",
        );
      });
    }
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

class UserChatNoticeComponent extends ConsumerWidget {
  final List<GameChatNotificationResponse> models;
  final VoidCallback onSelect;

  const UserChatNoticeComponent({
    super.key,
    required this.models,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "경기 공지사항",
                  style: MITITextStyle.mdBold.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(
                    AssetUtil.getAssetPath(
                        type: AssetType.icon, name: 'remove'),
                  ),
                )
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, idx) {
              return GameBottomSheetCard.fromUserChatNoticeModel(
                model: models[idx],
              );
            },
            separatorBuilder: (_, idx) => SizedBox(
                  height: 12.h,
                ),
            itemCount: models.length),
        SizedBox(height: 20.h),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final selected = ref.watch(selectedProvider);
            return TextButton(
                onPressed: selected != null ? onSelect : () {},
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(selected != null
                        ? V2MITIColor.primary5
                        : MITIColor.gray500)),
                child: Text(
                  "공지사항 불러오기",
                  style: MITITextStyle.mdBold.copyWith(
                      color: selected != null
                          ? MITIColor.gray800
                          : MITIColor.gray50),
                ));
          },
        ),
      ],
    );
  }
}
