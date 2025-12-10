import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/chat/model/chat_ui_model.dart';
import 'package:miti/chat/provider/chat_provider.dart';
import 'package:miti/chat/view/ui/chat_date_component.dart';
import 'package:miti/chat/view/ui/chat_drawer_component.dart';
import 'package:miti/chat/view/ui/my_chat_component.dart';
import 'package:miti/chat/view/ui/other_chat_component.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/defalut_flashbar.dart';
import '../../common/model/cursor_model.dart';
import '../component/chat_bubble_skeleton.dart';
import '../model/game_chat_room_approved_users_response.dart';
import '../provider/chat_approve_provider.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  static String get routeName => 'chatRoom';
  final int gameId;

  const ChatRoomScreen({super.key, required this.gameId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  TextEditingController textController = TextEditingController();
  late final FocusNode focusNode;
  late final ScrollController _scrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Scaffold 키 추가
  late Throttle<int> _throttler;
  int throttleCnt = 0;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) {
      log("api call sendMessage");

      sendMessage();
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMessages(); // 스크롤 끝에서 추가 로드
    }
  }

  @override
  void dispose() {
    _throttler.cancel();
    textController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _loadMoreMessages() {
    ref
        .read(chatPaginationProvider(gameId: widget.gameId).notifier)
        .getChatPagination(
          gameId: widget.gameId,
          fetchMore: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    return SelectableRegion(
      focusNode: focusNode,
      selectionControls: materialTextSelectionControls,
      child: Scaffold(
        key: _scaffoldKey, // Scaffold에 키 설정
        endDrawer: ChatDrawerComponent(
          gameId: widget.gameId,
        ), // 오른쪽 드로어 추가
        appBar: DefaultAppBar(
          title: "라커룸 채팅",
          actions: [
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer(); // 오른쪽 드로어 열기
              },
              icon: const Icon(Icons.menu),
            )
          ],
        ),
        body: Column(
          children: [
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final viewModel =
                    ref.watch(chatPaginationProvider(gameId: widget.gameId));
                if (viewModel is LoadingModel) {
                  return const Expanded(
                      child: ChatBubbleSkeleton());
                } else if (viewModel is ErrorModel) {
                  return const Expanded(child: Text("Error"));
                }

                final model = viewModel
                    as ResponseModel<CursorPaginationModel<ChatModel>>;
                final chatMessages = model.data!.items;
                if (chatMessages.isEmpty) {
                  return Expanded(
                      child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 10.h),
                        child: const _InitChatMessageInfo(),
                      ),
                    ],
                  ));
                }

                return Expanded(
                  child: Scrollbar(
                      child: Align(
                    alignment: Alignment.topCenter,
                    child: ListView.separated(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                      controller: _scrollController,
                      reverse: true,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        final message = chatMessages[index];
                        return _buildChatItem(message, index);
                      },
                      separatorBuilder: (_, index) {
                        if (chatMessages[index]
                            .showDate) {
                          return SizedBox(
                            height: 0.h,
                          );
                        }
                        return SizedBox(
                          height: 11.h,
                        );
                      },
                      itemCount: chatMessages.length,
                    ),
                  )),
                );
              },
            ),
            _ChatForm(
              gameId: widget.gameId,
              textController: textController,
              scrollController: _scrollController,
              sendMessage: () async {
                log("click sendMessage = ${textController.text}");
                _throttler.setValue(throttleCnt + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatModel message, int actualIndex) {
    final chat = <Widget>[];

    // ⭐ 첫 번째 메시지(가장 오래된)에 초기 정보 표시
    if (message.isFirstMessage) {
      chat.add(const _InitChatMessageInfo());
    }

    if (message.showDate) {
      chat.add(ChatDateComponent(date: message.date));
    }

    if (message.isMine) {
      chat.add(MyChatBubble.fromModel(chat: message));
    } else {
      chat.add(OtherChatBubble.fromModel(chat: message));
    }

    return Column(children: chat);
  }

  void sendMessage() async {
    final result = await ref
        .read(chatPaginationProvider(gameId: widget.gameId).notifier)
        .sendMessage(message: textController.text);
    if (result is ErrorModel) {
      FlashUtil.showFlash(context, "요청이 정상적으로 처리되지 않았습니다.",
          textColor: V2MITIColor.red5);
    } else {
      textController.clear();
    }
  }
}

class _ChatForm extends StatefulWidget {
  final int gameId;
  final TextEditingController textController;
  final ScrollController scrollController;
  final VoidCallback sendMessage;

  const _ChatForm(
      {super.key,
      required this.gameId,
      required this.textController,
      required this.scrollController,
      required this.sendMessage});

  @override
  State<_ChatForm> createState() => _ChatFormState();
}

class _ChatFormState extends State<_ChatForm> {
  @override
  void initState() {
    super.initState();
    widget.textController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.w,right:15.w, top: 10.h, bottom: 30.h),
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
        color: MITIColor.gray750,
      ))),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final userId = ref.watch(authProvider)?.id;

          final result = ref.watch(chatApproveProvider(gameId: widget.gameId));
          bool isExpired = true;
          if (result is LoadingModel || result is ErrorModel) {
            isExpired = false;
          } else {
            final model =
                (result as ResponseModel<GameChatRoomApprovedUsersResponse>)
                    .data!;
            isExpired = model.approvedUsers.contains(userId) && model.isExpired;
          }
          log("isExpired ${isExpired}");
          final hintText = isExpired ? "비활성화된 라커룸입니다." : "메세지를 입력해주세요";
          final enabled = !isExpired && widget.textController.text.isNotEmpty;
          log("textController.text = ${widget.textController.text} enabled = $enabled");
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: MultiLineTextField(
                  controller: widget.textController,
                  hintText: hintText,
                  enabled: !isExpired,
                ),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                width: 41.w,
                height: 30.h,
                child: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return TextButton(
                        onPressed: enabled
                            ? () async {
                                widget.sendMessage();
                                widget.scrollController.jumpTo(0);

                                // final result = await ref
                                //     .read(chatPaginationProvider(
                                //             gameId: widget.gameId)
                                //         .notifier)
                                //     .sendMessage(
                                //         message: widget.textController.text);
                                // if (result is ErrorModel) {
                                //   FlashUtil.showFlash(
                                //       context, "요청이 정상적으로 처리되지 않았습니다.",
                                //       textColor: V2MITIColor.red5);
                                // } else {
                                //   widget.textController.clear();
                                //   widget.scrollController.jumpTo(0);
                                // }
                              }
                            : () {},
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: enabled
                                ? V2MITIColor.primary5
                                : MITIColor.gray500),
                        child: Text(
                          "전송",
                          style: MITITextStyle.xxsm.copyWith(
                            color:
                                enabled ? MITIColor.gray800 : MITIColor.gray50,
                          ),
                        ));
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _InitChatMessageInfo extends StatelessWidget {
  const _InitChatMessageInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: MITIColor.gray750,
        ),
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        child: Text(
          "라커룸은 경기 시작 시간 이후 48시간 까지 이용 가능합니다.\n이용 가능 시간이 지나면 라커룸이 비활성화되며, 메세지를 전송 할 수 없습니다.",
          style: MITITextStyle.xxxsm140.copyWith(
            color: MITIColor.gray300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class MultiLineTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int maxLength;
  final bool showCounter;
  final String? Function(String?)? validator;
  final bool enabled;

  const MultiLineTextField({
    super.key,
    this.hintText,
    required this.controller,
    this.onChanged,
    this.focusNode,
    this.decoration,
    this.style,
    this.maxLength = 1500,
    this.showCounter = true,
    this.validator,
    this.enabled = true,
  });

  @override
  State<MultiLineTextField> createState() => _MultiLineTextFieldState();
}

class _MultiLineTextFieldState extends State<MultiLineTextField> {
  late int _currentLength;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.controller.text.length;
    widget.controller.addListener(_updateLength);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateLength);
    super.dispose();
  }

  void _updateLength() {
    if (mounted) {
      setState(() {
        _currentLength = widget.controller.text.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      style: widget.style ?? MITITextStyle.xxsm,
      textAlignVertical: TextAlignVertical.center,
      maxLines: null,
      // 줄 수 제한 없음
      minLines: 1,
      // 최소 1줄
      textInputAction: TextInputAction.newline,
      decoration: (widget.decoration ??
              InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    MITITextStyle.xxsm.copyWith(color: MITIColor.gray500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                  // borderSide: BorderSide(color: V2MITIColor.primary5),
                ),

                // 최소 높이 설정 및 contentPadding 을 적용하기 위해  isDense true 설정
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 11),
                // EdgeInsets.all(12.r),
                constraints: BoxConstraints(
                  minHeight: 30.h,
                  maxHeight: 4 * 20.h + 24.h, // 4줄 + 패딩
                ),
              ))
          .copyWith(
        // 카운터는 별도로 표시
        counterText: '',
      ),
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        // 최대 글자 수 제한
        if (value.length > widget.maxLength) {
          widget.controller.text = value.substring(0, widget.maxLength);
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.maxLength),
          );
        }
      },
    );
  }
}
