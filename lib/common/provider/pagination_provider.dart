// import 'dart:developer';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../model/default_model.dart';
// import '../model/model_id.dart';
// import '../param/pagination_param.dart';
// import '../repository/base_pagination_repository.dart';
//
// class PaginationProvider<T extends Base, S extends DefaultParam,
//         U extends IBasePaginationRepository<T, S>>
//     extends StateNotifier<BaseModel> {
//   final U repository;
//   final PaginationParam pageParams;
//   final S? param;
//   final int? path;
//
//   PaginationProvider({
//     required this.repository,
//     required this.pageParams,
//     this.param,
//     this.path,
//   }) : super(LoadingModel()) {
//     log("pagination Provider init");
//     log("param ${param}");
//     paginate(
//       paginationParams: pageParams,
//       param: param,
//       path: path,
//     );
//   }
//
//   Future<void> paginate(
//       {required PaginationParam paginationParams,
//       S? param,
//       int? path,
//       bool fetchMore = false,
//       bool forceRefetch = false}) async {
//     try {
//       log('prev state type = ${state.runtimeType}');
//
//       if (state is ResponseModel<PaginationModel> && !forceRefetch) {
//         final pState = (state as ResponseModel<PaginationModel>).data!;
//         // 다음 페이지가 없을 경우
//         if (pState.end_index == pState.current_index) {
//           log('다음 페이지가 없을 경우');
//           return;
//         }
//       }
//       final isLoading = state is LoadingModel;
//       final isRefetching = state is ResponseModel<PaginationModelRefetching>;
//       final isFetchingMore =
//           state is ResponseModel<PaginationModelFetchingMore>;
//
//       if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
//         return;
//       }
//       log("fetchMore = $fetchMore");
//       if (fetchMore) {
//         final pState = state as ResponseModel<PaginationModel<T>>;
//         state = ResponseModel(
//             status_code: pState.status_code,
//             message: pState.message,
//             data: PaginationModelFetchingMore<T>(
//                 start_index: pState.data!.start_index,
//                 end_index: pState.data!.end_index,
//                 current_index: pState.data!.current_index + 1,
//                 page_content: pState.data!.page_content));
//
//         paginationParams =
//             paginationParams.copyWith(page: pState.data!.current_index + 1);
//       } else {
//         if (state is ResponseModel<PaginationModel> && !forceRefetch) {
//           final pState = state as ResponseModel<PaginationModel<T>>;
//           state = ResponseModel(
//               status_code: pState.status_code,
//               message: pState.message,
//               data: PaginationModelRefetching<T>(
//                   start_index: pState.data!.start_index,
//                   end_index: pState.data!.end_index,
//                   current_index: pState.data!.current_index,
//                   page_content: pState.data!.page_content));
//         } else {
//           state = LoadingModel();
//         }
//       }
//
//       final resp = await repository.paginate(
//         paginationParams: paginationParams,
//         param: param,
//         path: path,
//       );
//       log("resp type = ${resp.runtimeType}");
//       log("mid state type = ${state.runtimeType} ");
//       if (state is ResponseModel<PaginationModelFetchingMore>) {
//         final pState = state as ResponseModel<PaginationModelFetchingMore<T>>;
//         final data = pState.data!.copyWith(page_content: [
//           ...pState.data!.page_content,
//           ...resp.data!.page_content,
//         ]);
//
//         state = resp.copyWith(
//           data: data,
//         );
//         log("change state type = ${state.runtimeType} ");
//       } else {
//         state = resp;
//       }
//       log("after state type = ${state.runtimeType} ");
//     } catch (e, stack) {
//       log("pagination error = $e}");
//       log("pagination stack = $stack}");
//       state = ErrorModel.respToError(e);
//     }
//   }
// }
