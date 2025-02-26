// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:miti/common/provider/remote_config_model.dart';
//
// class UpdateCheckerWidget extends ConsumerStatefulWidget {
//   final Widget child;
//
//   const UpdateCheckerWidget({
//     Key? key,
//     required this.child,
//   }) : super(key: key);
//
//   @override
//   ConsumerState<UpdateCheckerWidget> createState() => _UpdateCheckerWidgetState();
// }
//
// class _UpdateCheckerWidgetState extends ConsumerState<UpdateCheckerWidget> {
//   bool _dialogShown = false;
//   bool _isNavigatorReady = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // UI 초기화 후에 확인 작업 시작
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // 플래그 설정 (Navigator가 준비됨)
//       setState(() {
//         _isNavigatorReady = true;
//       });
//       // 초기 상태 확인
//       _checkCurrentUpdateStatus();
//     });
//   }
//
//   // 현재 상태를 확인하는 메서드
//   void _checkCurrentUpdateStatus() {
//     if (!_isNavigatorReady) {
//       log("Skipping update check - Navigator not ready");
//       return;
//     }
//
//     final remoteConfigState = ref.read(remoteConfigProvider);
//     log("Initial remote config state check: initialized=${remoteConfigState.initialized}, forceUpdate=${remoteConfigState.forceUpdate}, recommendedUpdate=${remoteConfigState.recommendedUpdate}");
//
//     // Remote Config가 이미 초기화된 경우 즉시 체크
//     if (remoteConfigState.initialized) {
//       _processUpdateStatus(remoteConfigState);
//     }
//   }
//
//   // Remote Config 상태를 처리하는 메서드
//   void _processUpdateStatus(RemoteConfigState state) {
//     if (!_isNavigatorReady) {
//       log("Skipping update processing - Navigator not ready");
//       return;
//     }
//
//     log("Processing update status: forceUpdate=${state.forceUpdate}, recommendedUpdate=${state.recommendedUpdate}");
//
//     if (state.forceUpdate) {
//       _showUpdateDialog(true);
//     } else if (state.recommendedUpdate) {
//       _showUpdateDialog(false);
//     }
//   }
//
//   void _showUpdateDialog(bool isForceUpdate) {
//     // Navigator가 준비되지 않았거나 다이얼로그가 이미 표시된 경우 스킵
//     if (!mounted || !_isNavigatorReady || _dialogShown) {
//       log("Skipping dialog display: mounted=$mounted, navigatorReady=$_isNavigatorReady, dialogShown=$_dialogShown");
//       return;
//     }
//
//     log("Showing update dialog: isForceUpdate=$isForceUpdate");
//
//     // Navigator가 있는지 확인
//     if (Navigator.of(context, rootNavigator: true).context == null) {
//       log("Cannot show dialog - Navigator context is null");
//       return;
//     }
//
//     setState(() {
//       _dialogShown = true;
//     });
//
//     final remoteConfigNotifier = ref.read(remoteConfigProvider.notifier);
//     final remoteConfigState = ref.read(remoteConfigProvider);
//
//     // 안전하게 showDialog 호출
//     Future.microtask(() {
//       if (mounted && _isNavigatorReady) {
//         showDialog(
//           context: context,
//           barrierDismissible: !isForceUpdate,
//           barrierColor: isForceUpdate ? Colors.black87 : Colors.black54,
//           builder: (context) => WillPopScope(
//             onWillPop: () async => !isForceUpdate,
//             child: UpdateDialog(
//               isForceUpdate: isForceUpdate,
//               message: remoteConfigState.updateMessage,
//               onUpdate: () {
//                 remoteConfigNotifier.navigateToStore();
//               },
//               onLater: isForceUpdate
//                   ? null
//                   : () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ),
//         ).then((_) {
//           if (!isForceUpdate && mounted) {
//             setState(() {
//               _dialogShown = false;
//             });
//           }
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // _isNavigatorReady가 true인 경우에만 Remote Config 상태 변화를 감시
//     // if (_isNavigatorReady) {
//       ref.listen<RemoteConfigState>(
//         remoteConfigProvider,
//             (previous, current) {
//           log("Remote config state changed: initialized=${current.initialized}, forceUpdate=${current.forceUpdate}, recommendedUpdate=${current.recommendedUpdate}");
//
//           // 이전에 초기화되지 않았거나, 업데이트 상태가 변경된 경우에만 처리
//           if (previous == null ||
//               !previous.initialized ||
//               previous.forceUpdate != current.forceUpdate ||
//               previous.recommendedUpdate != current.recommendedUpdate) {
//
//             if (current.initialized && !_dialogShown) {
//               _processUpdateStatus(current);
//             }
//           }
//         },
//       );
//     // }
//
//     // 기본 위젯 반환
//     return widget.child;
//   }
// }