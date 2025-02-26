import 'dart:developer';
import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

// Remote Config 설정을 위한 상수
class RemoteConfigKeys {
  static const String recommendedAppVersion = '_recommend_version';
  static const String minimumAppVersion = '_minimum_version';
  static const String recommendUpdateMessage = '_recommend_message';
  static const String minimumUpdateMessage = '_minimum_message';
  static const String appStoreUrl = 'app_store_url';
  static const String playStoreUrl = 'play_store_url';
  static const String ios = 'ios';
  static const String aos = 'aos';
}

// Remote Config 상태 정의
class RemoteConfigState {
  final bool forceUpdate;
  final bool recommendedUpdate;
  final String currentAppVersion;
  final List<String> updateMessage;
  final String updateVersion;
  final String storeUrl;

  RemoteConfigState({
    this.forceUpdate = false,
    this.recommendedUpdate = false,
    this.currentAppVersion = '',
    this.updateMessage = const [],
    this.updateVersion = '',
    this.storeUrl = '',
  });

  RemoteConfigState copyWith({
    bool? forceUpdate,
    bool? recommendedUpdate,
    String? currentAppVersion,
    List<String>? updateMessage,
    String? updateVersion,
    String? storeUrl,
  }) {
    return RemoteConfigState(
      forceUpdate: forceUpdate ?? this.forceUpdate,
      recommendedUpdate: recommendedUpdate ?? this.recommendedUpdate,
      currentAppVersion: currentAppVersion ?? this.currentAppVersion,
      updateMessage: updateMessage ?? this.updateMessage,
      updateVersion: updateVersion ?? this.updateVersion,
      storeUrl: storeUrl ?? this.storeUrl,
    );
  }
}
