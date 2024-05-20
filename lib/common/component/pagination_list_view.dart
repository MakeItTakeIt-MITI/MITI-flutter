import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../model/default_model.dart';
import '../model/model_id.dart';
import '../param/pagination_param.dart';
import '../provider/pagination_provider.dart';


enum ScrollDirection { horizontal, vertical }

typedef PaginationWidgetBuilder<T extends Base> = Widget Function(
    BuildContext context, int index, T model);

// class PaginationListView<T extends IModelWithId, S>
//     extends ConsumerStatefulWidget {
//   final ScrollDirection scrollDirection;
//   final StateNotifierProvider<PaginationProvider, BaseModel> provider;
//   final PaginationWidgetBuilder<T> itemBuilder;
//   final PaginationParam initParams;
//   final S? param;
//   final Widget skeleton;
//
//   const PaginationListView({
//     required this.scrollDirection,
//     required this.provider,
//     required this.itemBuilder,
//     required this.initParams,
//     required this.param,
//     required this.skeleton,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   ConsumerState<PaginationListView> createState() =>
//       _PaginationListViewState<T>();
// }
//
// class _PaginationListViewState<T extends IModelWithId>
//     extends ConsumerState<PaginationListView> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_scrollListener);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _scrollListener() {
//     // log("scrolling!!");
//
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       log("scroll end");
//       ref.read(widget.provider.notifier).paginate(
//         paginationParams: widget.initParams,
//         param: widget.param,
//         fetchMore: true,
//       );
//       // 스크롤이 끝에 도달했을 때 새로운 항목 로드
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(widget.provider);
//
//     // 완전 처음 로딩일때
//     if (state is LoadingModel) {
//       return widget.skeleton; // todo 스켈레톤 일반화
//     }
//     // 에러
//     if (state is ErrorModel) {
//       // if (state.metaData.message == DATA_NULL) {
//       //   return const Center(
//       //     child: Text("데이터가 없습니다."),
//       //   );
//       // }
//
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             'error message',
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16.0),
//           ElevatedButton(
//             onPressed: () {
//               ref.read(widget.provider.notifier).paginate(
//                 forceRefetch: true,
//                 paginationParams: widget.initParams,
//                 param: widget.param,
//               );
//             },
//             child: const Text(
//               '다시시도',
//             ),
//           ),
//         ],
//       );
//     }
//
//     // CursorPagination
//     // CursorPaginationFetchingMore
//     // CursorPaginationRefetching
//
//     final cp = state as ResponseModel<PaginationModel<T>>;
//     return ListView.separated(
//       controller: _scrollController,
//       scrollDirection: widget.scrollDirection == ScrollDirection.horizontal
//           ? Axis.horizontal
//           : Axis.vertical,
//       padding: EdgeInsets.symmetric(
//           horizontal:
//           widget.scrollDirection == ScrollDirection.horizontal ? 20.w : 0),
//       itemCount: cp.data!.length + 1,
//       itemBuilder: (_, index) {
//         if (index == (cp.data!.length)) {
//           return Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: cp is PaginationModelFetchingMore ? 16.0 : 0,
//               vertical: cp is PaginationModelFetchingMore ? 8.0 : 0,
//             ),
//             child: Center(
//               child: cp is PaginationModelFetchingMore
//                   ? const CircularProgressIndicator()
//                   : Container(),
//             ),
//           );
//         }
//
//         final pItem = cp.data![index];
//
//         return widget.itemBuilder(
//           context,
//           index,
//           pItem,
//         );
//       },
//       separatorBuilder: (_, index) {
//         final pItem = cp.data![index]; // todo 일반화 필요
//         if (pItem is Festival &&
//             (pItem.details == null || pItem.details!.isEmpty)) {
//           return Container();
//         }
//         return SizedBox(
//           height: cp.data!.length - 1 == index ? 0 : 16.h,
//           width: cp.data!.length - 1 == index ? 0 : 12.w,
//         );
//       },
//     );
//   }
// }
