import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/court/provider/court_game_pagination_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../game/component/game_list_component.dart';
import '../../game/model/base_game_meta_response.dart';
import '../param/court_pagination_param.dart';
import 'court_map_screen.dart';

class CourtGameListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'courtGameList';
  final int courtId;

  const CourtGameListScreen({super.key, required this.courtId});

  @override
  ConsumerState<CourtGameListScreen> createState() =>
      _CourtGameListScreenState();
}

class _CourtGameListScreenState extends ConsumerState<CourtGameListScreen> {
  String? courtName;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);

    // todo 지우기 여부 확인
    WidgetsBinding.instance.addPostFrameCallback((s) {
      ref
          .read(scrollControllerProvider.notifier)
          .update((s) => _scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. 파라미터 객체를 변수로 고정 (혹은 Equatable이 적용되었다면 인라인으로 써도 됨)
    final paginationParam = CourtPaginationParam(search: '');
    const cursorParam = CursorPaginationParam();

    // 2. Provider 정의 (변수에 담아두면 실수를 줄일 수 있음)
    final provider = courtGamePaginationProvider(
      courtId: widget.courtId,
      param: paginationParam,
      cursorParam: cursorParam,
    );

    // 3. build 상단에서 watch 수행 (AppBar와 Body 모두 사용하기 위함)
    final state = ref.watch(provider);

    // 4. 상태에서 courtName 추출 (listen + setState 불필요)
    String titleName = '';
    if (state
        is ResponseModel<CursorPaginationModel<List<BaseGameMetaResponse>>>) {
      titleName = state.data?.items.firstOrNull?.firstOrNull?.courtName ?? '';
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) {
          return [
            DefaultAppBar(
              title: titleName, // 5. 추출한 이름 바로 사용
              isSliver: true,
              hasBorder: false,
            ),
          ];
        },
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
                child: Text(
                  '이 경기장에서 모집 중인 경기',
                  style: V2MITITextStyle.regularBold.copyWith(
                    color: V2MITIColor.white,
                  ),
                ),
              ),
            ),

            // 6. Body에서는 이미 watch한 'state'를 기반으로 렌더링
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              sliver: _buildGameList(context, state), // 별도 메서드로 분리하거나 바로 작성
            ),
          ],
        ),
      ),
    );
  }

// 리스트 렌더링 로직 분리 (가독성을 위해)
  Widget _buildGameList(BuildContext context, BaseModel state) {
    if (state is LoadingModel) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is ErrorModel) {
      // 에러 처리
      return SliverToBoxAdapter(child: Container());
    }

    final cp = state
        as ResponseModel<CursorPaginationModel<List<BaseGameMetaResponse>>>;

    if (cp.data!.items.isEmpty) {
      return SliverToBoxAdapter(child: Container());
    }

    return SliverList.separated(
      itemBuilder: (_, index) {
        if (index == cp.data!.items.length) {
          if (cp is! ResponseModel<CursorPaginationModelFetchingMore>) {
            return Container();
          }
          return const Center(child: CircularProgressIndicator());
        }
        return GameCardByDate.fromModel(model: cp.data!.items[index]);
      },
      itemCount: cp.data!.items.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 32.h),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 300) {
      ref
          .read(courtGamePaginationProvider(
                  courtId: widget.courtId,
                  param: CourtPaginationParam(search: ''),
                  cursorParam: const CursorPaginationParam())
              .notifier)
          .paginate(
            courtId: widget.courtId,
            cursorPaginationParams: const CursorPaginationParam(),
            fetchMore: true,
            param: CourtPaginationParam(search: ''),
          );
      // 스크롤이 끝에 도달했을 때 새로운 항목 로드
    }
  }
}
