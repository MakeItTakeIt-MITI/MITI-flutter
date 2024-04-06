import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scroll_provider.g.dart';

@Riverpod(keepAlive: true)
class PageScrollController extends _$PageScrollController {
  @override
  List<ScrollController> build() {
    return [
      ScrollController(),
      ScrollController(),
      ScrollController(),
      ScrollController(),
    ];
  }
}