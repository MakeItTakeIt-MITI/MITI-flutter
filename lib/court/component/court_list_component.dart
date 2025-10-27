import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/court/component/court_card.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../game/param/game_param.dart';
import '../model/court_model.dart';
import '../model/v2/court_map_response.dart';

typedef LoadCourtInfoCallback = void Function(GameCourtParam court);

final selectedProvider = StateProvider.autoDispose<int?>((ref) => null);
final selectedCourtProvider =
    StateProvider.autoDispose<CourtMapResponse?>((ref) => null);

class CourtListComponent extends ConsumerStatefulWidget {
  final List<CourtMapResponse> models;
  final LoadCourtInfoCallback loadCallback;

  const CourtListComponent({
    super.key,
    required this.loadCallback,
    required this.models,
  });

  @override
  ConsumerState<CourtListComponent> createState() => _CourtListComponentState();
}

class _CourtListComponentState extends ConsumerState<CourtListComponent> {
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
    log("build!!");
    // final form = ref.watch(courtSearchProvider);
    // final search = ref.watch(gameFormProvider).court.address;
    // log("search address = $search");
    // final param = CourtPaginationParam(search: search);
    // final result = ref.watch(courtListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '경기장 목록',
              style: MITITextStyle.mdBold.copyWith(
                color: MITIColor.gray100,
              ),
            ),
            InkWell(
              onTap: () => context.pop(),
              child: const Icon(Icons.close),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Align(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 2,
            ),
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final selected = ref.watch(selectedCourtProvider);
                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (_, idx) => CourtAddressCard.fromModel(
                    model: widget.models[idx],
                    selected: selected?.id == widget.models[idx].id,
                    onTap: () {
                      ref.read(selectedCourtProvider.notifier).update((state) =>
                          selected?.id != widget.models[idx].id
                              ? widget.models[idx]
                              : null);
                    },
                  ),
                  separatorBuilder: (_, idx) => SizedBox(
                    height: 16.h,
                  ),
                  itemCount: widget.models.length,
                );

                // return DisposeSliverPaginationListView(
                //   provider: courtPageProvider(PaginationStateParam(
                //     param: param,
                //   )),
                //   itemBuilder:
                //       (BuildContext context, int index, Base model) {
                //     model as CourtMapResponse;
                //     return CourtAddressCard.fromModel(
                //       model: model,
                //       selected: selected?.id == model.id,
                //       onTap: () {
                //         ref.read(selectedCourtProvider.notifier).update(
                //                 (state) =>
                //             selected?.id != model.id ? model : null);
                //       },
                //     );
                //   },
                //   param: param,
                //   skeleton: const CourtListSkeleton(),
                //   controller: _scrollController,
                //   emptyWidget: Container(),
                // );
              },
            ),
          ),
        ),
        // Consumer(
        //   builder: (BuildContext context, WidgetRef ref, Widget? child) {
        //     return ListView.separated(
        //         shrinkWrap: true,
        //         physics: const NeverScrollableScrollPhysics(),
        //         itemBuilder: (_, idx) {
        //           return Consumer(
        //             builder:
        //                 (BuildContext context, WidgetRef ref, Widget? child) {
        //               final selected = ref.watch(selectedProvider);
        //               return CourtAddressCard.fromModel(
        //                 model: model.data!.page_content[idx],
        //                 selected:
        //                     selected == model.data!.page_content[idx].id,
        //                 onTap: () {
        //                   onTap(ref, idx, model);
        //                 },
        //               );
        //             },
        //           );
        //         },
        //         separatorBuilder: (_, idx) {
        //           return SizedBox(height: 6.h);
        //         },
        //         itemCount: model.data!.page_content.length);
        //   },
        // ),

        SizedBox(height: 20.h),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final selected = ref.watch(selectedCourtProvider);
            return TextButton(
                onPressed: selected != null
                    ? () {
                        selectCourt(ref, context, widget.loadCallback);
                      }
                    : () {},
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(selected != null
                        ? MITIColor.primary
                        : MITIColor.gray500)),
                child: Text(
                  "경기장 정보 불러오기",
                  style: MITITextStyle.mdBold.copyWith(
                      color: selected != null
                          ? MITIColor.gray800
                          : MITIColor.gray50),
                ));
          },
        ),
      ],
    );

    // if (result is LoadingModel) {
    //   return Container();
    // } else if (result is ErrorModel) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     context.pop();
    //   });
    //   return Container();
    // }
    // final model = result as ResponseModel<PaginationModel<CourtSearchModel>>;
    // if (model.data!.page_content.isEmpty) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     context.pop();
    //   });
    //   return Container();
    // } else {
    //   return ;
    // }
  }

  void onTap(WidgetRef ref, int idx,
      ResponseModel<CursorPaginationModel<CourtSearchModel>> model) {
    final selectId = ref.read(selectedProvider);
    if (selectId == model.data!.items[idx].id) {
      ref.read(selectedProvider.notifier).update((state) => null);
    } else {
      ref
          .read(selectedProvider.notifier)
          .update((state) => model.data!.items[idx].id);
    }
  }

  void selectCourt(
      WidgetRef ref, BuildContext context, LoadCourtInfoCallback loadCallback) {
    /// 게임 생성 폼을 닫은 후 늦게 갱신 !!
    /// 게임 폼이 부모 트리에 있기 때문에 갱신 되면 build를 하면서
    /// 자식인 해당 다이어로그까지 build 되어 닫히는게 버벅이는 현상이 있기 때문
    final model = ref.read(selectedCourtProvider)!;

    final court = ref.read(gameFormProvider).court;
    final newCourt =
        court.copyWith(name: model.name, address_detail: model.addressDetail);

    loadCallback(newCourt);

    // ref.read(gameFormProvider.notifier).selectGameHistory(
    //     model: model, textEditingControllers: textEditingControllers);

    ref.read(gameFormProvider.notifier).update(court: newCourt);

    context.pop();
  }
}
