import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/chat/model/base_game_chat_message_response.dart';
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
import 'package:miti/util/util.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/defalut_flashbar.dart';
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
  late final ScrollController _scrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Scaffold 키 추가

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMessages(); // 스크롤 끝에서 추가 로드
    }
  }

  @override
  void dispose() {
    textController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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
    return Scaffold(
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
                    child: Center(child: CircularProgressIndicator()));
              } else if (viewModel is ErrorModel) {
                return const Expanded(child: Text("Error"));
              }

              final model =
                  viewModel as ResponseModel<PaginationModel<ChatModel>>;
              final chatMessages = model.data!.page_content;

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
                      final actualIndex = chatMessages.length - 1 - index;
                      final message = chatMessages[actualIndex];
                      return _buildChatItem(message, actualIndex);
                    },
                    separatorBuilder: (_, index) {
                      if (chatMessages[chatMessages.length - 1 - index]
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: MITIColor.gray750,
            ))),
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final userId = ref.watch(authProvider)?.id;

                final result =
                    ref.watch(chatApproveProvider(gameId: widget.gameId));
                bool isExpired = true;
                if (result is LoadingModel || result is ErrorModel) {
                  isExpired = false;
                } else {
                  final model = (result
                          as ResponseModel<GameChatRoomApprovedUsersResponse>)
                      .data!;
                  isExpired =
                      model.approvedUsers.contains(userId) && !model.isExpired;
                }
                final enabled = !isExpired && textController.text.isNotEmpty;
                return Row(
                  children: [
                    Expanded(
                        child: MultiLineTextField(
                      controller: textController,
                      hintText: "메세지를 입력해주세요",
                      enabled: isExpired,
                    )),
                    SizedBox(
                      width: 10.w,
                    ),
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        return SizedBox(
                          width: 41.w,
                          child: TextButton(
                              onPressed: enabled
                                  ? () async {
                                      log("sendMessage = ${textController.text}");
                                      final result = await ref
                                          .read(chatPaginationProvider(
                                                  gameId: widget.gameId)
                                              .notifier)
                                          .sendMessage(
                                              message: textController.text);
                                      if (result is ErrorModel) {
                                        FlashUtil.showFlash(
                                            context, "요청이 정상적으로 처리되지 않았습니다.",
                                            textColor: MITIColor.error);
                                      } else {
                                        textController.clear();
                                        _scrollController.jumpTo(0);
                                      }
                                    }
                                  : () {},
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      enabled
                                          ? MITIColor.primary
                                          : MITIColor.gray500)),
                              child: Text(
                                "확인",
                                style: MITITextStyle.xxsm.copyWith(
                                  color: enabled
                                      ? MITIColor.gray800
                                      : MITIColor.gray50,
                                ),
                              )),
                        );
                      },
                    )
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatModel message, int actualIndex) {
    final chat = <Widget>[];

    // ⭐ 첫 번째 메시지(가장 오래된)에 초기 정보 표시
    if (actualIndex == 0) {
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 30.h,
        maxHeight: 4 * 20.h + 24.h, // 4줄 + 패딩
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        style: widget.style ?? MITITextStyle.md,
        maxLines: null,
        // 줄 수 제한 없음
        minLines: 1,
        // 최소 1줄
        textInputAction: TextInputAction.newline,
        decoration: (widget.decoration ??
                InputDecoration(
                  hintText: widget.hintText,
                  hintStyle:
                      MITITextStyle.md.copyWith(color: MITIColor.gray500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                    // borderSide: BorderSide(color: MITIColor.primary),
                  ),
                  contentPadding: EdgeInsets.all(12.r),
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
      ),
    );
  }
}
