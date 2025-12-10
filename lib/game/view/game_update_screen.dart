import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_bottom_sheet.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/defalut_flashbar.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../util/util.dart';
import '../model/v2/game/game_detail_response.dart';
import 'game_create_screen.dart';
import 'game_detail_screen.dart';

class GameUpdateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'gameUpdate';
  final int gameId;

  const GameUpdateScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameUpdateScreen> createState() => _GameUpdateScreenState();
}

class _GameUpdateScreenState extends ConsumerState<GameUpdateScreen> {
  late final ScrollController _scrollController;
  late Throttle<int> _throttler;
  bool isLoading = false;
  int throttleCnt = 0;

  final formKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  late final List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) async {
      setState(() {
        isLoading = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
      await onUpdate(context);
      setState(() {
        isLoading = false;
      });
    });
    for (int i = 0; i < 3; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          focusScrollable(i);
        }
      });
    }
  }

  void focusScrollable(int i) {
    Scrollable.ensureVisible(
      formKeys[i].currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _throttler.cancel();
    for (int i = 0; i < 3; i++) {
      focusNodes[i].removeListener(() {
        focusScrollable(i);
      });
    }
    _scrollController.dispose();
    super.dispose();
  }

  bool valid() {
    final form = ref.watch(gameFormProvider);
    // log('form.max_invitation.isNotEmpty = ${form.max_invitation.isNotEmpty }');
    // log('form.min_invitation.isNotEmpty = ${form.min_invitation.isNotEmpty }');
    // log('form.info.isNotEmpty = ${form.info.isNotEmpty }');
    return form.max_invitation.isNotEmpty &&
        form.min_invitation.isNotEmpty &&
        form.info.isNotEmpty &&
        ValidRegExp.validForm(form.min_invitation, form.max_invitation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '경기 수정하기',
        ),
        bottomNavigationBar: BottomButton(
          button: TextButton(
            onPressed: valid() && !isLoading
                ? () async {
                    _throttler.setValue(throttleCnt + 1);
                  }
                : () {},
            style: TextButton.styleFrom(
                backgroundColor: valid() && !isLoading
                    ? V2MITIColor.primary5
                    : V2MITIColor.gray7),
            child: Text(
              '수정하기',
              style: V2MITITextStyle.regularBold.copyWith(
                color: valid() && !isLoading
                    ? V2MITIColor.black
                    : V2MITIColor.white,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final result =
                        ref.watch(gameDetailProvider(gameId: widget.gameId));
                    if (result is LoadingModel) {
                      return const CircularProgressIndicator();
                    } else if (result is ErrorModel) {
                      GameError.fromModel(model: result)
                          .responseError(context, GameApiType.get, ref);
                      return const Text('에러');
                    }
                    result as ResponseModel<GameDetailResponse>;
                    final model = result.data!;
                    return Column(
                      spacing: 36.h,
                      children: [
                        Column(
                          spacing: 16.h,
                          children: [
                            SummaryComponent.fromDetailModel(
                              model: model,
                            ),

                            /// 무료 전환 버튼
                            if (model.fee != 0)
                              TextButton(
                                onPressed: () {
                                  final throttler = Throttle(
                                    const Duration(seconds: 1),
                                    initialValue: false,
                                    checkEquality: true,
                                  );
                                  throttler.values.listen((bool s) {
                                    _changeFree(ref, context);
                                  });

                                  CustomBottomSheet.showStringContent(
                                    context: context,
                                    title: '참가비 변경',
                                    content:
                                        '무료 경기 전환시,\n참가한 게스트들의 참가비는 자동으로 환불되며,\n유료 경기로 재전환이 불가합니다.',
                                    onPressed: () async {
                                      throttler.setValue(true);
                                    },
                                    buttonText: '무료 경기로 전환하기',
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 28.h),
                                    hasPop: true,
                                  );
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    side: WidgetStateProperty.all(
                                        const BorderSide(
                                            color: V2MITIColor.gray6))),
                                child: Text(
                                  "무료 경기로 전환하기",
                                  style: V2MITITextStyle.regularBold
                                      .copyWith(color: V2MITIColor.gray6),
                                ),
                              )
                          ],
                        ),
                        _GameUpdateFormComponent(
                          initMaxValue: model.max_invitation.toString(),
                          initMinValue: model.min_invitation.toString(),
                          focusNodes: focusNodes,
                          formKeys: formKeys,
                        ),
                        _InfoComponent(
                          info: model.info,
                          focusNodes: focusNodes,
                          formKeys: formKeys,
                        ),
                        SizedBox(height: 80.h),
                        // const Spacer(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeFree(WidgetRef ref, BuildContext context) async {
    final result =
        await ref.read(gameFreeProvider(gameId: widget.gameId!).future);

    if (context.mounted) {
      if (result is ErrorModel) {
        GameError.fromModel(model: result)
            .responseError(context, GameApiType.free, ref);
      } else {
        context.pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          FlashUtil.showFlash(context, '무료 경기로 전환되었습니다.');
        });
      }
    }
  }

  Future<void> onUpdate(BuildContext context) async {
    final result =
        await ref.read(gameUpdateProvider(gameId: widget.gameId).future);
    if (result is ErrorModel) {
      if (context.mounted) {
        GameError.fromModel(model: result)
            .responseError(context, GameApiType.update, ref);
      }
    } else {
      if (context.mounted) {
        showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            builder: (context) {
              return BottomDialog(
                title: '경기 모집 정보 수정 완료',
                content: '경기 정보가 정상적으로 수정되었습니다.',
                btn: TextButton(
                  onPressed: () {
                    Map<String, String> pathParameters = {
                      'gameId': widget.gameId.toString()
                    };
                    context.pop();
                    FocusScope.of(context).requestFocus(FocusNode());
                    context.goNamed(
                      GameDetailScreen.routeName,
                      pathParameters: pathParameters,
                    );
                  },
                  child: const Text("확인"),
                ),
              );
            });
      }
    }
  }

  Widget getDivider() {
    return Container(
      height: 5.h,
      color: MITIColor.gray750,
    );
  }
}

class _GameUpdateFormComponent extends ConsumerStatefulWidget {
  final String initMaxValue;
  final String initMinValue;
  final List<GlobalKey> formKeys;
  final List<FocusNode> focusNodes;

  const _GameUpdateFormComponent({
    super.key,
    required this.initMaxValue,
    required this.initMinValue,
    required this.formKeys,
    required this.focusNodes,
  });

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '참여 인원 수정',
          style: V2MITITextStyle.smallRegularNormal.copyWith(
            color: V2MITIColor.white,
          ),
        ),
        SizedBox(height: 4.h),
        ApplyForm(
          initMaxValue: widget.initMaxValue,
          initMinValue: widget.initMinValue,
          formKeys: widget.formKeys,
          focusNodes: widget.focusNodes,
          isUpdateForm: true,
        ),
      ],
    );
  }
}

class _InfoComponent extends ConsumerStatefulWidget {
  final String info;
  final List<GlobalKey> formKeys;
  final List<FocusNode> focusNodes;

  const _InfoComponent({
    super.key,
    required this.info,
    required this.formKeys,
    required this.focusNodes,
  });

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '모집 정보',
          style: V2MITITextStyle.regularBold.copyWith(
            color: V2MITIColor.white,
          ),
        ),
        Divider(color: V2MITIColor.gray10, height: 16.h),
        Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: true,
            child: TextFormField(
              focusNode: widget.focusNodes[2],
              key: widget.formKeys[2],
              initialValue: widget.info,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: MITITextStyle.sm150.copyWith(
                color: MITIColor.gray100,
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
                hintStyle: MITITextStyle.sm150.copyWith(
                  color: MITIColor.gray500,
                ),
                hintMaxLines: 10,
                fillColor: MITIColor.gray700,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                // isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
