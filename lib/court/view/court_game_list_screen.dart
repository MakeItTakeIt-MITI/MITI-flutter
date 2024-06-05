import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/court/component/court_search_card.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:miti/court/param/court_pagination_param.dart';
import 'package:miti/court/provider/court_pagination_provider.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/component/default_appbar.dart';
import '../../common/model/model_id.dart';
import '../../game/component/game_list_component.dart';
import '../../game/model/game_model.dart';

class CourtGameListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'courtGameList';
  final int bottomIdx;
  final CourtSearchModel model;
  final int courtId;

  const CourtGameListScreen({
    super.key,
    required this.courtId,
    required this.model,
    required this.bottomIdx,
  });

  @override
  ConsumerState<CourtGameListScreen> createState() =>
      _CourtGameListScreenState();
}

class _CourtGameListScreenState extends ConsumerState<CourtGameListScreen> {
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
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              title: '경기장 조회',
              isSliver: true,
            )
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(14.r),
              sliver: SliverMainAxisGroup(slivers: [
                SliverToBoxAdapter(
                  child: ResultCard.fromModel(
                    model: widget.model,
                    onTap: () {
                      final content =
                          '${widget.model.name} ${widget.model.address} ${widget.model.address}';
                      Share.share(content);
                    },
                    isShare: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 14.h, bottom: 20.h),
                    child: Text(
                      '경기목록',
                      style: MITITextStyle.sectionTitleStyle,
                    ),
                  ),
                ),
                Consumer(builder:
                    (BuildContext context, WidgetRef ref, Widget? child) {
                  return DisposeSliverPaginationListView(
                    provider: courtGamePageProvider(PaginationStateParam(
                        param: CourtPaginationParam(search: ''),
                        path: widget.courtId)),
                    itemBuilder:
                        (BuildContext context, int index, Base pModel) {
                      final model = pModel as GameListByDateModel;
                      return GameCardByDate.fromModel(model: model, bottomIdx: widget.bottomIdx,);
                    },
                    param: CourtPaginationParam(search: ''),
                    skeleton: Container(),
                    controller: _scrollController,
                    emptyWidget: Container(),
                  );
                }),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
