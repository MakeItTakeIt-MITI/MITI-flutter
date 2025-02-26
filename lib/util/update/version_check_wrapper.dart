import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:miti/util/update/update_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'force_dialog.dart';

class VersionCheckWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const VersionCheckWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<VersionCheckWrapper> createState() =>
      _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends ConsumerState<VersionCheckWrapper> {
  late final Box<String> recentUpdateViewVersionBox;

  @override
  void initState() {
    super.initState();
    recentUpdateViewVersionBox = Hive.box('recentUpdateVersion');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ref.read(updateProvider.notifier).checkAppVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(updateProvider);
    ref.listen(updateProvider, (prev, after) {
      log('prev = ${prev?.updateVersion}');
      log('after = ${after?.updateVersion}');
      final recentUpdateVersion =
          recentUpdateViewVersionBox.get('recentUpdateVersion');
      if (mounted) {
        if (after.recommendedUpdate) {
          if (recentUpdateVersion != after.updateVersion) {
            recentUpdateViewVersionBox.put(
                'recentUpdateVersion', after.updateVersion);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AppStoreStyleUpdateDialog(
                remoteConfig: after,
              ),
            );
          }
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AppStoreStyleUpdateDialog(
              remoteConfig: after,
            ),
          );
        }
      }
    });
    return widget.child;
  }
}
