import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameBody extends StatelessWidget {
  static String get routeName => 'game';

  const GameBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            centerTitle: true,
            title: Text('나의 참여 경기',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000000),
                )),
          ),
        ];
      },
      body: CustomScrollView(
        slivers: [],
      ),
    );
  }
}
