import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/provider/router_provider.dart';
import '../../util/util.dart';
import '../model/game_model.dart';
import 'game_create_screen.dart';
import 'game_detail_screen.dart';

class GameUpdateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'gameUpdate';
  final int gameId;
  final int bottomIdx;

  const GameUpdateScreen({
    super.key,
    required this.gameId,
    required this.bottomIdx,
  });

  @override
  ConsumerState<GameUpdateScreen> createState() => _GameUpdateScreenState();
}

class _GameUpdateScreenState extends ConsumerState<GameUpdateScreen> {
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

  bool valid() {
    final form = ref.watch(gameFormProvider);
    return form.max_invitation.isNotEmpty &&
        form.min_invitation.isNotEmpty &&
        form.info.isNotEmpty &&
        ValidRegExp.validForm(form.min_invitation, form.max_invitation);
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
            DefaultAppBar(
              title: '경기 정보 수정',
              isSliver: true,
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result =
                      ref.watch(gameDetailProvider(gameId: widget.gameId));
                  if (result is LoadingModel) {
                    return CircularProgressIndicator();
                  } else if (result is ErrorModel) {
                    GameError.fromModel(model: result)
                        .responseError(context, GameApiType.get, ref);
                    return Text('에러');
                  }
                  result as ResponseModel<GameDetailModel>;
                  final model = result.data!;
                  return Column(
                    children: [
                      SummaryComponent.fromDetailModel(model: model),
                      getDivider(),
                      _GameUpdateFormComponent(
                        initMaxValue: model.max_invitation.toString(),
                        initMinValue: model.min_invitation.toString(),
                      ),
                      getDivider(),
                      _InfoComponent(
                        info: model.info,
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: TextButton(
                          onPressed: valid()
                              ? () async {
                                  final result = await ref.read(
                                      gameUpdateProvider(gameId: widget.gameId)
                                          .future);
                                  if (result is ErrorModel) {
                                    if (context.mounted) {
                                      GameError.fromModel(model: result)
                                          .responseError(
                                              context, GameApiType.update, ref);
                                    }
                                  } else {
                                    if (context.mounted) {
                                      final extra = CustomDialog(
                                        title: '경기 모집 정보 수정 완료',
                                        content: '경기 정보가 정상적으로 수정되었습니다.',
                                        onPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                          Map<String, String> pathParameters = {
                                            'gameId': widget.gameId.toString()
                                          };
                                          final Map<String, String>
                                              queryParameters = {
                                            'bottomIdx':
                                                widget.bottomIdx.toString()
                                          };
                                          context.goNamed(
                                            GameDetailScreen.routeName,
                                            pathParameters: pathParameters,
                                            queryParameters: queryParameters,
                                          );
                                        },
                                      );
                                      context.pushNamed(DialogPage.routeName,
                                          extra: extra);
                                    }
                                  }
                                }
                              : () {},
                          style: TextButton.styleFrom(
                              backgroundColor: valid()
                                  ? const Color(0xFF4065F6)
                                  : const Color(0xFFE8E8E8)),
                          child: Text(
                            '저장하기',
                            style: MITITextStyle.btnTextBStyle.copyWith(
                              color: valid()
                                  ? Colors.white
                                  : const Color(0xff969696),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getDivider() {
    return Container(
      height: 5.h,
      color: const Color(0xFFF8F8F8),
    );
  }
}

class _GameUpdateFormComponent extends ConsumerStatefulWidget {
  final String initMaxValue;
  final String initMinValue;

  const _GameUpdateFormComponent(
      {super.key, required this.initMaxValue, required this.initMinValue});

  @override
  ConsumerState<_GameUpdateFormComponent> createState() =>
      _GameUpdateFormComponentState();
}

class _GameUpdateFormComponentState
    extends ConsumerState<_GameUpdateFormComponent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(gameFormProvider.notifier).update(
          max_invitation: widget.initMaxValue,
          min_invitation: widget.initMinValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '경기 수정',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff040000),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '참여 인원 수정',
            style: MITITextStyle.selectionSubtitleStyle.copyWith(
              color: const Color(0xff040000),
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 19.5.w),
            child: ApplyForm(
              initMaxValue: widget.initMaxValue,
              initMinValue: widget.initMinValue,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoComponent extends ConsumerStatefulWidget {
  final String info;

  const _InfoComponent({super.key, required this.info});

  @override
  ConsumerState<_InfoComponent> createState() => _InfoComponentState();
}

class _InfoComponentState extends ConsumerState<_InfoComponent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(gameFormProvider.notifier).update(info: widget.info);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '모집 정보',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 22.h),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              reverse: true,
              child: TextFormField(
                initialValue: widget.info,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: MITITextStyle.inputValueMStyle.copyWith(
                  color: Colors.black,
                ),
                onChanged: (val) {
                  ref.read(gameFormProvider.notifier).update(info: val);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  constraints: BoxConstraints(
                    minHeight: 68.h,
                    maxHeight: 500.h,
                  ),
                  hintText:
                      '주차, 샤워 가능 여부, 경기 진행 방식, 필요한 유니폼 색상 등 참가들에게 공지할 정보들을 입력해주세요',
                  hintStyle: MITITextStyle.placeHolderMStyle
                      .copyWith(color: const Color(0xFF969696)),
                  hintMaxLines: 10,
                  fillColor: const Color(0xFFF7F7F7),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  // isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
