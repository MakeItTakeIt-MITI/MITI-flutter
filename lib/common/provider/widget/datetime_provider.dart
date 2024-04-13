import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DateTimeType { start, end }

final showTimePickerProvider =
StateProvider.autoDispose.family<bool, DateTimeType>((ref, type) => false);

final dateProvider = StateProvider.autoDispose
    .family<DateTime?, DateTimeType>((ref, type) => null);

final timeProvider = StateProvider.autoDispose
    .family<DateTime, DateTimeType>((ref, type) => DateTime.now());
