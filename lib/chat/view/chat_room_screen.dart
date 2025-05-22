import 'package:flutter/cupertino.dart';
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

class ChatRoomScreen extends StatefulWidget {
  static String get routeName => 'chatRoom';
  final int gameId;

  const ChatRoomScreen({super.key, required this.gameId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController textController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Scaffold 키 추가

  @override
  Widget build(BuildContext context) {
    final list = List.generate(10, (idx) => {1});

    return Scaffold(
      key: _scaffoldKey, // Scaffold에 키 설정
      endDrawer:  ChatDrawerComponent(gameId: widget.gameId,), // 오른쪽 드로어 추가
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

              final model = viewModel as DateChatModel;
              final chatsByDate = model.chatsByDate;
              final dates = model.chatsByDate.keys;
              final chats = dates.map((date) {
                final userChats = chatsByDate[date];
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ChatDateComponent(
                        date: date,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: ListView.separated(
                          itemBuilder: (_, idx) {
                            return userChats![idx].isMine
                                ? MyChatComponent(chat: userChats[idx],)
                                : OtherChatComponent();
                          },
                          separatorBuilder: (_, idx) {
                            return SizedBox(
                              height: 11.h,
                            );
                          },
                          itemCount: userChats?.length ?? 0,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();

              model.chatsByDate.forEach((date, userChats) {
                SliverToBoxAdapter(
                  child: ChatDateComponent(
                    date: date,
                  ),
                );
              });

              return Expanded(
                child: Scrollbar(
                  child: CustomScrollView(
                    reverse: true,
                    slivers: [
                      SliverMainAxisGroup(
                        slivers: [
                          if (model.currentIndex == model.endIndex)
                            SliverToBoxAdapter(
                              child: _InitChatMessageInfo(),
                            ),
                          // ...chats,
                          // SliverToBoxAdapter(
                          //   child: ChatDateComponent(date:,),
                          // ),
                          // SliverPadding(
                          //   padding: EdgeInsets.symmetric(horizontal: 8.w),
                          //   sliver: SliverList.separated(
                          //     itemBuilder: (_, idx) {
                          //       return idx % 2 == 0
                          //           ? OtherChatComponent()
                          //           : MyChatComponent();
                          //     },
                          //     separatorBuilder: (_, idx) {
                          //       return SizedBox(
                          //         height: 11.h,
                          //       );
                          //     },
                          //     itemCount: list.length,
                          //   ),
                          // )

                          // SliverList.separated(children: children)
                        ],
                      ),
                    ],
                  ),
                ),
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
            child: Row(
              children: [
                Expanded(
                    child: MultiLineTextField(
                  controller: textController,
                  hintText: "메세지를 입력해주세요",
                )),
                SizedBox(
                  width: 10.w,
                ),
                SizedBox(
                  width: 41.w,
                  child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "확인",
                        style: MITITextStyle.xxsm.copyWith(
                          color: MITIColor.gray800,
                        ),
                      )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}

class _InitChatMessageInfo extends StatelessWidget {
  const _InitChatMessageInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: MITIColor.gray750,
        ),
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
