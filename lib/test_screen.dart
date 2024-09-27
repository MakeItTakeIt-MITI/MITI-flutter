import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class NestedCustomScrollExample extends StatefulWidget {
  static String get routeName => 'scroll';

  @override
  _NestedCustomScrollExampleState createState() =>
      _NestedCustomScrollExampleState();
}

class _NestedCustomScrollExampleState extends State<NestedCustomScrollExample> {
  final GlobalKey globalKey = GlobalKey();
  final FocusNode _textFieldFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 키보드 감지 리스너 설정
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        // _scrollToTextField();
      }
    });
  }

  // TextFormField로 스크롤 이동하는 함수
  void _scrollToTextField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // globalKey를 사용하여 TextFormField 위치를 구함
      final RenderBox renderBox =
      globalKey.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);

      // 키보드가 올라왔을 때, 해당 위치로 스크롤
      Future.delayed(Duration(milliseconds: 300), () {
        log("Scrolling to TextFormField");
        // _scrollController.animateTo(
        //   _scrollController.offset + position.dy - 100, // 약간의 여유 공간을 줌
        //   duration: Duration(milliseconds: 300),
        //   curve: Curves.easeInOut,
        // );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(title: Text('Nested Scroll Example')),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                // 여러 색깔의 200 높이 컨테이너 생성
                return Container(
                  height: 200,
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Center(
                    child: Text(
                      'Container $index',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                );
              },
              childCount: 10, // 10개의 색깔 컨테이너
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                // key: globalKey,
                // focusNode: _textFieldFocusNode, // 포커스 노드 연결
                maxLines: null, // 여러 줄 입력 허용
                decoration:
                InputDecoration(labelText: 'Last Text Form Field'),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: bottom,),)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }
}