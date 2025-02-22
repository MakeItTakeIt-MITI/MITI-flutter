import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/account/view/bank_transfer_form_screen.dart';
import 'package:miti/common/component/default_appbar.dart';

import '../../common/component/dispose_sliver_pagination_list_view.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../game/component/game_list_component.dart';
import '../../game/component/skeleton/game_list_skeleton.dart';
import '../../game/model/game_model.dart';
import '../../game/model/v2/game/base_game_court_by_date_response.dart';
import '../param/court_pagination_param.dart';
import '../provider/court_pagination_provider.dart';

class CourtGameListScreen extends StatefulWidget {
  static String get routeName => 'courtGameList';
  final int courtId;

  const CourtGameListScreen({super.key, required this.courtId});

  @override
  State<CourtGameListScreen> createState() => _CourtGameListScreenState();
}

class _CourtGameListScreenState extends State<CourtGameListScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              const DefaultAppBar(
                title: '이 경기장에 생성된 경기',
                isSliver: true,
                hasBorder: false,
              ),
            ];
          },
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                sliver: Consumer(builder:
                    (BuildContext context, WidgetRef ref, Widget? child) {
                  return DisposeSliverPaginationListView(
                    provider: courtGamePageProvider(PaginationStateParam(
                        param: CourtPaginationParam(search: ''),
                        path: widget.courtId)),
                    itemBuilder:
                        (BuildContext context, int index, Base pModel) {
                      final model = pModel as BaseGameCourtByDateResponse;
                      return GameCardByDate.fromModel(model: model);
                    },
                    param: CourtPaginationParam(search: ''),
                    skeleton: const GameListSkeleton(),
                    controller: _scrollController,
                    emptyWidget: Container(),
                  );
                }),
                padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
              ),
            ],
          )),
    );
  }
}
